#!/usr/bin/env python3
"""Evidence harness: executes NexShader's REAL GLSL (lighting + tonemapping)
headlessly via moderngl/llvmpipe and measures per-component luminance for
controlled scenarios. No transcription of the math — the actual lib files
are #include-expanded into the test shader."""
import math
import os
import re
import sys

import moderngl
import numpy as np

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "shaders")


def expand(path, seen):
    out = []
    for line in open(path):
        m = re.match(r'\s*#include\s+"(/.*?)"', line)
        if m:
            inc = ROOT + m.group(1)
            if inc not in seen:
                seen.add(inc)
                out.append(expand(inc, seen))
        else:
            out.append(line)
    return "".join(out)


LIBS = expand(ROOT + "/lib/lighting.glsl", set()) + expand(ROOT + "/lib/tonemapping.glsl", set())

FRAG = """#version 330 core
#define texture2D texture
""" + LIBS + """
uniform vec3 u_albedo;
uniform vec3 u_normal;      // view space
uniform float u_shadow;
uniform float u_ao;
uniform vec2 u_lm;
layout(location=0) out vec4 o_lit;      // lighting output (what composite writes)
layout(location=1) out vec4 o_final;    // after nexTonemap (what final.fsh shows)
layout(location=2) out vec4 o_ambient;  // ambient component only
layout(location=3) out vec4 o_meta;     // dayFactor, sunUp, skyGate, shadowTerm
void main(){
    vec3 lit = nexApplyLighting(nexSrgbToLinear(u_albedo), u_normal, u_shadow, u_ao, u_lm);
    o_lit = vec4(lit, 1.0);
    o_final = vec4(nexTonemap(lit, mix(3.0, 1.0, nexDayFactor())), 1.0);
    o_ambient = vec4(nexAmbientColor(u_normal, u_lm), 1.0);
    float sunUp = nexSunUpFactor();
    float skyGate = smoothstep(0.05, 0.55, u_lm.y);
    float shadowTerm = mix(1.0, u_shadow, SHADOW_STRENGTH);
    o_meta = vec4(nexDayFactor(), sunUp, skyGate, shadowTerm);
}
"""

VERT = """#version 330 core
const vec2 v[3] = vec2[3](vec2(-1,-1), vec2(3,-1), vec2(-1,3));
void main(){ gl_Position = vec4(v[gl_VertexID], 0.0, 1.0); }
"""

ctx = moderngl.create_context(standalone=True, backend="egl")
prog = ctx.program(vertex_shader=VERT, fragment_shader=FRAG)
vao = ctx.vertex_array(prog, [])
texs = [ctx.texture((1, 1), 4, dtype="f4") for _ in range(4)]
fbo = ctx.framebuffer(color_attachments=texs)


def run(albedo, normal, shadow, ao, lm, sun_view, rain=0.0):
    prog["u_albedo"].value = albedo
    prog["u_normal"].value = tuple(np.asarray(normal) / np.linalg.norm(normal))
    prog["u_shadow"].value = shadow
    prog["u_ao"].value = ao
    prog["u_lm"].value = lm
    prog["sunPosition"].value = tuple(sun_view)
    mv = np.eye(4, dtype="f4")
    mv[:3, :3] = np.linalg.inv(CUR_VIEW).astype("f4")  # gbufferModelViewInverse rotation
    prog["gbufferModelViewInverse"].write(mv.T.tobytes())
    prog["rainStrength"].value = rain
    fbo.use()
    vao.render(moderngl.TRIANGLES, vertices=3)
    out = []
    for t in texs:
        out.append(np.frombuffer(t.read(), dtype="f4")[:3])
    return out  # lit, final, ambient, meta


def luma(c):
    return float(np.dot(c, [0.2126, 0.7152, 0.0722]))


