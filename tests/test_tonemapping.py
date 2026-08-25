import numpy as np

from tests.glsl_runner import run
from tests.reference import tonemap


def render(c, defines=None):
    return run(
        libs=["tonemapping"],
        defines=defines,
        body=f"fragOut = vec4(tonemapNex(vec3({c[0]},{c[1]},{c[2]})),1.0);",
    )[0, 0, :3]


def test_tonemap_matches_reference_and_is_clamped_monotonic():
    for c in ([.1, .2, .4], [1, 2, 4], [10, 10, 10]):
        assert np.allclose(render(c), tonemap(c, 1, 1.05, 1.06), atol=1e-5)
        assert np.all((render(c) >= 0) & (render(c) <= 1))
    luminances = [render([x, x, x])[0] for x in (.05, .2, 1, 4, 20)]
    assert np.all(np.diff(luminances) >= -1e-6)


def test_saturation_one_preserves_hue_ratios_and_config_extremes_compile():
    result = render([.08, .16, .32], {"SATURATION": "1.00"})
    reference = tonemap([.08, .16, .32], 1, 1.05, 1)
    assert np.allclose(result, reference, atol=1e-5)
    for exposure in ("0.70", "1.35"):
        for contrast in ("0.85", "1.30"):
            for saturation in ("0.80", "1.30"):
                result = render([.2, .4, .7], {"EXPOSURE": exposure, "CONTRAST": contrast, "SATURATION": saturation})
                assert np.all((result >= 0) & (result <= 1))
