#!/usr/bin/env python3
"""Compare the Code Ocean App Panel and adapter CLI with canonical interface 2."""

from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def scalar(value: str):
    value = value.strip()
    if value.startswith('"') and value.endswith('"'):
        return json.loads(value)
    if value in {"true", "false"}:
        return value == "true"
    if re.fullmatch(r"-?\d+", value):
        return int(value)
    if re.fullmatch(r"-?\d+\.\d+", value):
        return float(value)
    return value


def canonical_parameters(schema_path: Path) -> dict[str, dict]:
    result: dict[str, dict] = {}
    section = None
    current = None
    for line in schema_path.read_text().splitlines():
        if line and not line.startswith(" ") and line.endswith(":"):
            section = line[:-1]
            current = None
            continue
        item = re.match(r"^  ([A-Za-z0-9_]+):$", line)
        if section == "parameters" and item:
            current = item.group(1)
            result[current] = {}
            continue
        prop = re.match(r"^    (type|default|allowed):\s*(.*)$", line)
        if section == "parameters" and current and prop:
            key, value = prop.groups()
            if key == "allowed":
                result[current][key] = [part.strip() for part in value[1:-1].split(",")]
            else:
                result[current][key] = scalar(value)
    return result


def normalized(value):
    if value == r"\t":
        return "\t"
    if isinstance(value, str):
        lowered = value.lower()
        if lowered in {"true", "false"}:
            return lowered == "true"
        if re.fullmatch(r"-?\d+", value):
            return int(value)
        if re.fullmatch(r"-?\d+\.\d+", value):
            return float(value)
    return value


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--canonical-schema", required=True, type=Path)
    args = parser.parse_args()

    panel = json.loads((ROOT / ".codeocean/app-panel.json").read_text())
    assert panel["named_parameters"] is True
    panel_params = {item["param_name"]: item for item in panel["parameters"]}
    assert len(panel_params) == len(panel["parameters"]), "Duplicate param_name"

    canonical = canonical_parameters(args.canonical_schema)
    visible_canonical = set(canonical) - {"output_dir"}
    input_params = {"normalized_data", "sample_metadata", "pathways_database"}
    assert set(panel_params) == visible_canonical | input_params
    assert "output_dir" not in panel_params

    for name in input_params:
        assert panel_params[name]["type"] == "file"

    for name in visible_canonical:
        expected = canonical[name]
        actual = panel_params[name]
        assert "default_value" in actual, f"Missing App Panel default for {name}"
        left = normalized(actual["default_value"])
        right = normalized(expected["default"])
        if isinstance(left, float) or isinstance(right, float):
            assert math.isclose(float(left), float(right)), (name, left, right)
        else:
            assert left == right, (name, left, right)
        if "allowed" in expected:
            assert actual.get("extra_data") == expected["allowed"], name

    cli_text = (ROOT / "code/main.R").read_text()
    cli_options = set(re.findall(r'make_option\("--([A-Za-z0-9_]+)"', cli_text))
    assert cli_options == set(panel_params), (
        f"CLI/App Panel mismatch: cli={sorted(cli_options)} panel={sorted(panel_params)}"
    )

    results = {item["file_name"] for item in panel["results"]}
    assert results == {
        "gsva_results.csv",
        "gsva_heatmap.png",
        "gsva_run_summary.txt",
    }
    print("GSVA App Panel and CLI contract passed")


if __name__ == "__main__":
    main()
