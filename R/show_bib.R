#' Show the contents of a BibTeX file
#'
#' Return a formatted list of references in a .bib file, probably in
#'   the files/ subdirectory, without citing them.#'
#'
#' @param name The basename of the .bib file
#' @param dir The location of the .bib file. Absolute or relative to
#'   the working directory.
#' @param html Should the output be made html-safe?
#'
#' @return A formatted list of references. To show in an
#'   RMarkdown document, set the chunk option `results='asis'`.
#' @export
show_bib <- function(
		name,
		dir  = "files",
		html = knitr::is_html_output()
		) {
	# make the file path
	x = file.path(
		dir,
		glue::glue("{name}.bib")
		)

	if(!file.exists(x)) {
		return(glue::glue("File not found: {x}"))
		}

	# make math symbols html-safe
	if(html) {
		t = tempfile(fileext = ".bib")

		readLines(x) |>
			latex_to_katex() |>
			writeLines(con = t)

		x = t
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


#' LaTeX to KaTeX
#'
#' @param text A string or vector of strings
#'
#' @return A string or vector of strings with html-safe math symbols
#' @export
latex_to_katex <- function(text) {
	gsub(
		"\\{\\$([^\\$]*)\\$\\}",
		# " `r blogdown::shortcode_html('katex', .content = '\\1')` ",
		"\\1",
		text
	)
}