def view_matrix(pitch_deg, yaw_deg):
    """Minecraft-style view rotation matrix (world->view)."""
    p, y = math.radians(pitch_deg), math.radians(yaw_deg)
    ry = np.array([[math.cos(y), 0, -math.sin(y)], [0, 1, 0], [math.sin(y), 0, math.cos(y)]])
    rx = np.array([[1, 0, 0], [0, math.cos(p), math.sin(p)], [0, -math.sin(p), math.cos(p)]])
    return rx @ ry


CUR_VIEW = np.eye(3)


def sun_view_vec(elev_deg, pitch_deg, yaw_deg):
    global CUR_VIEW
    e = math.radians(elev_deg)
    sun_world = np.array([math.cos(e), math.sin(e), 0.0])
    CUR_VIEW = view_matrix(pitch_deg, yaw_deg)
    return CUR_VIEW @ sun_world * 100.0


GRASS = (0.35, 0.48, 0.22)  # sRGB-space grass albedo

print("=" * 78)
print("EVIDENCIA 1: dependencia de la CAMARA (sol a 65 grados de elevacion, mediodia)")
print("Mismo pixel de terreno (cesped soleado, up-facing, shadow=1, lm.y=1.0)")
print("Solo cambia la orientacion de la camara:")
print(f"{'pitch/yaw':>12} | {'dayFactor':>9} | {'sunUp':>6} | {'luma lit':>8} | {'luma final':>10}")
for pitch, yaw in [(0, 0), (0, 90), (0, 180), (-45, 0), (-80, 0), (45, 0), (80, 0), (30, 135)]:
    sv = sun_view_vec(65, pitch, yaw)
    normal_view = view_matrix(pitch, yaw) @ np.array([0, 1, 0])
    lit, final, amb, meta = run(GRASS, normal_view, 1.0, 1.0, (0.0, 1.0), sv)
    print(f"{pitch:>5}/{yaw:<6} | {meta[0]:>9.3f} | {meta[1]:>6.3f} | {luma(lit):>8.3f} | {luma(final):>10.3f}")

print()
print("=" * 78)
print("EVIDENCIA 2: black crush (camara neutra pitch=0/yaw=0, sol 65 grados)")
print("Valores 'final' = lo que se muestra en pantalla (final.fsh no re-encodea a sRGB)")
print(f"{'escenario':>34} | {'luma lit':>8} | {'luma amb':>8} | {'luma FINAL':>10}")
scenarios = [
    ("cesped SOL (shadow=1 ao=1 lmY=1)", GRASS, (0, 1, 0), 1.0, 1.0, (0.0, 1.0)),
    ("cesped SOMBRA (shadow=0 ao=.85 lmY=.75)", GRASS, (0, 1, 0), 0.0, 0.85, (0.0, 0.75)),
    ("cesped bosque denso (sh=0 ao=.7 lmY=.55)", GRASS, (0, 1, 0), 0.0, 0.70, (0.0, 0.55)),
    ("tronco lateral (sh=0 ao=.8 lmY=.6)", (0.42, 0.32, 0.20), (1, 0, 0), 0.0, 0.8, (0.0, 0.6)),
    ("interior/cueva (sh=0 ao=.9 lmY=.15)", (0.5, 0.5, 0.5), (0, 1, 0), 0.0, 0.9, (0.0, 0.15)),
    ("interior antorcha (lmX=.85 lmY=.1)", (0.5, 0.5, 0.5), (0, 1, 0), 0.0, 0.9, (0.85, 0.1)),
]
for name, alb, n, sh, ao, lm in scenarios:
    nv = view_matrix(0, 0) @ np.array(n, dtype=float)
    sv = sun_view_vec(65, 0, 0)
    lit, final, amb, meta = run(alb, nv, sh, ao, lm, sv)
    print(f"{name:>42} | {luma(lit):>8.3f} | {luma(amb):>8.3f} | {luma(final):>10.3f}")

print()
print("Referencia: en un monitor sRGB, luminancia lineal 0.05 se percibe ~0.25;")
print("final.fsh actualmente muestra el valor del tonemap SIN codificacion sRGB.")
