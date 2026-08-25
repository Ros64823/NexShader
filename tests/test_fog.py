import numpy as np

from tests.glsl_runner import run
from tests.reference import fog


def render(pos, rain=0, water=0):
    return run(
        libs=["fog"],
        uniforms={"rainStrength": rain, "isEyeInWater": water},
        body=f"fragOut=vec4(applyNexFog(vec3(.8,.1,.05),vec3({pos}),vec3(.1,.2,.9)),1);",
    )[0, 0, :3]


def test_fog_matches_reference_zero_distance_far_and_rain():
    actual = render("0,0,0")
    assert np.allclose(actual, [.8,.1,.05], atol=1e-5)
    far = render("0,0,256")
    assert np.allclose(far, fog([.8,.1,.05], [0,0,256], [.1,.2,.9], [.5,.6,.7], 128, 0, 0), atol=1e-5)
    assert np.linalg.norm(render("0,0,100", rain=1) - [.8,.1,.05]) > np.linalg.norm(render("0,0,100") - [.8,.1,.05])
    assert np.allclose(render("0,0,10"), fog([.8,.1,.05], [0,0,10], [.1,.2,.9], [.5,.6,.7], 128, 0, 0), atol=1e-5)


def test_underwater_forces_fog_and_result_stays_between_inputs():
    dry = render("0,0,10")
    wet = render("0,0,10", water=1)
    assert not np.allclose(dry, wet)
    target = np.array([.5,.6,.7]) * .55 + np.array([.1,.2,.9]) * .45
    low, high = np.minimum([.8,.1,.05], target), np.maximum([.8,.1,.05], target)
    assert np.all((wet >= low - 1e-6) & (wet <= high + 1e-6))
