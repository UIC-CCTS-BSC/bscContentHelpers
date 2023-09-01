#' PDF Document
#'
#' @param toc Table of contents?
#' @param toc_depth Numeric. Level of headings included in table of contents
#' @param number_sections Logical. If `TRUE`, sections will be numbered according to heading hierarchy
#' @param ... Additional arguments passed to bookdown::pdf_document2()
#'
#' @export
pdf_document <- function(
		toc             = FALSE,
		toc_depth       = NULL,
		number_sections = FALSE,
		...
		) {

	# path to LaTex preamble
	preamble = bscContentHelpers::pkg_resource(
		"rmd_files/preamble.tex"
	)

	# path to header logo
	logo = bscContentHelpers::pkg_resource(
		"rmd_files/uic_logo_header.png"
	)

	# insert path to header logo into tex
	preamble = gsub(
		"LOGOPATH",
		logo,
		readLines(preamble)
	)

	# write to temp file
	new_preamble = tempfile(fileext = ".tex")
	writeLines(
		preamble,
		new_preamble
	)

	bookdown::pdf_document2(
		toc             = toc,
		toc_depth       = toc_depth,
		number_sections = number_sections,
		latex_engine    = "pdflatex",
		includes        = rmarkdown::includes(
			in_header      = new_preamble
		),
		pandoc_args  = c(
			rmarkdown::pandoc_variable_arg("colorlinks")
		),
		extra_dependencies = c("float"),
		...
	)
}

