# functions:
# read a fragment or md or Rmd file
# save as a modified Rmd:
	# modify the yaml and post-yaml frontmatter to standard text
	# replace image markdown with knitr::include_graphics
# knit to pdf



infile       <- "C:/Users/rlane7/Documents/Packages/_Temp/test_doc/test_doc.Rmd"
outdir       <- "C:/Users/rlane7/Documents/Packages/_Temp/bundle"
before       <- "This text goes up top."
after        <- "This text goes at the bottom."
default_yaml <- "C:/Users/rlane7/Documents/Packages/_Temp/web.yaml"

# parse input
indir                <- dirname(infile)
intxt                <- readLines(infile)
indash               <- grep("---", intxt)
inyml                <- yaml::yaml.load(intxt[(indash[1]+1):(indash[2]-1)])
intxt                <- intxt[indash[2]+1:length(intxt)]
outyml               <- yaml::yaml.load(readLines(default_yaml))
outyml[names(inyml)] <- inyml



# make a temp location
tmpdir <- tempdir()
list.files(tmpdir,)
# copy over supporting files and images

c("images", "files") |>
	purrr::map(~{

		if(!file.exists(file.path(indir, .x))) {return(NULL)}

		list.dirs(file.path(indir, .x), recursive = TRUE) |>
			purrr::walk(dir.)

		dir.create(file.path(tmpdir, .x))

		file.path(
			.x,
			list.files(file.path(indir, .x), recursive = TRUE, full.names = FALSE)
			)
		}) |>
	unlist() |>
	purrr::walk(~{
		file.copy(
			file.path(indir, .x),
			file.path(tmpdir, .x),
			recursive = TRUE
			)
		})



list.files(file.path(indir, "images"), recursive = TRUE)

list.files(indir, full.names = FALSE) |>
	intersect(c("images", "files")) |>
	c(list.files(indir, pattern = "bib$")) |>
	purrr::walk(~{
		file.copy(
			file.path(indir, .x),
			file.path(tmpdir, .x),
			recursive = TRUE
		)})


c(
	"---",
	yaml::as.yaml(outyml),
	"---\n",
	before,
	intxt,
	after
)






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
		section      = FALSE,
		bib_head     = "## References"
	)

	# get f_opts metadata from file and overwrite defaults
	input_yaml = rmarkdown::yaml_front_matter(input)
	f_opts[names(input_yaml)] = input_yaml

	# bundle name will be first non-missing of
	# output_file, title, input file name
	f_opts$output_file = tools::file_path_sans_ext(basename(
		dplyr::coalesce(
			f_opts$output_file,
			f_opts$title
		)
	))

	# make safe output_file name
	f_opts$output_file = tolower(gsub(
		"[^a-zA-Z0-9]+",
		"_",
		f_opts$output_file
	))

	# make (safe) file path from
	# output_dir/bundle_dir
	f_opts$bundle_dir = file.path(
		f_opts$output_dir,
		f_opts$output_file
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
		include.dirs = FALSE # no empty folders
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
				f_opts$bib_head,
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
					"cat(c('## Attachments',	'\\n', bscContentHelpers::create_attachment_links('%s')), sep = '\\n')",
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
			'nocite',
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

#' Copy output from one location to another (intended to pipe locally from bscContent to bsc-site)
#'
#' @param bundle_name The name of the page bundle (e.g., "e_consent")
#' @param bundle_path The path to the page bundle WITHOUT the bundle name (e.g., "~/project/output")
#' @param dest_path The path to the destination of the page bundle (e.g., "~/site/section")
#' @param clean Recursively delete everything in "~/site/section/bundle_name" before copying?
#'
#' @return NULL
#' @export
copy_for_web <- function(
		bundle_name,
		bundle_path,
		dest_path,
		clean = TRUE
) {


	if(clean) {
		del_path    = file.path(dest_path, bundle_name)

		confirm_del = utils::askYesNo(
			glue::glue("Do you want to delete everything in {del_path}?"),
			default = FALSE
		)
		if(!confirm_del) {return("Action cancelled.")}

		# delete all files and folders in del_path
		unlink(del_path, recursive = TRUE)
	}

	# copy all directories from a to b
	list.dirs(
		file.path(bundle_path, bundle_name),
		recursive    = TRUE,
		full.names   = FALSE
	) |>
		purrr::walk(~{
			y = file.path(dest_path, bundle_name, .x)
			if(!dir.exists(y)) {dir.create(y)}
		})

	# copy all files from a to b
	list.files(
		file.path(bundle_path, bundle_name),
		recursive    = TRUE,
		include.dirs = TRUE,
		full.names   = FALSE
	) |>
		purrr::walk(~{
			file.copy(
				file.path(bundle_path, bundle_name, .x),
				file.path(dest_path, bundle_name, .x)
			)
		})
}



