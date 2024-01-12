# functions:
# read a fragment or md or Rmd file
# save as a modified Rmd:
	# modify the yaml and post-yaml frontmatter to standard text
	# replace image markdown with knitr::include_graphics
# knit to pdf


#' Return only the content of a markdown file, sans YAML
#'
#' @param x A file path
#'
#' @return A vector of strings without yaml header
#' @export

unyaml_file <- function(file) {
	x = readLines(file)

	dashes = grep("---", x)
	if(length(dashes) != 2) {return(x)}

	x[(dashes[2] + 1):length(x)]
}

coalesce_lists <- function(x, y) {
	unique_names = unique(c(names(x), names(y)))

	purrr::map(
		purrr::set_names(unique_names), ~{
			dplyr::coalesce(x[[.x]], y[[.x]])
			}
		)
}

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
#' @param input The source Rmd file (full path)
#' @param new_dir The new location (full path to directory)
#' @param default_yaml Default YAML values for the Rmd file. A named list. Will be overwritten by file's YAML
#' @param pre_content Content to insert after the YAML header and before the content
#'
#' @return NULL
#' @export
create_temp_bundle <- function(
		input,
		default_yaml  = here::here("inst/rmd_files/web_defaults.yml"),
		pre_content   = c(
			here::here("inst/rmd_files/web_opts_chunk.Rmd"),
			here::here("inst/rmd_files/web_page_toc.Rmd")
			),
		post_content  = c(
			here::here("inst/rmd_files/web_reference_block.Rmd")
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
			post_content  = here::here("inst/rmd_files/web_attachment_block.Rmd")
			) |>
			writeLines(temp_rmd)
	}

	# return path to temp dir
	temp_dir
}

# create_temp_bundle(
# 	input = "C:/Users/rlane7/Documents/Packages/_Temp/test_doc/test_doc.Rmd"
# ) |>
# 	list.files(recursive = TRUE)
#


#' Knit for Web
#'
#' @param input Input file
#' @param ... Additional parameters
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


knit_for_web(
	input = "C:/Users/rlane7/Documents/Packages/_Temp/test_doc/test_doc.Rmd",
	target_dir = "C:/Users/rlane7/Documents/Packages/_Temp/webpage"
)


