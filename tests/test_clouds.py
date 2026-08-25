import numpy as np

from tests.glsl_runner import run


def cloud(direction, quality="4", frame=0):
    return run(
        libs=["clouds"],
        defines={"CLOUD_QUALITY": quality},
        uniforms={"frameTimeCounter": frame},
        body=f"fragOut=vec4(cloudLayer(normalize(vec3({direction}))),0,0,1);",
    )[0, 0, 0]


def test_cloud_quality_zero_downward_and_range():
    assert cloud("0,.5,1", "0") == 0
    assert cloud("0,-1,0") == 0
    assert 0 <= cloud(".3,.6,.8") <= 1


def test_cloud_layer_varies_over_time():
    values = [cloud(".31,.57,.77", frame=t) for t in (0, 100, 1000, 10000)]
    assert max(values) != min(values)
