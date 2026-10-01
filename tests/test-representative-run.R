#!/usr/bin/env Rscript

required <- c("GSVA", "dplyr", "l2psupp", "stringr", "tibble", "optparse")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Required runtime packages are missing: ", paste(missing, collapse = ", "))
}

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
repo_root <- normalizePath(file.path(dirname(sub("^--file=", "", script_arg)), ".."))
main_file <- file.path(repo_root, "code", "main.R")

test_root <- tempfile("omix-gsva-run-")
data_root <- file.path(test_root, "data")
results_root <- file.path(test_root, "results")
dir.create(file.path(data_root, "workflow"), recursive = TRUE)
dir.create(file.path(data_root, "catalog"), recursive = TRUE)
dir.create(results_root, recursive = TRUE)
on.exit(unlink(test_root, recursive = TRUE), add = TRUE)

set.seed(20261001)
samples <- paste0("S", seq_len(6L))
genes <- paste0("G", seq_len(40L))
expression <- data.frame(
  Gene = genes,
  matrix(stats::rnorm(length(genes) * length(samples), 6, 1),
    nrow = length(genes), dimnames = list(NULL, samples)),
  check.names = FALSE
)
metadata <- data.frame(
  Sample = c("S3", "S1", "S6", "S2", "S5", "S4"),
  Group = c("B", "A", "B", "A", "B", "A")
)
pathways <- rbind(
  data.frame(
    collection = "H: hallmark gene sets",
    gene_set_name = "TEST_SET_A",
    gene_symbol = genes[1:20],
    species = "Human"
  ),
  data.frame(
    collection = "H: hallmark gene sets",
    gene_set_name = "TEST_SET_B",
    gene_symbol = genes[21:40],
    species = "Human"
  )
)

utils::write.table(expression, file.path(data_root, "workflow", "normalized.tsv"), sep = "\t", row.names = FALSE, quote = FALSE)
utils::write.table(metadata, file.path(data_root, "workflow", "metadata.tsv"), sep = "\t", row.names = FALSE, quote = FALSE)
utils::write.table(pathways, file.path(data_root, "catalog", "pathways.tsv"), sep = "\t", row.names = FALSE, quote = FALSE)

status <- system2(
  file.path(R.home("bin"), "Rscript"),
  c(
    "--vanilla", shQuote(main_file),
    "--minimum_geneset_size", "5",
    "--maximum_geneset_size", "100",
    "--update_genes", "false"
  ),
  env = c(
    paste0("OMIX_DATA_ROOT=", shQuote(data_root)),
    paste0("OMIX_RESULTS_ROOT=", shQuote(results_root))
  )
)
stopifnot(identical(status, 0L))

expected <- c("gsva_v1_results.csv", "gsva_v1_heatmap.png", "gsva_run_summary.txt")
paths <- file.path(results_root, expected)
stopifnot(all(file.exists(paths)), all(file.info(paths)$size > 0L))
results <- utils::read.csv(paths[[1L]], check.names = FALSE)
stopifnot(identical(results$Geneset, c("TEST_SET_A", "TEST_SET_B")))
stopifnot(identical(names(results)[-1L], metadata$Sample))
summary_text <- readLines(paths[[3L]], warn = FALSE)
stopifnot(any(grepl("method: gsva", summary_text, fixed = TRUE)))
stopifnot(any(grepl("canonical source: b39dbff7f04ff47b2235a454209a3fb4812e763c", summary_text, fixed = TRUE)))
message("GSVA representative adapter run passed")
