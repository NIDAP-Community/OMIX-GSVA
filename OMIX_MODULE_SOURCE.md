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
| Adapter version | Pending — baseline tag not yet established. |
| Adapter release tag | Pending. |
| Platform release | Pending Code Ocean validation and explicit approval. |
| Code Ocean runtime | `codeocean/omix-r-pathway:r4.4.3-bioconductor3.20-v2`; imported environment identity must be confirmed in the capsule. |
| Public runtime identity | `ghcr.io/nidap-community/omix-r-pathway@sha256:25ad9f50df5a4d7f70a7e3debed13f8d5c9b07cbc46d57fdf5c3cf4f2e767ddc` |
| Runtime lockfile | `starter-environments/r-pathway/renv.lock`, SHA-256 `66b0b93e7b1f05dd9429e542c8fdca89b38770667827b53ffca80400b286795c` |
| Pathway data asset | `OMIX MSigDB v2023.2 compatibility bundle v1`, mounted as `/data/msigdb` in the validation capsule. |

The source commit, adapter tag, platform release, runtime identity, and Data
Asset version are separate facts. Pending fields must not be inferred.

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
