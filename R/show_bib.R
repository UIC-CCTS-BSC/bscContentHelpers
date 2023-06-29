#' Show the contents of a BibTeX file
#'
#' Return a formatted list of references in a .bib file, probably in
#'   the files/ subdirectory, without citing them.#'
#'
#' @param name The basename of the .bib file
#' @param dir The location of the .bib file. Absolute or relative to
#'   the working directory.
#'
#' @return A formatted list of references. To show in an
#'   RMarkdown document, set the chunk option `results='asis'`.
#' @export
show_bib <- function(name, dir = "files") {
	# make the file path
	x = file.path(
		dir,
		glue::glue("{name}.bib")
		)

	if(!file.exists(x)) {
		return(glue::glue("File not found: {x}"))
		}

	# read the bib file
	x = RefManageR::ReadBib(x)
	RefManageR::NoCite(x, "*")

	# format and return
	RefManageR::PrintBibliography(
		x,
		.opts = list(
			bib.style   = "authoryear",
			first.inits = FALSE,
			sorting     = "nyt"
		)
	)
}
