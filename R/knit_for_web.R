#' Knit for Web
#'
#' @param input Input file
#' @param ... Additional parameters
#'
#' @export
knit_for_web <- function(input, ...) {

	# set default doc_opts for output
	doc_opts = list(
		title       = tools::file_path_sans_ext(basename(input)),
		author      = "CCTS Biostatistics Core",
		date        = format(Sys.Date(), "%B %d, %Y"),
		include_pdf = TRUE,
		image_dir   = "images"
	)

	# get doc_opts metadata from file and overwrite defaults
	input_yaml = rmarkdown::yaml_front_matter(input)
	doc_opts[names(input_yaml)] = input_yaml

	# if no output_file name was passed, use simplified document title
	if (is.null(doc_opts$output_file) | is.na(doc_opts$output_file)) {
		doc_opts$output_file = gsub("[^a-zA-Z0-9]+", "_", doc_opts$title)
	}

	# if no output_dir was passed, use simplified document title
	if (is.null(doc_opts$output_dir)) {
		doc_opts$output_dir = tolower(doc_opts$output_file)
		}

	# copy entire document directory to new location
	file.copy(
		dirname(input),
		doc_opts$output_dir,
		recursive = TRUE
	)


	# create attachment directory if needed
	doc_opts$attach_dir = file.path(doc_opts$output_dir, "files")
	if(!dir.exists(doc_opts$attach_dir)) {dir.create()}

	# copy attachments (explicitly named) to attach_dir
	if (!is.null(doc_opts$attachments)) {
		purrr::walk(
			doc_opts$attachments, ~{
				file.copy(
					.x,
					file.path(doc_opts$attach_dir, basename(.x))
				)
			}
		)
	}

	# create a pdf version in a attach_dir
	if(doc_opts$include_pdf) {
		rmarkdown::render(
			input,
			output_format = "bscContentHelpers::pdf_document",
			output_file   = doc_opts$output_file,
			output_dir    = doc_opts$attach_dir
		)
		# add to list of attachments
		doc_opts$attachments = c(
			doc_opts$attachments,
			paste0(doc_opts$output_file, ".pdf")
		)
	}

	# rename the target Rmd file
	outfile = file.path(doc_opts$output_dir, "_index.Rmd")
	file.rename(
		file.path(doc_opts$output_dir, basename(input)),
		outfile
	)

	# add snippet to end of output file input and save to a temp file
	writeLines(
		c(
			readLines(outfile),
			"\n",
			"```{r, results='asis', echo = FALSE}",
			"cat(c('Attachments',	bscContentHelpers::create_attachment_links()), sep = '\n')",
			"```",
			"\n"
			),
			outfile
		)

	# clean up the metadata of the output file
	# see https://bookdown.org/yihui/blogdown/from-jekyll.html#from-jekyll
	blogdown:::modify_yaml(
		outfile,
		.keep_fields = c(
			'title', 'author', 'date', 'categories', 'tags', 'slug'
		),
		.keep_empty = FALSE
		)
}


#' Create markdown links to a list of files in a directory
#'
#' @param source_dir Where are the files located?
#' @param target_dir Where should references point? (probably the same as `source_dir`)
#' @param pattern Regex search string. Defaults to NULL (returns everything).
#' @param exclude Specific files to exclude from the list. Only basenames are compared.
#'
#' @return Vector of strings, suitable to be inserted into text as a bulleted list
#' @export
create_attachment_links <- function(
		source_dir   = "files",
		target_dir   = source_dir,
		pattern      = NULL,
		exclude      = NULL
		) {

	# get list of files in source directory, minus any exclusions
	files = basename(list.files(source_dir, pattern = pattern))
	if(!is.null(exclude)) {files = setdiff(files, basename(exclude))}

	# return references in a named list
	c(
		section_head,
		"\n",
		sprintf(
			"* [%s](%s)",
			files,
			file.path(target_dir, files)
		)
	)
}
