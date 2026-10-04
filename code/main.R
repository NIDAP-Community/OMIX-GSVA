#!/usr/bin/env Rscript

# Thin Code Ocean entry point for canonical OMIX GSVA.
# Input discovery and platform translation live in code/adapter/. The
# scientific implementation is sourced unchanged from code/functions/.

suppressPackageStartupMessages(library(optparse))

script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_dir <- if (length(script_argument) == 1L) {
  dirname(normalizePath(sub("^--file=", "", script_argument), mustWork = TRUE))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}
source(file.path(script_dir, "adapter", "GSVA_Adapter.R"))
source(file.path(script_dir, "functions", "GSVA.R"))

option_list <- list(
  make_option("--normalized_data", type = "character", default = "", help = "Normalized expression CSV, TSV, or TXT; blank discovers one candidate under /data"),
  make_option("--sample_metadata", type = "character", default = "", help = "Sample metadata CSV, TSV, or TXT; blank discovers one candidate under /data"),
  make_option("--pathways_database", type = "character", default = "", help = "Long pathway membership CSV, TSV, or TXT; blank discovers one candidate under /data"),
  make_option("--gene_column", type = "character", default = "Gene"),
  make_option("--sample_name_column", type = "character", default = "Sample"),
  make_option("--samples_to_include", type = "character", default = "", help = "Optional comma-separated sample IDs"),
  make_option("--species", type = "character", default = "Human"),
  make_option("--database_species", type = "character", default = "Human"),
  make_option("--collections_to_include", type = "character", default = "H: hallmark gene sets", help = "Comma-separated exact collection names"),
  make_option("--custom_pathways_database", type = "character", default = "false", help = "true or false"),
  make_option("--custom_species", type = "character", default = "Mouse"),
  make_option("--method", type = "character", default = "gsva", help = "gsva, ssgsea, zscore, or plage"),
  make_option("--minimum_geneset_size", type = "integer", default = 15L),
  make_option("--maximum_geneset_size", type = "integer", default = 1200L),
  make_option("--update_genes", type = "character", default = "true", help = "true or false"),
  make_option("--display_warnings", type = "integer", default = -1L),
  make_option("--input_delim", type = "character", default = "auto", help = "Shared fallback delimiter or auto detection"),
  make_option("--normalized_data_delim", type = "character", default = "", help = "Optional normalized-expression delimiter override"),
  make_option("--sample_metadata_delim", type = "character", default = "", help = "Optional sample-metadata delimiter override"),
  make_option("--pathways_database_delim", type = "character", default = "", help = "Optional pathway-database delimiter override"),
  make_option("--image_width", type = "double", default = 12),
  make_option("--image_height", type = "double", default = 10)
)

opt <- parse_args(
  OptionParser(
    usage = "Usage: %prog [input selectors] [options]",
    option_list = option_list,
    description = "Code Ocean adapter for canonical OMIX GSVA"
  ),
  args = gsva_filter_blank_cli_args(commandArgs(trailingOnly = TRUE))
)

resolved <- resolve_gsva_inputs(
  normalized_data = opt$normalized_data,
  sample_metadata = opt$sample_metadata,
  pathways_database = opt$pathways_database,
  gene_column = opt$gene_column,
  sample_name_column = opt$sample_name_column,
  input_delim = opt$input_delim,
  normalized_data_delim = opt$normalized_data_delim,
  sample_metadata_delim = opt$sample_metadata_delim,
  pathways_database_delim = opt$pathways_database_delim,
  data_root = Sys.getenv("OMIX_DATA_ROOT", unset = "/data")
)

normalized_preview <- utils::read.delim(
  resolved$normalized_data,
  sep = resolved$normalized_data_delim,
  check.names = FALSE,
  stringsAsFactors = FALSE
)
metadata_preview <- utils::read.delim(
  resolved$sample_metadata,
  sep = resolved$sample_metadata_delim,
  check.names = FALSE,
  stringsAsFactors = FALSE
)

if (!opt$gene_column %in% names(normalized_preview)) {
  stop("ERROR: Gene column '", opt$gene_column, "' was not found in normalized expression.")
}
if (!opt$sample_name_column %in% names(metadata_preview)) {
  stop("ERROR: Sample ID column '", opt$sample_name_column, "' was not found in metadata.")
}

