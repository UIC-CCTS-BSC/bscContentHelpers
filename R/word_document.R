#' Word (docx) document output format, with optional themes
#'
#' @param theme Theme to use in styling the output document
#' @param toc Include a table of contents (2 levels deep)?
#' @param number_sections Number sections in document and TOC?
#' @param ... Additional arguments passed to bookdown::word_document2
#'
#' @export
word_document <- function(theme = "plain", toc = TRUE, number_sections = FALSE, ...) {

	# fetch the stylesheet
	refdoc = bscContentHelpers::find_theme_doc(theme, "docx")

	# call the base word_document function
	bookdown::word_document2(
		toc             = toc,
		number_sections = number_sections,
		reference_docx  = refdoc,
		...
	)
}
