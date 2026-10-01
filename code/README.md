# Code Ocean adapter code

- `main.R` parses named App Panel parameters, resolves mounted inputs, writes
  stable files under `/results`, and calls the canonical function.
- `adapter/GSVA_Adapter.R` contains only platform input and value translation.
- `functions/GSVA_v1.R` is the byte-identical canonical scientific export.
- `run` is the Code Ocean launcher.

Do not edit `code/functions/` directly. Scientific changes belong in the
canonical OMIX module and must return here through reviewed synchronization.
