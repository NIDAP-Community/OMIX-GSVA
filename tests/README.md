# Adapter validation

- `test-source-parity.py` verifies the complete byte-identical canonical R
  export and recorded checksums.
- `test-app-panel.py` compares canonical parameters with the adapter CLI and
  App Panel, including defaults and method choices.
- `test-adapter-inputs.R` tests recursive discovery, explicit selection, and
  ambiguity failure without running the scientific method.
- `test-representative-run.R` executes the deployment entry point with three
  synthetic attached inputs and inspects all stable outputs.

These local checks do not replace the required Code Ocean runs with the
approved pathway Data Asset.
