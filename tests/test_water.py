import numpy as np

from tests.glsl_runner import run
from tests.reference import water_color, water_normal


def color(normal, view, depth, quality="4"):
    return run(
        libs=["water"],
        defines={"WATER_QUALITY": quality},
        body=f"fragOut=vec4(waterColor(vec3(.2,.3,.4),vec3({normal}),vec3({view}),{depth}),1);",
    )[0, 0, :3]


def test_water_color_matches_reference_fresnel_depth_and_quality():
    n, v = np.array([0, 1, 0]), np.array([0, -1, 0])
    for depth in (0, .25, 1):
        actual = color("0,1,0", "0,-1,0", depth)
        assert np.allclose(actual, water_color([.2,.3,.4], n, v, depth), atol=1e-5)
    normal = color("0,1,0", "0,-1,0", 0)
    grazing = color("1,0,0", "0,1,0", 0)
    assert np.linalg.norm(grazing - np.array([.18,.55,.62])) > np.linalg.norm(normal - np.array([.18,.55,.62]))
    assert np.linalg.norm(color("0,1,0", "0,1,0", 1)) < np.linalg.norm(color("0,1,0", "0,1,0", 0))
    assert np.linalg.norm(color("0,1,0", "0,1,0", 1, "6")) > np.linalg.norm(color("0,1,0", "0,1,0", 1, "0"))


def test_water_normal_is_unit_varies_with_time_and_quality_zero_is_input():
    body = "fragOut=vec4(waterNormal(normalize(vec3(.2,.9,.1)),vec2(.13,.27)),1);"
    a = run(libs=["water"], body=body, uniforms={"frameTimeCounter": 0})[0, 0, :3]
    b = run(libs=["water"], body=body, uniforms={"frameTimeCounter": 12})[0, 0, :3]
    q0 = run(libs=["water"], body=body, defines={"WATER_QUALITY": "0"})[0, 0, :3]
    expected = water_normal(np.array([.2,.9,.1]) / np.linalg.norm([.2,.9,.1]), [.13,.27], 0, 4)
    assert np.allclose(a, expected, atol=1e-5)
    assert np.isclose(np.linalg.norm(a), 1, atol=1e-5)
    assert not np.allclose(a, b)
    assert np.allclose(q0, np.array([.2,.9,.1]) / np.linalg.norm([.2,.9,.1]), atol=1e-5)
