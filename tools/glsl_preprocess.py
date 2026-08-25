"""Small include flattener for the absolute includes used by NexShader."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Mapping

_INCLUDE = re.compile(r"^(\s*)#include\s+\"(/[^\"]+)\"\s*$")
_DEFINE = re.compile(r"^(\s*#define\s+)([A-Za-z_]\w*)(\s+)(\S+)(.*)$")


class IncludeCycleError(ValueError):
    """Raised when an include recursively refers to an active source file."""


def preprocess(
    source: str | Path,
    shader_root: str | Path | None = None,
    defines: Mapping[str, object] | None = None,
) -> str:
    """Flatten *source*, resolving absolute shader-pack includes.

    ``source`` may be a path or source text.  A path is resolved relative to
    ``shader_root`` (or the parent of ``source``'s ``shaders`` directory).
    Define overrides replace the value on matching ``#define`` lines before
    GLSL parses the source.
    """
    overrides = {str(k): str(v) for k, v in (defines or {}).items()}
    source_path = Path(source)
    if source_path.exists():
        source_path = source_path.resolve()
        root = Path(shader_root).resolve() if shader_root else _find_root(source_path)
        return _expand(source_path, root, overrides, [])
    if shader_root is None:
        raise ValueError("shader_root is required when source is source text")
    return _expand_text(str(source), Path(shader_root).resolve(), overrides, [], "<source>")


def preprocess_file(
    path: str | Path,
    shader_root: str | Path | None = None,
    defines: Mapping[str, object] | None = None,
) -> str:
    """Flatten a shader source file."""
    return preprocess(path, shader_root=shader_root, defines=defines)


def _find_root(path: Path) -> Path:
    for parent in (path.parent, *path.parents):
        if parent.name == "shaders":
            return parent
    raise ValueError(f"cannot infer shaders root for {path}")


def _expand(path: Path, root: Path, overrides: Mapping[str, str], stack: list[Path]) -> str:
    path = path.resolve()
    if path in stack:
        chain = " -> ".join(str(p) for p in (*stack, path))
        raise IncludeCycleError(f"include cycle: {chain}")
    try:
        text = path.read_text()
    except OSError as exc:
        raise FileNotFoundError(f"unable to read shader include {path}") from exc
    return _expand_text(text, root, overrides, [*stack, path], str(path))


def _expand_text(
    text: str,
    root: Path,
    overrides: Mapping[str, str],
    stack: list[Path],
    source_name: str,
) -> str:
    output: list[str] = []
    for line in text.splitlines(keepends=True):
        match = _INCLUDE.match(line.rstrip("\r\n"))
        if match:
            include_path = (root / match.group(2).lstrip("/")).resolve()
            try:
                include_path.relative_to(root)
            except ValueError as exc:
                raise ValueError(f"include escapes shader root: {match.group(2)}") from exc
            output.append(_expand(include_path, root, overrides, stack))
            continue
        define = _DEFINE.match(line.rstrip("\r\n"))
        if define and define.group(2) in overrides:
            newline = line[len(line.rstrip("\r\n")) :]
            output.append(f"{define.group(1)}{define.group(2)}{define.group(3)}{overrides[define.group(2)]}{define.group(5)}{newline}")
        else:
            output.append(line)
    return "".join(output)


__all__ = ["IncludeCycleError", "preprocess", "preprocess_file"]
