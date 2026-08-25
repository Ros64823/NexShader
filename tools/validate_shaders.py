"""Validate every top-level NexShader program with glslangValidator."""

from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from tools.glsl_preprocess import preprocess_file


def validate(shader_root: Path, validator: str = "glslangValidator") -> int:
    programs = sorted((*shader_root.glob("*.vsh"), *shader_root.glob("*.fsh")))
    failures = 0
    with tempfile.TemporaryDirectory(prefix="nexshader-glsl-") as tmp:
        tmp_path = Path(tmp)
        for source in programs:
            stage = "vert" if source.suffix == ".vsh" else "frag"
            flattened = preprocess_file(source, shader_root)
            generated = tmp_path / source.name
            generated.write_text(flattened)
            result = subprocess.run(
                [validator, "-S", stage, str(generated)],
                capture_output=True,
                text=True,
            )
            if result.returncode:
                failures += 1
                print(f"FAIL {source.relative_to(shader_root)}")
                print((result.stdout + result.stderr).rstrip())
            else:
                print(f"PASS {source.relative_to(shader_root)}")
    print(f"{len(programs) - failures}/{len(programs)} shader programs passed")
    return 1 if failures else 0


def main() -> int:
    root = Path(__file__).resolve().parent.parent / "shaders"
    return validate(root)


if __name__ == "__main__":
    raise SystemExit(main())
