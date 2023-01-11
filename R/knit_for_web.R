#' Knit for Web
#'
#' @param input Input file
#' @param ... Additional parameters
#'
#' @export
knit_for_web <- function(input, ...) {

	# set default f_opts for output
	f_opts = list(
		title        = tools::file_path_sans_ext(basename(input)),
		output_dir   = file.path(dirname(input), "output"),
		output_file  = NA,
		author       = "CCTS Biostatistics Core",
		date         = format(Sys.Date(), "%B %d, %Y"),
		include_pdf  = TRUE,
		image_dir    = "images",
		attach_dir   = "files",
		clean        = TRUE,
		section      = FALSE
	)

	# get f_opts metadata from file and overwrite defaults
	input_yaml = rmarkdown::yaml_front_matter(input)
	f_opts[names(input_yaml)] = input_yaml

	# bundle name will be first non-missing of
	# output_file, title, input file name
	f_opts$bundle_dir = tools::file_path_sans_ext(basename(
		dplyr::coalesce(
			f_opts$output_file,
			f_opts$title
			)
		))

	# make (safe) file path from
	# output_dir/bundle_dir
	f_opts$bundle_dir = file.path(
		f_opts$output_dir,
		tolower(gsub("[^a-zA-Z0-9]+","_", f_opts$bundle_dir))
		)

	# delete old output?
	if (f_opts$clean) {unlink(f_opts$bundle_dir, recursive = TRUE)}

	# create bundle location and subfolders
	# mirroring structure of source
	for (d in file.path(
		f_opts$bundle_dir,
		list.dirs(dirname(input), recursive = TRUE, full.names = FALSE)
		)) {
		if(!dir.exists(d)) {dir.create(d, recursive = TRUE)}
	}

	# copy over all files
	for (f in list.files(
		dirname(input),
		recursive    = TRUE,
		full.names   = FALSE,
		include.dirs = FALSE
		)) {
		file.copy(
			file.path(dirname(input), f),
			file.path(f_opts$bundle_dir, f),
			overwrite = TRUE
			)
		}

	# ATTACHMENTS
	# define location
	f_opts$attach_dir = file.path(
		f_opts$bundle_dir,
		basename(f_opts$attach_dir)
		)

	# create a pdf version in a attach_dir
	if(f_opts$include_pdf) {

		if(!dir.exists(f_opts$attach_dir)) {dir.create(f_opts$attach_dir)}
		rmarkdown::render(
			input,
			output_format = "bscContentHelpers::pdf_document",
			output_file   = f_opts$output_file,
			output_dir    = f_opts$attach_dir
		)
	}



	# MODIFY RMD DOCUMENT
		# rename the target Rmd file
	if(f_opts$section) {
		pagename = "_index.Rmd"
	} else {
		pagename = "index.Rmd"
	}

	outfile = file.path(f_opts$bundle_dir, pagename)
	file.rename(
		file.path(f_opts$bundle_dir, basename(input)),
		outfile
	)

	# add comment to top of file

	# <!-- this was  -->
	# find close of yaml header block
	#
	# t = readlines(outfile)
	# setdiff(grep("---", t), 1)


	# add references block
	if(!is.null(f_opts$bibliography)) {
		writeLines(
			c(
				readLines(outfile),
				"",
				"# References",
				"::: {#refs}",
				":::",
				""
				),
			outfile
			)
	}

	# if there are attachments and the text isn't already in the output file
	# add snippet to end of output file

	in_text = readLines(outfile)

	if(
		length(list.files(f_opts$attach_dir))>0 &
		length(grep("create_attachment_links", in_text))==0
		) {
		writeLines(
			c(
				in_text,
				"\n",
				"```{r, results='asis', echo = FALSE, eval=knitr::is_html_output()}",
				sprintf(
					"cat(c('# Attachments',	'\\n', bscContentHelpers::create_attachment_links('%s')), sep = '\\n')",
					basename(f_opts$attach_dir)
					),
				"```",
				"\n"
				),
				outfile
		)
		}

	# delete empty subdirectories
	for (d in list.dirs(
		f_opts$bundle_dir,
		recursive  = TRUE,
		full.names = TRUE
		)) {
			if(length(list.files(d)) == 0) {unlink(d, recursive = TRUE)}
		}


	# # clean up the metadata of the output file
	# # see https://bookdown.org/yihui/blogdown/from-jekyll.html#from-jekyll
	blogdown:::modify_yaml(
		outfile,
		.keep_fields = c(
			'author',
			'date',
			'title',
			'weight',
			'categories',
			'tags',
			'slug',
			'type',
			'draft',
			'publishdate',
			'bibliography',
			grep("(?i)geekdoc",names(f_opts), value = TRUE)
			),
		.keep_empty = FALSE
		)
}


#' Create markdown links to a list of files in a directory
#'
#' @param source_dir Where are the files located? (Relative to file being knit)
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

	# return attachments in a formatted list
	sprintf(
		"* [%s](%s)",
		files,
		file.path(target_dir, files)
		)
}
