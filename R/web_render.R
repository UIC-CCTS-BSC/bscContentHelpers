#' Return only the content of a markdown file, sans YAML
#'
#' @param file A path to a file with a YAML header
#'
#' @return A vector of strings without yaml header
#' @export

unyaml_file <- function(file) {
	x = readLines(file)

	dashes = grep("---", x)
	if(length(dashes) != 2) {return(x)}

	x[(dashes[2] + 1):length(x)]
}

#' Coalesce two lists by element name
#'
#' @param x A list. Values will take precedence if names overlap.
#' @param y A list. Values will be overwritten if names overlap.
#'
#' @return A list
#' @export
coalesce_lists <- function(x, y) {
	unique_names = unique(c(names(x), names(y)))

	purrr::map(
		purrr::set_names(unique_names), ~{
			dplyr::coalesce(x[[.x]], y[[.x]])
			}
		)
}

#' Insert YAML values, headers, and footers in an existing Rmd file.
#'
#' @param input A path to a .Rmd file.
#' @param default_yaml A path to a .yml file containing default key-value pairs. Values will be overwritten by matching values in input header.
#' @param pre_content A path to a file containing text to be inserted after the YAML header and before existing input content.
#' @param post_content A path to a file containing text to be inserted after existing input content.
#'
#' @return a vector of strings
#' @export
modify_rmd_contents <- function(
		input,
		default_yaml = NULL,
		pre_content  = NULL,
		post_content = NULL
		) {

	# read old yaml
	rmd_yaml <- rmarkdown::yaml_front_matter(input)

	# update yaml with default values
	if(!is.null(default_yaml)) {
		rmd_yaml = coalesce_lists(
			rmd_yaml,
			yaml::yaml.load(readLines(default_yaml))
		)
	}

	# read old and new content, if relevant
	rmd_content <- c(pre_content, input, post_content) |>
		purrr::compact() |>
		purrr::map(unyaml_file) |>
		unlist()

	# return updated yaml, updated content
	c(
		"---",
		yaml::as.yaml(rmd_yaml),
		"---\n",
		rmd_content,
		"\n"
	)
}

#' Copy the contents of a file from one location to another
#'
#' @param from A directory path
#' @param to A directory path
#'
#' @return NULL
#' @export
copy_dir <- function(from, to) {
	if(!dir.exists(from)) {return(NULL)}
	if(!dir.exists(to)) {dir.create(to)}

	file.copy(
		list.files(from, full.names = TRUE),
		to,
		recursive = TRUE,
		overwrite = TRUE
	)
}


#' Copy files from a shared location; optionally overwrite YAML
#'
#' @param input A path to a .Rmd file.
#' @param default_yaml A path to a .yml file containing default key-value pairs. Values will be overwritten by matching values in input header.
#' @param pre_content A path to a file containing text to be inserted after the YAML header and before existing input content.
#' @param post_content A path to a file containing text to be inserted after existing input content.
#' @param temp_dir A path where the modified page bundle (directory) will be created
#'
#' @return NULL
#' @export
create_temp_bundle <- function(
		input,
		default_yaml  = pkg_resource("rmd_files/web_defaults.yml"),
		pre_content   = c(
			pkg_resource("rmd_files/web_opts_chunk.Rmd"),
			pkg_resource("rmd_files/web_page_toc.Rmd")
			),
		post_content  = c(
			pkg_resource("rmd_files/web_reference_block.Rmd")
			),
		temp_dir = tempdir()
		) {

	# identify source location
	in_dir  <- dirname(input)
	in_yaml <- rmarkdown::yaml_front_matter(input)

	# create (or empty) a temporary directory
	if(!dir.exists(temp_dir)) {dir.create(temp_dir)}
	unlink(file.path(temp_dir, "*"), recursive = TRUE, force = TRUE)

	# copy source subfolders to temporary directory
	purrr::walk(c("images", "files"), ~{
		copy_dir(
			from = file.path(in_dir, .x),
			to   = file.path(temp_dir, .x)
		)
	})

	# define path to new Rmd file
	temp_rmd <- "index.Rmd"
	if(isTRUE(in_yaml$section)) {temp_rmd  <- "_index.Rmd"}
	temp_rmd <- file.path(temp_dir, temp_rmd)

	# copy old Rmd file, possibly modified, to new location
	modify_rmd_contents(
		input,
		default_yaml  = default_yaml,
		pre_content   = pre_content,
		post_content  = post_content
		) |>
		writeLines(temp_rmd)

	# capture new yaml
	temp_yaml <- rmarkdown::yaml_front_matter(temp_rmd)

	# (maybe) create pdf
	if(temp_yaml$include_pdf) {
		rmarkdown::render(
			temp_rmd,
			output_format = "bscContentHelpers::pdf_document",
			output_file   = snakecase::to_snake_case(temp_yaml$title),
			output_dir    = file.path(temp_dir, "files")
		)
	}

	# (maybe) add attachment links
	if(length(list.files(file.path(temp_dir, "files"))>0)) {
		modify_rmd_contents(
			temp_rmd,
			post_content  = pkg_resource("rmd_files/web_attachment_block.Rmd")
			) |>
			writeLines(temp_rmd)
	}

	# return path to temp dir
	temp_dir
}



#' Prepare a Rmd file and supporting files for inclusion in a blogdown project
#'
#' @param input A path to the input file
#' @param target_dir A path to the directory where the page bundle should be located
#' @param ... Additional arguments passed to create_temp_bundle()
#' @param clean Devele everything in target_dir before populating?
#'
#' @export
knit_for_web <- function(
		input,
		target_dir,
		...,
		clean = FALSE
		) {

	# create a bundle
	bundle_dir = create_temp_bundle(input = input, ...)

	# create target location
	if(!dir.exists(target_dir)) {dir.create(target_dir)}
	if(clean){
		unlink(
			file.path(target_dir, "*"),
			recursive = TRUE, force = TRUE)
	}

	# copy bundle to target location
	purrr::walk(c("images", "files"), ~{
		copy_dir(
			file.path(bundle_dir, .x),
			file.path(target_dir, .x)
			)
		})

		list.files(bundle_dir, pattern = "index.Rmd$") |>
			purrr::walk(~{
				file.copy(
					file.path(bundle_dir, .x),
					file.path(target_dir, .x),
					overwrite = TRUE
					)
			})

		target_dir
}
