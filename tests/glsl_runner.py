"""Moderngl runner for evaluating NexShader GLSL helper functions."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Mapping, Sequence

import moderngl
import numpy as np

from tools.glsl_preprocess import preprocess_file

ROOT = Path(__file__).resolve().parents[1]
SHADER_ROOT = ROOT / "shaders"

_CONTEXT = moderngl.create_standalone_context(require=330, backend="egl")
_TEXTURE_UNIFORMS = ("colortex0", "colortex1", "depthtex0", "shadowtex0", "texture")


def _flattened_source(libs: Sequence[str], defines: Mapping[str, object] | None) -> str:
    chunks = []
    for lib in libs:
        name = lib if lib.endswith(".glsl") else f"{lib}.glsl"
        chunks.append(preprocess_file(SHADER_ROOT / "lib" / name, SHADER_ROOT, defines))
    return "\n".join(chunks)


def _numbered(source: str) -> str:
    return "\n".join(f"{i:5d} | {line}" for i, line in enumerate(source.splitlines(), 1))


def _as_texture(ctx: moderngl.Context, value: Any, shadow: bool = False) -> moderngl.Texture:
    if isinstance(value, moderngl.Texture):
        return value
    data = np.asarray(value, dtype=np.float32)
    if data.ndim == 2:
        data = data[..., None]
    if data.ndim != 3 or data.shape[2] not in (1, 2, 3, 4):
        raise ValueError("textures must have shape (height, width[, channels])")
    data = np.ascontiguousarray(data)
    if shadow:
        if data.shape[2] != 1:
            raise ValueError("shadow textures must have one channel")
        tex = ctx.depth_texture((data.shape[1], data.shape[0]), data=data[..., 0].tobytes())
    else:
        tex = ctx.texture((data.shape[1], data.shape[0]), data.shape[2], data=data.tobytes(), dtype="f4")
    tex.filter = (moderngl.NEAREST, moderngl.NEAREST)
    tex.repeat_x = False
    tex.repeat_y = False
    if shadow:
        tex.compare_func = "<="
    return tex


def _set_uniform(program: moderngl.Program, name: str, value: Any) -> None:
    try:
        uniform = program[name]
    except KeyError:
        return
    if isinstance(value, np.ndarray):
        value = value.tolist()
    if isinstance(value, (list, tuple)):
        value = tuple(np.asarray(value).reshape(-1).tolist())
    uniform.value = value


def run(
    libs: Sequence[str] | None = None,
    body: str = "fragOut = vec4(0.0);",
    uniforms: Mapping[str, Any] | None = None,
    defines: Mapping[str, object] | None = None,
    textures: Mapping[str, Any] | None = None,
    size: int = 1,
) -> np.ndarray:
    """Compile helper libraries and render ``body`` to an RGBA32F array."""
    libs = tuple(libs or ())
    source = _flattened_source(libs, defines)
    vertex = """#version 330 core
void main() {
    vec2 p = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
}"""
    fragment = f"""#version 330 core
#define texture2D texture
vec4 shadow2D(sampler2DShadow sampler, vec3 coordinate) {{
    return vec4(texture(sampler, coordinate));
}}
out vec4 fragOut;
{source}
void main() {{
    {body}
}}"""
    try:
        program = _CONTEXT.program(vertex_shader=vertex, fragment_shader=fragment)
    except moderngl.Error as exc:
        raise RuntimeError(f"GLSL helper compilation failed:\n{exc}\n\n{_numbered(fragment)}") from exc

    defaults: dict[str, Any] = {
        "sunPosition": (0.0, 100.0, 0.0),
        "moonPosition": (0.0, -100.0, 0.0),
        "eyeBrightnessSmooth": (240, 240),
        "rainStrength": 0.0,
        "worldTime": 6000,
        "frameTimeCounter": 0.0,
        "fogColor": (0.5, 0.6, 0.7),
        "far": 128.0,
        "near": 0.1,
        "isEyeInWater": 0,
        "viewWidth": float(size),
        "viewHeight": float(size),
        "gbufferProjectionInverse": np.eye(4, dtype=np.float32),
        "gbufferModelViewInverse": np.eye(4, dtype=np.float32),
        "shadowModelView": np.eye(4, dtype=np.float32),
        "shadowProjection": np.eye(4, dtype=np.float32),
    }
    defaults.update(uniforms or {})
    for name, value in defaults.items():
        _set_uniform(program, name, value)

    dummy_rgba = np.ones((1, 1, 4), dtype=np.float32)
    dummy_depth = np.ones((1, 1), dtype=np.float32)
    supplied = textures or {}
    allocated: list[moderngl.Texture] = []
    for unit, name in enumerate(_TEXTURE_UNIFORMS):
        value = supplied.get(name, dummy_depth if name in ("depthtex0", "shadowtex0") else dummy_rgba)
        tex = _as_texture(_CONTEXT, value, shadow=name == "shadowtex0")
        if not isinstance(value, moderngl.Texture):
            allocated.append(tex)
        tex.use(location=unit)
        _set_uniform(program, name, unit)

    target = _CONTEXT.texture((size, size), 4, dtype="f4")
    target.filter = (moderngl.NEAREST, moderngl.NEAREST)
    framebuffer = _CONTEXT.framebuffer(color_attachments=[target])
    framebuffer.use()
    framebuffer.clear(0.0, 0.0, 0.0, 0.0)
    vao = _CONTEXT.vertex_array(program, [])
    vao.render(mode=moderngl.TRIANGLES, vertices=3)
    result = np.frombuffer(target.read(), dtype=np.float32).reshape((size, size, 4)).copy()
    vao.release()
    framebuffer.release()
    target.release()
    for tex in allocated:
        tex.release()
    return result


__all__ = ["run"]
