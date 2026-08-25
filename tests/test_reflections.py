import numpy as np

from tests.glsl_runner import run


def reflection(enabled="1", strength=".8"):
    tex = np.zeros((2,2,4), dtype=np.float32)
    tex[..., :3] = [.9,.2,.1]
    return run(
        libs=["reflections"],
        defines={"SSR_ENABLED": enabled},
        textures={"colortex0": tex},
        body=f"fragOut=vec4(screenReflection(vec2(.25,.5),vec3(.1,.2,.3),{strength}),1);",
    )[0, 0, :3]


def test_reflections_toggle_blend_and_zero_strength():
    base = np.array([.1,.2,.3])
    assert np.allclose(reflection(enabled="0"), base, atol=1e-5)
    result = reflection()
    assert np.all(result >= np.minimum(base, [.9,.2,.1]) - 1e-6)
    assert np.all(result <= np.maximum(base, [.9,.2,.1]) + 1e-6)
    assert np.allclose(reflection(strength="0"), base, atol=1e-5)
