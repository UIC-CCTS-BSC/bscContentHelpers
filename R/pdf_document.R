#' PDF Document
#'
#' @param toc Table of contents?
#'
#' @export
pdf_document <- function(toc = TRUE) {

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

	rmarkdown::pdf_document(
		toc          = toc,
		latex_engine = "pdflatex",
		includes     = includes(
			in_header = new_preamble
		)

	)
}

