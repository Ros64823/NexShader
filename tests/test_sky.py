import numpy as np

from tests.glsl_runner import run


def render(direction, sun, rain=0):
    return run(
        libs=["sky"],
        uniforms={"sunPosition": sun, "rainStrength": rain},
        body=f"fragOut=vec4(skyGradient(normalize(vec3({direction}))),1);",
    )[0, 0, :3]


def test_sky_gradient_day_night_and_sunset_rain():
    day = render("0,.5,1", (0,100,0))
    night = render("0,.5,1", (0,-20,0))
    assert np.linalg.norm(day) > np.linalg.norm(night)
    sunset = render("0,.1,1", (0,10,1))
    away = render("0,.1,-1", (0,10,1))
    assert sunset[0] > away[0]
    rainy = render("0,.1,1", (0,10,1), rain=1)
    assert rainy[0] < sunset[0]


def test_star_field_is_nonnegative_and_hidden_by_high_sun():
    high = run(libs=["sky"], uniforms={"sunPosition": (0,100,0)}, body="fragOut=vec4(starField(vec3(.13,.4,.27)));")[0,0,0]
    low = run(libs=["sky"], uniforms={"sunPosition": (0,0,0)}, body="fragOut=vec4(starField(vec3(.13,.4,.27)));")[0,0,0]
    assert high == 0
    assert low >= 0
