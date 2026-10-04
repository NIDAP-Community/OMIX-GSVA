# Canonical OMIX Module Source

## Canonical module

- **Module:** [OMIX GSVA](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSVA)
- **Canonical path:** `modules/OMIX-GSVA/`
- **Canonical module version:** `0.3.0`
- **Canonical interface version:** `2`
- **Canonical release tag:** Pending — baseline tag not yet established.
- **Canonical source reference:** [`5396be0203b94fc1e22cb2eaf74d8265a32466a7`](https://github.com/NIDAP-Community/OMIX/commit/5396be0203b94fc1e22cb2eaf74d8265a32466a7)
- **Interface schema:** [schemas/interface.yml](https://github.com/NIDAP-Community/OMIX/blob/5396be0203b94fc1e22cb2eaf74d8265a32466a7/modules/OMIX-GSVA/schemas/interface.yml)
- **Module contract:** [OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md)

## Adapter release record

| Field | Recorded value |
| --- | --- |
| Adapter version | `0.1.0` |
| Adapter release tag | `v0.1.0`; pending finalization at validated source commit `1508651439504680991eb6ef1ffe38d2cc7d5853` after the post-release evidence review. |
| Platform release | Code Ocean Standard Capsule release `1.0`: [`f60059de-0260-4e49-83a0-b367d99fbd0b/tree/v1`](https://poc-nci.codeocean.io/capsule/f60059de-0260-4e49-83a0-b367d99fbd0b/tree/v1), created 2026-10-04 from source capsule `3631910`. |
| Code Ocean runtime | `codeocean/omix-r-pathway:r4.4.3-bioconductor3.20-v2`, selected and validated in source capsule `3631910`. |
| Public runtime identity | `ghcr.io/nidap-community/omix-r-pathway@sha256:25ad9f50df5a4d7f70a7e3debed13f8d5c9b07cbc46d57fdf5c3cf4f2e767ddc` |
| Runtime lockfile | `starter-environments/r-pathway/renv.lock`, SHA-256 `66b0b93e7b1f05dd9429e542c8fdca89b38770667827b53ffca80400b286795c` |
| Capsule runs | Release-producing `gsva` run `1130403` and post-release `ssgsea` validation run `1139932` in capsule `3631910`, completed successfully on 2026-10-04 from adapter source commit `1508651439504680991eb6ef1ffe38d2cc7d5853`. |
| Pathway data asset | `OMIX MSigDB v2023.2 compatibility bundle v1`, mounted as `/data/msigdb` in the validation capsule. |

The source commit, adapter tag, platform release, runtime identity, and Data
Asset version are separate facts. Pending fields must not be inferred.

## Representative platform validation

Code Ocean source capsule [`3631910`](https://poc-nci.codeocean.io/capsule/3631910/tree)
completed release-producing run `1130403` from adapter source commit
`1508651439504680991eb6ef1ffe38d2cc7d5853`. The run used
`DEG_Analysis.csv` and `Sample_Metadata.csv` from the attached DEG training
asset together with the versioned pathway table
`msigdb_v2023_2_human_mouse_long.tsv` from the attached MSigDB asset. The
adapter independently detected comma delimiters for expression and metadata
and a tab delimiter for the pathway table.

The validation scored 50 `MH: orthology-mapped hallmark gene sets` for Mouse
across samples `A1`, `A2`, `A3`, `B1`, `B2`, `B3`, `C1`, `C2`, and `C3` with
the canonical `gsva` method, minimum gene-set size 15, maximum size 1200, and
gene-symbol updating enabled. The run summary recorded canonical OMIX GSVA
`0.3.0` (interface `2`), canonical source
`5396be0203b94fc1e22cb2eaf74d8265a32466a7`, and the `r-pathway`
`r4.4.3-bioconductor3.20-v2` runtime. The run produced and exposed
`gsva_results.csv`, `gsva_heatmap.png`, and `gsva_run_summary.txt`; these
artifacts were retained in Standard Capsule release
[`1.0`](https://poc-nci.codeocean.io/capsule/f60059de-0260-4e49-83a0-b367d99fbd0b/tree/v1).

Post-release Code Ocean run `1139932` used the same validated adapter source,
inputs, collection, species, sample order, gene-set size limits, and runtime
with the supported alternative `ssgsea` method. It scored the same 50 gene
sets across the same nine samples and produced a populated finite result
matrix, readable 50-by-9 heatmap, and complete run summary. Beacon independently
verified the retained `gsva_results.csv` (9.48 KB), `gsva_heatmap.png`
(344.54 KB), `gsva_run_summary.txt` (713 B), and execution log (942 B).

Together, runs `1130403` and `1139932` establish platform validation for both
the default `gsva` method and the supported `ssgsea` alternative. Final adapter
tagging remains a separate explicit release action tracked in
[OMIX issue #62](https://github.com/NIDAP-Community/OMIX/issues/62).

## Exported scientific files

| Canonical file | Adapter copy | SHA-256 | Purpose |
| --- | --- | --- | --- |
| `modules/OMIX-GSVA/R/GSVA.R` | `code/functions/GSVA.R` | `2ef7ab5d3726a89676ffb6e5e6b1bc42b41c4ef59093d3754252c8035b0fa7ad` | Canonical GSVA implementation. |

The adapter copy is byte-identical to the file at the canonical source
reference above.

## Syncweaver mapping

- **Lockfile:** Pending — production Syncweaver has not generated
  `.syncweaver-lock.json` for this new adapter.
- **Canonical source directory:** `modules/OMIX-GSVA/R/`
- **Adapter destination:** `code/functions/`
- **Last content verification:** Local source-parity test against canonical
  commit `5396be0203b94fc1e22cb2eaf74d8265a32466a7` during the reviewed adapter refresh.
- **Host-side drift:** None at the recorded source reference.

Until Syncweaver onboards this mapping, Harbor may refresh it only by copying
the complete canonical `R/` tree byte-for-byte from a reviewed immutable
source and obtaining Beacon review. No adapter-specific scientific edits are
allowed.

## Adapter translations

- Canonical `output_dir` is platform-managed as `/results` and is intentionally
  hidden from the App Panel.
- The three canonical input paths are optional file selectors in the App
  Panel. A blank selector triggers content-based discovery under `/data` and
  must resolve to exactly one candidate.
- Delimiters are detected independently for each input unless the user supplies
  a shared or input-specific override. A displayed `\\t` value is translated
  to the canonical tab character.
- Boolean App Panel strings are translated to R logical values.
- The adapter reproduces the canonical stable filenames and run summary but
  does not alter scientific defaults.

## Ownership and synchronization

The canonical module owns scientific functions, portable CLI behavior,
schemas, tests, and scientific documentation. This adapter owns Code Ocean UI,
mounted-input discovery, result placement, and runtime selection.

Scientific changes must be made and validated in canonical OMIX first. Beacon
must verify byte parity, interface translation, runtime provenance, and
representative outputs before release. Platform validation, adapter tagging,
and capsule publication remain separate explicit steps.
