from tests.glsl_runner import run


def rays(uv, enabled="1"):
    return run(
        libs=["volumetrics"],
        defines={"VOLUMETRIC_ENABLED": enabled},
        uniforms={"sunPosition": (0,100,0)},
        body=f"fragOut=vec4(godRays(vec2({uv})),0,0,1);",
    )[0, 0, 0]


def test_god_rays_toggle_nonnegative_and_projected_sun_peak():
    assert rays(".5,.75", "0") == 0
    assert rays("0,0") >= 0
    assert rays(".5,.75") > rays("0,0")
