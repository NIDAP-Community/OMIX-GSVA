# Changelog

Canonical scientific changes belong in the
[OMIX GSVA module](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSVA).

## Unreleased

### Changed

- Documents and regression-tests the workflow handoff from OMIX Limma
  Analysis using `Batch_Corrected_Expression.csv` and
  `Sample_Metadata.csv`. This is adapter input translation only; GSVA
  scientific behavior, defaults, and managed source are unchanged.
- Keeps the MSigDB compatibility bundle attached internally as the default
  pathway database and updates the replaceable workflow-input description to
  use the standard `description` field.

## 0.1.0 - 2026-10-04

### Added

- Mixed CSV/TSV input support through independent delimiter detection and
  optional per-input App Panel overrides from canonical OMIX GSVA `0.3.0`.

- Initial Code Ocean deployment adapter for canonical OMIX GSVA `0.2.0`,
  interface version `2`.
- Byte-identical canonical scientific export under `code/functions/`.
- Unambiguous recursive discovery for normalized expression, sample metadata,
  and pathway membership tables.
- App Panel coverage for every user-settable canonical control.
- Source-parity, App Panel, input-discovery, CLI-contract, and representative
  run tests.
- Pinned OMIX Pathways v2 runtime selection and immutable public-image
  provenance.

### Changed

- Refreshed the complete managed scientific export from merged canonical OMIX
  commit `5396be0203b94fc1e22cb2eaf74d8265a32466a7`.

- Refreshed the complete managed scientific export from merged canonical OMIX
  commit `4b28d1697a8267848b003ac3b285d8a1e4eebef7`.
- Removed legacy template revision names from the managed R filename and public
  result filenames; outputs are now `gsva_results.csv` and `gsva_heatmap.png`.

### Validated

- Code Ocean release-producing run `1130403` exercised the canonical `gsva`
  method against mixed CSV/TSV inputs, scored 50 Mouse orthology-mapped
  Hallmark gene sets across nine samples, and produced all three expected
  result artifacts.
- Standard Capsule release `1.0` was created from source capsule `3631910` at
  `f60059de-0260-4e49-83a0-b367d99fbd0b/tree/v1`.
- Post-release Code Ocean run `1139932` exercised the supported alternative
  `ssgsea` method from the same validated adapter source, scored the same 50
  gene sets across nine samples, and produced a populated result table,
  readable heatmap, complete run summary, and successful execution log.
