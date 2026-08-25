import numpy as np

from tests.glsl_runner import run
from tests.reference import ambient_color, apply_lighting, sun_color


def test_sun_color_warm_horizon_neutral_noon_and_rain_reduction():
    horizon = run(libs=["lighting"], uniforms={"sunPosition": (0, 0, 0)}, body="fragOut=vec4(sunColor(),1);")[0,0,:3]
    noon = run(libs=["lighting"], uniforms={"sunPosition": (0, 100, 0)}, body="fragOut=vec4(sunColor(),1);")[0,0,:3]
    rainy = run(libs=["lighting"], uniforms={"sunPosition": (0, 100, 0), "rainStrength": 1}, body="fragOut=vec4(sunColor(),1);")[0,0,:3]
    assert np.allclose(horizon, sun_color((0,0,0)), atol=1e-5)
    assert horizon[1] / horizon[0] < noon[1] / noon[0]
    assert np.all(rainy < noon)


def test_ambient_brightness_and_sun_height_increase_and_clamp():
    low = run(libs=["lighting"], uniforms={"sunPosition": (0, 0, 0), "eyeBrightnessSmooth": (0,0)}, body="fragOut=vec4(ambientColor(),1);")[0,0,:3]
    bright = run(libs=["lighting"], uniforms={"sunPosition": (0, 0, 0), "eyeBrightnessSmooth": (240,240)}, body="fragOut=vec4(ambientColor(),1);")[0,0,:3]
    high = run(libs=["lighting"], uniforms={"sunPosition": (0, 100, 0), "eyeBrightnessSmooth": (240,240)}, body="fragOut=vec4(ambientColor(),1);")[0,0,:3]
    assert np.allclose(low, ambient_color((0,0,0), (0,0)), atol=1e-5)
    assert np.all(bright > low)
    assert np.all(high <= np.array([.23,.30,.38]) + 1e-6)


def test_apply_lighting_is_linear_and_shadow_orders_with_wrap_ambient():
    kwargs = {"sunPosition": (0,100,0), "eyeBrightnessSmooth": (240,240)}
    lit = run(libs=["lighting"], uniforms=kwargs, body="fragOut=vec4(applyLighting(vec3(.2,.4,.6),vec3(0,1,0),vec3(0,0,-1),1),1);")[0,0,:3]
    expected = apply_lighting([.2,.4,.6], [0,1,0], (0,100,0), (240,240), 0, 1)
    assert np.allclose(lit, expected, atol=1e-5)
    black = run(libs=["lighting"], uniforms=kwargs, body="fragOut=vec4(applyLighting(vec3(0),vec3(0,1,0),vec3(0),1),1);")[0,0,:3]
    half = run(libs=["lighting"], uniforms=kwargs, body="fragOut=vec4(applyLighting(vec3(.2,.4,.6),vec3(0,1,0),vec3(0),.5),1);")[0,0,:3]
    full = run(libs=["lighting"], uniforms=kwargs, body="fragOut=vec4(applyLighting(vec3(.2,.4,.6),vec3(0,1,0),vec3(0),1),1);")[0,0,:3]
    away = run(libs=["lighting"], uniforms=kwargs, body="fragOut=vec4(applyLighting(vec3(1),vec3(0,0,-1),vec3(0),0),1);")[0,0,:3]
    assert np.allclose(black, 0, atol=1e-6)
    assert np.all(full >= half)
    assert np.all(away > 0)
