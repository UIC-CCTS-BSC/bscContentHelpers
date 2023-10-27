#' Copy files from a shared location; optionally overwrite YAML
#'
#' @param old_dir The old location (full path to directory)
#' @param new_dir The new location (full path to directory)
#' @param new_yaml New YAML for the Rmd file. Will overwrite old YAML.
#' @param log (If not NULL) Relative path to log file
#'
#' @return
#' @export
#'
#' @examples
copy_from_shared <- function(
		old_dir,
		new_dir,
		new_yaml = NULL,
		log      = "log.md"
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

	f_msg = glue::glue(
		"\n\n[{Sys.time()}]\nFiles copied from\n{old_dir}\n",
		"to\n{new_dir}:\n",
		"  * {paste(f, collapse = '\n  * ' )}"
	)

	if(!is.null(new_yaml)) {
		rmd_path <- list.files(
			new_dir,
			"Rmd",
			full.names = TRUE
		) |>
			dplyr::first()

		old_text <- rmd_path |> readLines()

		# drop old yaml
		new_text = old_text[(grep("---", old_text)[2] + 1):length(old_text)]

		# add new yaml and write
		c("---", new_yaml, "---", "", new_text, "") |>
			writeLines(con = rmd_path)

		f_msg = c(f_msg, glue::glue("\n\nYAML modified:\n{rmd_path}"))
	}

	if(!is.null(log)) {
		write(c(f_msg), file = file.path(new_dir, log), append = TRUE)
	}

	f_msg
}
