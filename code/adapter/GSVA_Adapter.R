# Code Ocean input and parameter translation for OMIX GSVA.
#
# This file is deployment glue. Scientific behavior lives only in
# code/functions/GSVA_v1.R, exported byte-for-byte from canonical OMIX.

gsva_supported_table <- function(path) {
  tolower(tools::file_ext(path)) %in% c("csv", "tsv", "txt")
}

gsva_normalize_delimiter <- function(value) {
  if (is.null(value) || length(value) == 0L) return("\t")
  value <- as.character(value[[1L]])
  if (value %in% c("\\t", "tab", "TAB")) return("\t")
  if (value %in% c(",", "comma", "COMMA")) return(",")
  if (value %in% c(";", "semicolon", "SEMICOLON")) return(";")
  if (nchar(value) != 1L) {
    stop("ERROR: input_delim must be one character, \\t, tab, comma, or semicolon.")
  }
  value
}

gsva_split_csv <- function(value) {
  if (is.null(value) || length(value) == 0L || !nzchar(trimws(value[[1L]]))) {
    return(character())
  }
  values <- trimws(strsplit(as.character(value[[1L]]), ",", fixed = TRUE)[[1L]])
  values[nzchar(values)]
}

gsva_as_logical <- function(value, argument) {
  normalized <- tolower(trimws(as.character(value[[1L]])))
  if (normalized %in% c("true", "t", "1", "yes")) return(TRUE)
  if (normalized %in% c("false", "f", "0", "no")) return(FALSE)
  stop("ERROR: --", argument, " must be true or false.")
}

gsva_filter_blank_cli_args <- function(args) {
  filtered <- character()
  index <- 1L
  while (index <= length(args)) {
    if (!nzchar(args[[index]])) {
      index <- index + 1L
    } else if (
      index < length(args) &&
        startsWith(args[[index]], "--") &&
        !nzchar(args[[index + 1L]])
    ) {
      index <- index + 2L
    } else {
      filtered <- c(filtered, args[[index]])
      index <- index + 1L
    }
  }
  filtered
}

gsva_read_header <- function(path, delim) {
  tryCatch(
    names(utils::read.delim(
      path,
      sep = delim,
      nrows = 0L,
      check.names = FALSE,
      stringsAsFactors = FALSE
    )),
    error = function(error) character()
  )
}

gsva_data_files <- function(data_root) {
  if (!dir.exists(data_root)) return(character())
  files <- list.files(
    data_root,
    recursive = TRUE,
    full.names = TRUE,
    all.files = FALSE,
    no.. = TRUE
  )
  sort(files[file.exists(files) & !dir.exists(files) & vapply(
    files,
    gsva_supported_table,
    logical(1)
  )])
}

gsva_resolve_explicit_file <- function(value, label, data_root) {
  if (is.null(value) || length(value) == 0L || !nzchar(trimws(value[[1L]]))) {
    return(NULL)
  }
  value <- path.expand(as.character(value[[1L]]))
  if (file.exists(value) && !dir.exists(value)) {
    if (!gsva_supported_table(value)) {
      stop("ERROR: ", label, " must be a CSV, TSV, or TXT file: ", value)
    }
    return(normalizePath(value, mustWork = TRUE))
  }

  exact_name_matches <- gsva_data_files(data_root)
  exact_name_matches <- exact_name_matches[
    basename(exact_name_matches) == basename(value)
  ]
  if (length(exact_name_matches) == 1L) {
    return(normalizePath(exact_name_matches, mustWork = TRUE))
  }
  if (length(exact_name_matches) > 1L) {
    stop(
      "ERROR: ", label, " selector matches multiple files under ", data_root,
      ":\n", paste(exact_name_matches, collapse = "\n")
    )
  }
  stop("ERROR: ", label, " file does not exist: ", value)
}

gsva_find_unique_file <- function(label, files, predicate, headers) {
  matches <- files[vapply(seq_along(files), function(index) {
    predicate(headers[[index]])
  }, logical(1))]

  if (length(matches) == 1L) return(normalizePath(matches, mustWork = TRUE))
  if (length(matches) == 0L) {
    stop(
      "ERROR: No ", label, " was found under /data. Upload it explicitly or ",
      "attach a data asset containing one unambiguous candidate. Visible ",
      "supported files:\n",
      if (length(files)) paste(files, collapse = "\n") else "<none>"
    )
  }
  stop(
    "ERROR: Multiple ", label, " candidates were found under /data. Select ",
    "one explicitly:\n", paste(matches, collapse = "\n")
  )
}

resolve_gsva_inputs <- function(
  normalized_data = NULL,
  sample_metadata = NULL,
  pathways_database = NULL,
  gene_column = "Gene",
  sample_name_column = "Sample",
  input_delim = "\t",
  data_root = "/data"
) {
  delim <- gsva_normalize_delimiter(input_delim)
  files <- gsva_data_files(data_root)
  headers <- lapply(files, gsva_read_header, delim = delim)
  pathway_columns <- c("collection", "gene_set_name", "gene_symbol", "species")
  is_pathway <- function(header) all(pathway_columns %in% header)

  normalized_path <- gsva_resolve_explicit_file(
    normalized_data, "normalized expression table", data_root
  )
  if (is.null(normalized_path)) {
    normalized_path <- gsva_find_unique_file(
      "normalized expression table",
      files,
      function(header) gene_column %in% header && length(header) >= 2L && !is_pathway(header),
      headers
    )
  }

  metadata_path <- gsva_resolve_explicit_file(
    sample_metadata, "sample metadata table", data_root
  )
  if (is.null(metadata_path)) {
    metadata_path <- gsva_find_unique_file(
      "sample metadata table",
      files,
      function(header) sample_name_column %in% header && !is_pathway(header),
      headers
    )
  }

  pathways_path <- gsva_resolve_explicit_file(
    pathways_database, "pathway database table", data_root
  )
  if (is.null(pathways_path)) {
    pathways_path <- gsva_find_unique_file(
      "pathway database table", files, is_pathway, headers
    )
  }

  selected <- c(normalized_path, metadata_path, pathways_path)
  if (anyDuplicated(selected)) {
    stop("ERROR: Expression, metadata, and pathway database must be distinct files.")
  }

  list(
    normalized_data = normalized_path,
    sample_metadata = metadata_path,
    pathways_database = pathways_path,
    input_delim = delim
  )
}