samples_to_include <- gsva_split_csv(opt$samples_to_include)
if (length(samples_to_include) == 0L) {
  samples_to_include <- intersect(
    as.character(metadata_preview[[opt$sample_name_column]]),
    names(normalized_preview)
  )
}
if (length(samples_to_include) == 0L) {
  stop("ERROR: No metadata sample IDs occur as columns in normalized expression.")
}
if (anyDuplicated(samples_to_include)) {
  stop("ERROR: samples_to_include must not contain duplicates.")
}

collections_to_include <- gsva_split_csv(opt$collections_to_include)
if (length(collections_to_include) == 0L) {
  stop("ERROR: collections_to_include must name at least one collection.")
}
if (opt$minimum_geneset_size < 1L) {
  stop("ERROR: minimum_geneset_size must be at least 1.")
}
if (opt$maximum_geneset_size < opt$minimum_geneset_size) {
  stop("ERROR: maximum_geneset_size must be greater than or equal to minimum_geneset_size.")
}
if (!is.finite(opt$image_width) || opt$image_width <= 0) {
  stop("ERROR: image_width must be positive.")
}
if (!is.finite(opt$image_height) || opt$image_height <= 0) {
  stop("ERROR: image_height must be positive.")
}

results_dir <- Sys.getenv("OMIX_RESULTS_ROOT", unset = "/results")
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
results_dir <- normalizePath(results_dir, mustWork = TRUE)
results_path <- file.path(results_dir, "gsva_results.csv")
plot_path <- file.path(results_dir, "gsva_heatmap.png")

message("OMIX GSVA Code Ocean adapter")
message("Normalized expression: ", resolved$normalized_data)
message("Sample metadata: ", resolved$sample_metadata)
message("Pathway database: ", resolved$pathways_database)
message("Collections: ", paste(collections_to_include, collapse = ", "))

results <- run_gsva(
  normalized_data_file = resolved$normalized_data,
  sample_metadata_file = resolved$sample_metadata,
  pathways_database_file = resolved$pathways_database,
  gene_column = opt$gene_column,
  sample_name_column = opt$sample_name_column,
  samples_to_include = samples_to_include,
  species = opt$species,
  database_species = opt$database_species,
  collections_to_include = collections_to_include,
  custom_pathways_database = gsva_as_logical(opt$custom_pathways_database, "custom_pathways_database"),
  custom_species = opt$custom_species,
  method = opt$method,
  minimum_geneset_size = opt$minimum_geneset_size,
  maximum_geneset_size = opt$maximum_geneset_size,
  update_genes = gsva_as_logical(opt$update_genes, "update_genes"),
  display_warnings = opt$display_warnings,
  input_delim = resolved$input_delim,
  normalized_data_delim = resolved$normalized_data_delim,
  sample_metadata_delim = resolved$sample_metadata_delim,
  pathways_database_delim = resolved$pathways_database_delim,
  export_results_file = results_path,
  export_plot_file = plot_path,
  export_plot_width = opt$image_width,
  export_plot_height = opt$image_height
)

summary_lines <- c(
  "OMIX GSVA run summary",
  paste("normalized data:", resolved$normalized_data),
  paste("sample metadata:", resolved$sample_metadata),
  paste("pathways database:", resolved$pathways_database),
  paste("normalized data delimiter:", if (identical(resolved$normalized_data_delim, "\t")) "\\t (tab)" else resolved$normalized_data_delim),
  paste("sample metadata delimiter:", if (identical(resolved$sample_metadata_delim, "\t")) "\\t (tab)" else resolved$sample_metadata_delim),
  paste("pathways database delimiter:", if (identical(resolved$pathways_database_delim, "\t")) "\\t (tab)" else resolved$pathways_database_delim),
  paste("samples:", paste(samples_to_include, collapse = ", ")),
  paste("collections:", paste(collections_to_include, collapse = ", ")),
  paste("expression species:", opt$species),
  paste("database species:", opt$database_species),
  paste("method:", tolower(opt$method)),
  paste("minimum gene-set size:", opt$minimum_geneset_size),
  paste("maximum gene-set size:", opt$maximum_geneset_size),
  paste("gene updating:", gsva_as_logical(opt$update_genes, "update_genes")),
  paste("gene sets scored:", nrow(results)),
  "canonical module: OMIX-GSVA 0.3.0 (interface 2)",
  "canonical source: 5396be0203b94fc1e22cb2eaf74d8265a32466a7",
  "runtime profile: r-pathway r4.4.3-bioconductor3.20-v2"
)
writeLines(summary_lines, file.path(results_dir, "gsva_run_summary.txt"))
message("Wrote GSVA results to ", results_dir)
