#!/usr/bin/env python3
"""Verify the complete canonical R export and its recorded immutable bytes."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = json.loads((ROOT / "tests/source_manifest.json").read_text())


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--canonical-root",
        type=Path,
        help="Optional OMIX checkout containing the recorded canonical commit",
    )
    args = parser.parse_args()

    expected_destinations = {entry["destination"] for entry in MANIFEST["files"]}
    actual_destinations = {
        str(path.relative_to(ROOT))
        for path in (ROOT / "code/functions").glob("*.R")
    }
    assert actual_destinations == expected_destinations, (
        "Managed scientific tree differs from the recorded complete mapping: "
        f"expected={sorted(expected_destinations)} actual={sorted(actual_destinations)}"
    )

    for entry in MANIFEST["files"]:
        adapter_bytes = (ROOT / entry["destination"]).read_bytes()
        assert digest(adapter_bytes) == entry["sha256"], entry["destination"]

        if args.canonical_root:
            canonical_bytes = subprocess.check_output(
                [
                    "git",
                    "-C",
                    str(args.canonical_root),
                    "show",
                    f'{MANIFEST["canonical_commit"]}:{entry["source"]}',
                ]
            )
            assert adapter_bytes == canonical_bytes, (
                f'Byte drift: {entry["source"]} != {entry["destination"]}'
            )

    source_record = (ROOT / "OMIX_MODULE_SOURCE.md").read_text()
    assert MANIFEST["canonical_commit"] in source_record
    for entry in MANIFEST["files"]:
        assert entry["sha256"] in source_record
    print("GSVA scientific source parity passed")


if __name__ == "__main__":
    main()
