#!/usr/bin/env Rscript

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
repo_root <- normalizePath(file.path(dirname(sub("^--file=", "", script_arg)), ".."))
source(file.path(repo_root, "code", "adapter", "GSVA_Adapter.R"))

test_root <- tempfile("omix-gsva-inputs-")
dir.create(file.path(test_root, "workflow"), recursive = TRUE)
dir.create(file.path(test_root, "catalog"), recursive = TRUE)
on.exit(unlink(test_root, recursive = TRUE), add = TRUE)

writeLines("Gene\tS1\tS2\nG1\t1\t2", file.path(test_root, "workflow", "normalized.tsv"))
writeLines("Sample\tGroup\nS1\tA\nS2\tB", file.path(test_root, "workflow", "metadata.tsv"))
writeLines(
  "collection\tgene_set_name\tgene_symbol\tspecies\nH: hallmark gene sets\tTEST\tG1\tHuman",
  file.path(test_root, "catalog", "pathways.tsv")
)

resolved <- resolve_gsva_inputs(data_root = test_root)
stopifnot(basename(resolved$normalized_data) == "normalized.tsv")
stopifnot(basename(resolved$sample_metadata) == "metadata.tsv")
stopifnot(basename(resolved$pathways_database) == "pathways.tsv")

writeLines("Gene\tS1\nG1\t3", file.path(test_root, "workflow", "second-expression.tsv"))
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
  normalized_data = file.path(test_root, "workflow", "normalized.tsv"),
  data_root = test_root
)
stopifnot(basename(resolved_explicit$normalized_data) == "normalized.tsv")
stopifnot(identical(gsva_normalize_delimiter("\\t"), "\t"))
stopifnot(identical(gsva_as_logical("true", "test"), TRUE))
message("GSVA adapter input-discovery tests passed")
