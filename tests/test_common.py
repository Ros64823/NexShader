import numpy as np

from tests.glsl_runner import run
from tests.reference import decode_normal, encode_normal, hash12, linear_depth, luma, screen_to_view


def value(body, **kwargs):
    return run(libs=["common"], body=f"fragOut = vec4(vec3({body}),1.0);", **kwargs)[0, 0]


def test_luma_matches_rec709_and_is_linear():
    for c in ([1, 0, 0], [0.2, 0.4, 0.8], [0.33, 0.33, 0.33]):
        assert np.isclose(value("luma(vec3(%ff,%ff,%ff))" % tuple(c))[0], luma(c), atol=1e-5)
    assert np.isclose(value("luma(vec3(0.4))")[0], 0.4, atol=1e-5)
    a, b = np.array([.1, .2, .3]), np.array([.4, .1, .2])
    assert np.isclose(value("luma(vec3(.1,.2,.3)+vec3(.4,.1,.2))")[0], luma(a + b), atol=1e-5)


def test_hash12_is_deterministic_bounded_and_input_sensitive():
    first = value("hash12(vec2(1.25,-3.5))")[0]
    second = value("hash12(vec2(1.25,-3.5))")[0]
    other = value("hash12(vec2(2.25,-3.5))")[0]
    assert first == second
    assert 0 <= first < 1
    assert first != other


def test_normal_encoding_round_trip_and_unit_length():
    normal = np.array([.3, .4, .8660254], dtype=np.float32)
    encoded = value("encodeNormal(normalize(vec3(.3,.4,.8660254)))")[:3]
    decoded = value("decodeNormal(encodeNormal(normalize(vec3(.3,.4,.8660254))))")[:3]
    assert np.allclose(encoded, encode_normal(normal / np.linalg.norm(normal)), atol=1e-5)
    assert np.allclose(decoded, normal / np.linalg.norm(normal), atol=1e-5)
    assert np.isclose(np.linalg.norm(decoded), 1.0, atol=1e-5)


def test_screen_to_view_identity_and_perspective_inverse():
    identity = value("screenToView(vec2(.5), .5, mat4(1.0))")
    assert np.allclose(identity[:3], [0, 0, 0], atol=1e-5)
    matrix = np.diag([2.0, 3.0, 4.0, 2.0]).astype(np.float32)
    actual = value("screenToView(vec2(.75,.25), .5, mat4(2.0,0,0,0, 0,3.0,0,0, 0,0,4.0,0, 0,0,0,2.0))")
    assert np.allclose(actual[:3], screen_to_view((.75, .25), .5, matrix), atol=1e-5)
    guarded = value("screenToView(vec2(.5), .5, mat4(0.0))")
    assert np.all(np.isfinite(guarded))


def test_linear_depth_matches_formula_and_is_monotonic():
    values = [value(f"linearDepth({d}, .1, 128.0)")[0] for d in (0.0, .25, .5, .75, 1.0)]
    assert np.allclose(values, [linear_depth(d, .1, 128) for d in (0, .25, .5, .75, 1)], atol=3e-5)
    assert values == sorted(values)
    assert np.isclose(values[0], linear_depth(0, .1, 128), atol=1e-5)
