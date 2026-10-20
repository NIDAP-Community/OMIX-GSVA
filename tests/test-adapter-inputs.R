#!/usr/bin/env Rscript

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
repo_root <- normalizePath(file.path(dirname(sub("^--file=", "", script_arg)), ".."))
source(file.path(repo_root, "code", "functions", "GSVA.R"))
source(file.path(repo_root, "code", "adapter", "GSVA_Adapter.R"))

test_root <- tempfile("omix-gsva-inputs-")
dir.create(file.path(test_root, "workflow"), recursive = TRUE)
dir.create(file.path(test_root, "catalog"), recursive = TRUE)
on.exit(unlink(test_root, recursive = TRUE), add = TRUE)

writeLines("Gene,S1,S2\nG1,1,2", file.path(test_root, "workflow", "normalized.csv"))
writeLines("Sample,Group\nS1,A\nS2,B", file.path(test_root, "workflow", "metadata.csv"))
writeLines(
  "collection\tgene_set_name\tgene_symbol\tspecies\nH: hallmark gene sets\tTEST\tG1\tHuman",
  file.path(test_root, "catalog", "pathways.tsv")
)

resolved <- resolve_gsva_inputs(data_root = test_root)
stopifnot(basename(resolved$normalized_data) == "normalized.csv")
stopifnot(basename(resolved$sample_metadata) == "metadata.csv")
stopifnot(basename(resolved$pathways_database) == "pathways.tsv")
stopifnot(identical(resolved$normalized_data_delim, ","))
stopifnot(identical(resolved$sample_metadata_delim, ","))
stopifnot(identical(resolved$pathways_database_delim, "\t"))

writeLines("Gene,S1\nG1,3", file.path(test_root, "workflow", "second-expression.csv"))
ambiguous <- tryCatch(
  {
    resolve_gsva_inputs(data_root = test_root)
    NULL
  },
  error = identity
)
stopifnot(inherits(ambiguous, "error"))
stopifnot(grepl("Multiple normalized expression table candidates", conditionMessage(ambiguous), fixed = TRUE))

resolved_explicit <- resolve_gsva_inputs(
  normalized_data = file.path(test_root, "workflow", "normalized.csv"),
  data_root = test_root
)
stopifnot(basename(resolved_explicit$normalized_data) == "normalized.csv")

# OMIX Limma Analysis can provide the workflow input bundle through its opt-in
# batch-corrected continuous matrix and paired modeled metadata. The generic
# discovery contract must recognize these stable filenames without a
# deployment-specific scientific parser.
limma_root <- file.path(test_root, "limma-result")
dir.create(limma_root)
writeLines("Gene,S1,S2\nG1,1.1,2.2", file.path(limma_root, "Batch_Corrected_Expression.csv"))
writeLines("Sample,Group\nS1,A\nS2,B", file.path(limma_root, "Sample_Metadata.csv"))
limma_resolved <- resolve_gsva_inputs(
  normalized_data = file.path(limma_root, "Batch_Corrected_Expression.csv"),
  sample_metadata = file.path(limma_root, "Sample_Metadata.csv"),
  pathways_database = file.path(test_root, "catalog", "pathways.tsv"),
  data_root = test_root
)
stopifnot(
  basename(limma_resolved$normalized_data) == "Batch_Corrected_Expression.csv",
  basename(limma_resolved$sample_metadata) == "Sample_Metadata.csv"
)
stopifnot(identical(gsva_normalize_delimiter("\\t"), "\t"))
stopifnot(is.null(gsva_normalize_delimiter("auto")))
stopifnot(identical(gsva_as_logical("true", "test"), TRUE))
message("GSVA adapter input-discovery tests passed")
