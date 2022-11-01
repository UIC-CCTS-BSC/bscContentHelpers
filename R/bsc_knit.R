#' Define custom knit behavior
#'
#' @param input The document to knit
#' @param ... Additional arguments
#'
#' @export
bsc_knit <- function(input, ...) {

	# set default render arguments
	yaml = list(
		output_file   = NULL,
		output_dir    = "output",
		dated_file    = FALSE,
		file_date     = Sys.Date(),
		output        = "bscContentHelpers::pdf_document"
	)

	# get custom metadata from file
	custom = rmarkdown::yaml_front_matter(input)

	# replace defaults with custom
	yaml[names(custom)] <- custom

	# if no output_file name was passed, use simplified document title
	if (is.null(yaml$output_file)) {
		yaml$output_file = gsub("[^a-zA-Z0-9]+", "_", yaml$title)
	}

	# if requested, add date to file name
	if (yaml$dated_file) {
		yaml$output_file = paste0(
			c(
				yaml$output_file,
				format(as.Date(yaml$file_date, "%Y_%m_%d"))
			),
			collapse = "_"
		)
	}

	# knit the file to each format with the new file name/location
	purrr::walk(names(yaml$output), ~{
		rmarkdown::render(
			input,
			output_format = .x,
			output_file   = yaml$output_file,
			output_dir    = yaml$output_dir,
			envir         = globalenv()
		)
	})
}
