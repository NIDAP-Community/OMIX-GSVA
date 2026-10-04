# Changelog

Canonical scientific changes belong in the
[OMIX GSVA module](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSVA).

## Unreleased

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
