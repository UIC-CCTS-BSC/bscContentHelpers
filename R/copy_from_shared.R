#' Copy files from a shared location; optionally overwrite YAML
#'
#' @param old_dir The old location (full path to directory)
#' @param new_dir The new location (full path to directory)
#' @param new_yaml New YAML for the Rmd file. A named list. Will modify existing YAML
#' @param pre_content Content to insert afler the YAML header and before the content
#'
#' @return NULL
#' @export
copy_from_shared <- function(
		old_dir,
		new_dir,
		new_yaml     = NULL,
		pre_content  = c(default_opts_chunk(), geekdoc_toc())
		) {

	if(!dir.exists(new_dir)) {dir.create(new_dir)}

	f = list.files(old_dir) |>
		purrr::keep(~!grepl("html$", .x)) |>
		purrr::keep(~!grepl("output", .x))

	f |>
		purrr::walk(~{
			file.copy(
				file.path(old_dir, .x),
				new_dir,
				recursive = TRUE,
				overwrite = TRUE
			)
		})

	# identify primary Rmd file
	rmd_path <- list.files(new_dir, "Rmd", full.names = TRUE) |>
		dplyr::first()

	# read old content
	rmd_path |>
		readLines() |>

		# modify yaml and other pre-content
		strip_yaml() |>
		prepend_c(
			"---",
			update_yaml(rmd_path, new_yaml),
			"---",
			pre_content
			) |>

		# write with new frontmatter
		writeLines(con = rmd_path)
}

#' Return the default chunk options for a BSC doc
#'
#' @return A vector of strings
default_opts_chunk <- function() {
	c(
		'',
		'```{r setup, include=FALSE}',
		'knitr::opts_chunk$set(',
		'  echo      = FALSE, ',
		'  eval      = TRUE, ',
		'',
		'  # output settings for PDFs',
		'  fig.pos   = "H", ',
		'  out.extra = "", ',
		"  fig.show  = 'hold', ",
		"  fig.align = 'center'",
		")",
		'',
		'# image settings for html and pdf',
		'# [only applies to images inserted with knitr::include_graphics()]',
		'',
		'if(knitr::is_html_output()) {',
		'  knitr::opts_chunk$set(dpi = 72)',
		'} else if(knitr::is_latex_output()) {',
		'  knitr::opts_chunk$set(out.width = "100%")',
		'}',
		'```',
		''
	)
}

#' Return a chunk that contains a geekdoc TOC
#'
#' @return A vector of strings
geekdoc_toc <- function() {
	c(
	'',
	'```{r, eval=knitr::is_html_output()}',
	'# insert a page TOC at the top of the page',
	'blogdown::shortcode_html("toc")',
	'```',
	''
	)
}

#' Update Existing YAML
#'
#' @param file A file with a YAML header
#' @param new_yaml Fields to add or overwrite
#'
#' @return A string with new YAML values
#' @export
update_yaml <- function(file, new_yaml = NULL) {
	old_yaml = rmarkdown::yaml_front_matter(file)
	if(!is.null(new_yaml)) {
		old_yaml[names(new_yaml)] <- unlist(new_yaml)
		}
		new_yaml = old_yaml
		yaml::as.yaml(new_yaml)
}

#' Return only the content of a markdown file, sans YAML
#'
#' @param x A vector of strings (probably from readLines)
#'
#' @return The vector without any text between '---' delimiters
#' @export
strip_yaml <- function(x) {
	dashes = grep("---", x)
	if(length(dashes) != 2) {return("YAML header could not be parsed.")}
	x[(dashes[2] + 1):length(x)]
}


#' Utility function to prepend items in a vector through the pipe
#'
#' @param x A value or vector
#' @param ... Values to add to the beginning of the vector
#'
#' @return A vector
#' @export
prepend_c <- function(x, ...) {
	c(..., x)
}

