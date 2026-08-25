#!/usr/bin/env python3
"""Compile every shader program with glslangValidator, once per quality profile.

Iris reports a shader compile error by falling back to vanilla rendering, so a
broken program (a duplicated uniform, a typo behind an #if) is easy to ship
without noticing. This script resolves the `#include` tree the way Iris does and
fails loudly on any compile error.

Usage: python3 tools/validate_shaders.py [--profile NORMAL]
Requires glslangValidator (Debian/Ubuntu: apt-get install glslang-tools).
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHADERS = os.path.join(REPO, "shaders")
PROPERTIES = os.path.join(SHADERS, "shaders.properties")
INCLUDE = re.compile(r'^\s*#include\s+"([^"]+)"\s*$')
DEFINE = re.compile(r"^(\s*#define\s+)(\w+)(\s+)(\S+)(.*)$")
STAGE_EXT = {".fsh": ".frag", ".vsh": ".vert"}


def read_profiles():
    """Return {profile_name: {macro: value}} from shaders.properties."""
    profiles = {}
    if not os.path.exists(PROPERTIES):
        return profiles
    with open(PROPERTIES, encoding="utf-8") as handle:
        for line in handle:
            if not line.startswith("profile."):
                continue
            name, _, settings = line[len("profile."):].partition("=")
            values = {}
            for token in settings.split():
                if "=" in token:
                    macro, _, value = token.partition("=")
                    values[macro] = value
            profiles[name.strip()] = values
    return profiles


def expand(path, stack):
    """Inline #include directives, honouring the include guards like a real preprocessor."""
    if path in stack:
        raise RuntimeError("circular include: %s" % " -> ".join(stack + [path]))
    if not os.path.exists(path):
        raise RuntimeError("missing include target: %s" % path)
    lines = []
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            match = INCLUDE.match(line)
            if match:
                target = os.path.join(SHADERS, match.group(1).lstrip("/"))
                lines.extend(expand(target, stack + [path]))
            else:
                lines.append(line)
    return lines


def apply_profile(lines, overrides):
    out = []
    for line in lines:
        match = DEFINE.match(line)
        if match and match.group(2) in overrides:
            line = "%s%s%s%s%s\n" % (
                match.group(1), match.group(2), match.group(3),
                overrides[match.group(2)], match.group(5).rstrip("\n"),
            )
        out.append(line)
    return out


def compile_source(source, ext):
    with tempfile.NamedTemporaryFile("w", suffix=ext, delete=False, encoding="utf-8") as handle:
        handle.write(source)
        temp = handle.name
    try:
        result = subprocess.run(
            ["glslangValidator", temp], capture_output=True, text=True, check=False
        )
        return result.returncode, result.stdout.replace(temp, "<source>")
    finally:
        os.unlink(temp)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", action="append", help="only validate these profiles")
    args = parser.parse_args()

    if shutil.which("glslangValidator") is None:
        print("glslangValidator not found; install glslang-tools", file=sys.stderr)
        return 2

    profiles = read_profiles()
    selected = args.profile or sorted(profiles) or ["<defaults>"]
    programs = sorted(f for f in os.listdir(SHADERS) if os.path.splitext(f)[1] in STAGE_EXT)
    failures = []

    for profile in selected:
        if profile not in profiles and profile != "<defaults>":
            print("unknown profile: %s" % profile, file=sys.stderr)
            return 2
        overrides = profiles.get(profile, {})
        for program in programs:
            ext = STAGE_EXT[os.path.splitext(program)[1]]
            source = "".join(apply_profile(expand(os.path.join(SHADERS, program), []), overrides))
            code, output = compile_source(source, ext)
            status = "ok" if code == 0 else "FAIL"
            print("%-10s %-24s %s" % (profile, program, status))
            if code != 0:
                failures.append((profile, program, output.strip()))

    for profile, program, output in failures:
        print("\n=== %s / %s\n%s" % (profile, program, output), file=sys.stderr)
    print("\n%d program/profile combination(s) failed" % len(failures))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
