import numpy as np

from tests.glsl_runner import run


def bloom(texture, enabled="1", quality="3"):
    size = len(texture)
    return run(
        libs=["bloom"],
        defines={"BLOOM_ENABLED": enabled, "BLOOM_QUALITY": quality},
        textures={"colortex0": np.asarray(texture, dtype=np.float32)},
        uniforms={"viewWidth": float(size), "viewHeight": float(size)},
        body="fragOut=vec4(bloom(vec2(.5)),1);",
        size=size,
    )[size // 2, size // 2, :3]


def test_bloom_toggle_black_bright_and_quality_scaling():
    assert np.allclose(bloom(np.zeros((4,4,4)), enabled="0"), 0)
    assert np.allclose(bloom(np.zeros((4,4,4))), 0)
    bright = np.ones((4,4,4), dtype=np.float32)
    low = bloom(bright, quality="1")
    high = bloom(bright, quality="6")
    assert np.all(low > 0)
    assert np.all(high > low)
