#!/usr/bin/env python3
"""Compile-check every shader stage with glslangValidator (includes expanded),
and verify that every profile value in shaders.properties is present in the
allowed-value list of its option in lib/config.glsl."""
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "shaders")


def expand(path, seen):
    out = []
    for line in open(path):
        m = re.match(r'\s*#include\s+"(/.*?)"', line)
        if m:
            inc = ROOT + m.group(1)
            if inc not in seen:
                seen.add(inc)
                out.append(expand(inc, seen))
        else:
            out.append(line)
    return "".join(out)


def check_stages():
    fail = 0
    for f in sorted(os.listdir(ROOT)):
        if not (f.endswith(".vsh") or f.endswith(".fsh")):
            continue
        stage = "vert" if f.endswith(".vsh") else "frag"
        src = expand(os.path.join(ROOT, f), set())
        with tempfile.NamedTemporaryFile("w", suffix="." + stage, delete=False) as t:
            t.write(src)
            tmp = t.name
        r = subprocess.run(["glslangValidator", "-S", stage, tmp],
                           capture_output=True, text=True)
        if r.returncode != 0:
            fail += 1
            print(f"{f}: FAIL\n{r.stdout}{r.stderr}")
        else:
            print(f"{f}: OK")
        os.unlink(tmp)
    return fail


def check_profiles():
    allowed = {}
    for line in open(os.path.join(ROOT, "lib/config.glsl")):
        m = re.match(r'#define (\w+) [\d.]+ // \[([^\]]+)\]', line)
        if m:
            allowed[m.group(1)] = set(m.group(2).split())
    bad = 0
    for line in open(os.path.join(ROOT, "shaders.properties")):
        m = re.match(r'profile\.(\w+)=(.*)', line)
        if not m:
            continue
        prof = m.group(1)
        for kv in m.group(2).split():
            k, v = kv.split("=")
            if k in allowed and v not in allowed[k]:
                print(f"{prof}: {k}={v} not in {sorted(allowed[k])}")
                bad += 1
            elif k not in allowed:
                print(f"{prof}: {k} has no allowed-value list in config.glsl")
                bad += 1
    print("profiles OK" if not bad else f"{bad} profile value mismatches")
    return bad


if __name__ == "__main__":
    failures = check_stages() + check_profiles()
    sys.exit(1 if failures else 0)
