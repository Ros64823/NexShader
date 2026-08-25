import numpy as np

from tests.glsl_runner import run


def shadow(depth, position="0,0,0", samples="6"):
    return run(
        libs=["shadows"],
        defines={"SHADOW_SAMPLES": samples},
        textures={"shadowtex0": np.asarray(depth, dtype=np.float32)},
        body=f"fragOut=vec4(shadowVisibility(vec3({position}),vec3(0,0,1),vec3(0,0,1)));",
        size=4,
    )[0, 0, 0]


def test_shadow_outside_frustum_lit_occluded_range_and_sample_options():
    assert shadow(np.zeros((4,4)), position="3,0,0") == 1
    lit = shadow(np.ones((4,4)))
    occluded = shadow(np.zeros((4,4)))
    assert lit > occluded
    assert 0 <= occluded <= 1
    assert 0 <= lit <= 1
    assert 0 <= shadow(np.ones((4,4)), samples="1") <= 1
    assert 0 <= shadow(np.ones((4,4)), samples="12") <= 1
