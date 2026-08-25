"""Independent NumPy references for NexShader's pure helper formulas."""

from __future__ import annotations

import numpy as np


def luma(c):
    return np.dot(np.asarray(c), np.array([0.2126, 0.7152, 0.0722], dtype=np.float32))


def hash12(p):
    p = np.asarray(p, dtype=np.float32)
    return np.mod(np.sin(np.dot(p, np.array([127.1, 311.7], dtype=np.float32))) * 43758.5453, 1.0)


def encode_normal(n):
    return np.asarray(n) * 0.5 + 0.5


def decode_normal(n):
    v = np.asarray(n) * 2.0 - 1.0
    return v / np.linalg.norm(v, axis=-1, keepdims=True)


def screen_to_view(uv, depth, inv_proj):
    p = np.array([uv[0] * 2 - 1, uv[1] * 2 - 1, depth * 2 - 1, 1.0])
    p = np.asarray(inv_proj) @ p
    return p[:3] / max(p[3], 1e-5)


def linear_depth(d, near, far):
    return (2 * near) / (far + near - d * (far - near))


def tonemap(c, exposure=1.0, contrast=1.05, saturation=1.06):
    c = np.asarray(c, dtype=np.float32) * exposure
    c = (c * (2.51 * c + 0.03)) / (c * (2.43 * c + 0.59) + 0.14)
    y = luma(c)
    c = y + (c - y) * saturation
    return np.clip((c - 0.5) * contrast + 0.5, 0, 1)


def water_color(base, normal, view_dir, depth, quality=4):
    fres = (1 - np.clip(np.dot(normal, -np.asarray(view_dir)), 0, 1)) ** 3
    shallow = np.array([0.18, 0.55, 0.62])
    deep = np.array([0.03, 0.16, 0.28])
    water = shallow + (deep - shallow) * np.clip(depth * 2, 0, 1)
    water = water + (np.array([0.65, 0.86, 1.0]) - water) * (fres * 0.35)
    return water * (0.75 + 0.25 * quality / 6)


def water_normal(n, uv, frame_time, quality=4):
    w = np.sin((uv[0] + frame_time * 0.025) * 80) + np.cos((uv[1] - frame_time * 0.018) * 64)
    value = np.asarray(n) + np.array([w * 0.035 * quality, 0, w * 0.025 * quality])
    return value / np.linalg.norm(value)


def fog(color, view_pos, sky, fog_color, far, rain, eye_in_water, quality=4):
    dist = np.linalg.norm(view_pos)
    t = np.clip((dist - far * (0.25 + 0.04 * quality)) / (far - far * (0.25 + 0.04 * quality)), 0, 1)
    f = t * t * (3 - 2 * t)
    f *= 0.45 + 0.07 * quality + rain * 0.35
    if eye_in_water == 1:
        x = np.clip((dist - 2) / 16, 0, 1)
        f = max(f, (x * x * (3 - 2 * x)) * 0.75)
    target = np.asarray(fog_color) * 0.55 + np.asarray(sky) * 0.45
    return np.asarray(color) * (1 - np.clip(f, 0, 1)) + target * np.clip(f, 0, 1)


def sun_color(sun_position, rain=0, world_time=6000):
    t = np.clip(sun_position[1] / 100, 0, 1)
    dusk_x = 1 - abs(world_time - 12000) / 12000
    dusk = np.clip((dusk_x - 0) / 0.28, 0, 1)
    dusk = dusk * dusk * (3 - 2 * dusk)
    return (np.array([1, .52, .28]) * (1 - t) + np.array([1, .92, .78]) * t) * (1 - rain * .35) + dusk * np.array([.10, .03, .01])


def ambient_color(sun_position, eye_brightness, rain=0):
    day = np.clip(sun_position[1] / 100, 0, 1)
    sky = eye_brightness[1] / 240
    amount = max(day, sky * .6)
    return (np.array([.025, .035, .06]) * (1 - amount) + np.array([.23, .30, .38]) * amount) * (1 - rain * .25)


def apply_lighting(albedo, normal, sun_position, eye_brightness, rain, shadow):
    l = np.asarray(sun_position) / np.linalg.norm(sun_position)
    ndl = max(float(np.dot(normal, l)), 0)
    wrap = np.clip((np.dot(normal, l) + .35) / 1.35, 0, 1)
    amb = ambient_color(sun_position, eye_brightness, rain) * (.55 + .45 * normal[1])
    return np.asarray(albedo) * (amb + sun_color(sun_position, rain) * (ndl * shadow + .18 * wrap))
