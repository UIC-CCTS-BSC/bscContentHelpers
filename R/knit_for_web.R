#' Knit for Web
#'
#' @param input Input file
#' @param ... Additional parameters
#'
#' @export
knit_for_web <- function(input, ...) {

	# get yaml metadata from file
	yaml = rmarkdown::yaml_front_matter(input)

	# default: include pdf version
	if (is.null(yaml$include_pdf)) {yaml$include_pdf = TRUE}

	# if no output_file name was passed, use simplified document title
	if (is.null(yaml$output_file)) {
		output_file = gsub("[^a-zA-Z0-9]+", "_", yaml$title)
	} else {
		output_file = yaml$output_file
	}

	# if no output_dir was passed, use simplified document title
	if (is.null(yaml$output_dir)) {
		output_dir = tolower(output_file)
		} else {
			output_dir = yaml$output_dir
		}
	attachment_dir = file.path(output_dir, "files")

	# create directories as needed
	purrr::walk(list(output_dir, attachment_dir), ~{
		if(!dir.exists(.x)) {dir.create(.x)}
	})

	# copy named files over
	attachments = yaml$attachments
	if (!is.null(attachments)) {
		if(!dir.exists(attachment_dir)) {dir.create(attach)}
		purrr::walk(
			attachments, ~{
				file.copy(
					.x,
					file.path(attachment_dir, basename(.x))
				)
			}
		)
	}

	# create a pdf version in a named folder
	if(yaml$include_pdf) {
		rmarkdown::render(
			input,
			output_format = "bscContentHelpers::pdf_document",
			output_file   = output_file,
			output_dir    = attachment_dir
		)
		# add to list of attachments
		attachments = c(
			attachments,
			paste0(output_file, ".pdf")
		)
	}

	# format links for markdown with relative references...
	attach_list = NULL
	if(length(attachments>0)) {
		attach_list = sprintf(
			"* [%s](%s)",
			basename(attachments),
			file.path("files", basename(attachments))
			)
		attach_list = c("# Attachments", "", attach_list)
	}

	# add snippet to input and save to a temp file
	tmp = tempfile(fileext = ".Rmd", tmpdir = dirname(input))
	writeLines(c(readLines(input), attach_list), tmp)


	# create an html version in a named folder
	rmarkdown::render(
		tmp,
		output_format = "blogdown::html_page",
		output_file   = "_index",
		output_dir    = output_dir
	)

	# delete temp file
	file.remove(tmp)
}
