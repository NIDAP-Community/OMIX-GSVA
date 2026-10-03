# OMIX GSVA — Code Ocean Deployment Adapter

Calculate sample-level pathway enrichment scores from normalized continuous
gene expression in Code Ocean while using the canonical OMIX GSVA scientific
implementation unchanged.

## Canonical OMIX module

| Item | Location |
| --- | --- |
| Canonical module | [OMIX GSVA](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSVA) |
| Interface contract | [schemas/interface.yml](https://github.com/NIDAP-Community/OMIX/blob/main/modules/OMIX-GSVA/schemas/interface.yml) |
| Development contract | [OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md) |
| Version and source record | [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md) |

The canonical module owns the method, defaults, and reusable interface. This
repository owns only the Code Ocean App Panel, mounted-input discovery,
`/results` placement, and runtime selection.

## What this deployment adds

- Named App Panel controls for every user-settable canonical parameter.
- Recursive, content-based discovery of exactly one normalized-expression
  table, one sample-metadata table, and one pathway-membership table under
  `/data` when uploads are left blank.
- Stable Code Ocean results under `/results`.
- Selection of the imported **OMIX Pathways v2** starter environment.

## Inputs

All three inputs must use the same delimiter and may be CSV, TSV, or TXT.
Supply files explicitly in the App Panel or attach assets containing exactly
one unambiguous candidate for each role.

### Normalized expression

A gene-by-sample table containing the selected gene column (default `Gene`)
and numeric sample columns. Use normalized continuous expression—not raw
integer counts.

### Sample metadata

A table containing one row per sample and the selected sample-ID column
(default `Sample`). Sample IDs must match expression column names.

### Pathway database

A long table with these columns:

- `collection`
- `gene_set_name`
- `gene_symbol`
- `species`

The database is a separately provisioned, immutable Code Ocean Data Asset. It
is not committed to this repository or embedded in the runtime. MSigDB content
may be used only through an appropriately licensed restricted asset.

When a blank selector has no match or more than one match, the adapter stops
and lists the candidate paths. It never chooses among ambiguous files.

## Run the analysis

1. Attach or upload normalized expression, matching sample metadata, and an
   approved pathway database.
2. Confirm the gene and sample ID column names.
3. Select one or more exact pathway collection names.
4. Choose the GSVA method. The canonical default is `gsva`.
5. Run the capsule.

The App Panel defaults preserve the canonical module: Hallmark pathways,
Human expression/database species, minimum set size 15, maximum set size 1200,
and gene-symbol updating enabled.

## Outputs and workflow handoff

| Output | Purpose | Downstream use |
| --- | --- | --- |
| `gsva_results.csv` | Gene-set-by-sample enrichment scores. | Continuous input to OMIX Limma Analysis. |
| `gsva_heatmap.png` | Row-scaled overview heatmap. | Visual review. |
| `gsva_run_summary.txt` | Inputs, selections, method, thresholds, and source provenance. | Reproducibility record. |

## Environment and reproducibility

- **Runtime profile:** `r-pathway`
- **Code Ocean environment:** `codeocean/omix-r-pathway:r4.4.3-bioconductor3.20-v2`
- **Public immutable image:** `ghcr.io/nidap-community/omix-r-pathway@sha256:25ad9f50df5a4d7f70a7e3debed13f8d5c9b07cbc46d57fdf5c3cf4f2e767ddc`
- **Canonical source:** recorded in [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md)

Retain the Code Ocean computation ID, exact adapter commit, pathway Data Asset
version, selected parameters, and released capsule version with every result.

## Troubleshooting and limitations

- Raw counts are not supported. Normalize expression before GSVA.
- All three current canonical inputs share one delimiter setting.
- Collection names are exact and case-sensitive.
- Duplicate gene-set display names across selected collections are unsupported
  by the preserved implementation and should be resolved in the input asset.
- A Code Ocean run is still required before this adapter can be tagged or
  released. Local tests do not establish platform validation.

## For developers

Read [AGENTS.md](AGENTS.md) and
[OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md) before editing.
`code/functions/GSVA.R` is a byte-identical canonical export and must not
be edited in this repository.

## References and support

- Hänzelmann S, Castelo R, Guinney J. *BMC Bioinformatics*. 2013;14:7.
- OMIX support: NCICCBRNIDAP@mail.nih.gov
