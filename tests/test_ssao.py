import numpy as np

from tests.glsl_runner import run


def ssao(depth, uv=".5,.5", enabled="1"):
    size = len(depth)
    return run(
        libs=["ssao"],
        defines={"SSAO_ENABLED": enabled},
        uniforms={"viewWidth": float(size), "viewHeight": float(size)},
        textures={"depthtex0": np.asarray(depth, dtype=np.float32)},
        body=f"fragOut=vec4(computeSSAO(vec2({uv}),.9),0,0,1);",
        size=size,
    )[size // 2, size // 2, 0]


def test_ssao_toggle_flat_depth_and_edge_occlusion():
    assert ssao(np.ones((4,4)), enabled="0") == 1
    assert np.isclose(ssao(np.ones((8,8))), 1, atol=1e-5)
    edge = np.full((8,8), .9, dtype=np.float32)
    edge[:, :4] = .5
    assert ssao(edge, uv=".5,.5") < 1
    assert 0 <= ssao(edge, uv=".5,.5") <= 1
