
-   <a href="#bsccontenthelpers"
    id="toc-bsccontenthelpers">bscContentHelpers</a>
    -   <a href="#quick-start" id="toc-quick-start">Quick Start</a>
        -   <a href="#install-software-and-r-packages"
            id="toc-install-software-and-r-packages">Install Software and R
            Packages</a>
        -   <a href="#create-a-draft" id="toc-create-a-draft">Create a Draft</a>
        -   <a href="#edit" id="toc-edit">Edit</a>
        -   <a href="#knit" id="toc-knit">Knit</a>
        -   <a href="#for-more-detail" id="toc-for-more-detail">For More Detail…</a>
    -   <a href="#under-the-hood" id="toc-under-the-hood">Under the Hood</a>
        -   <a href="#an-r-markdown-template" id="toc-an-r-markdown-template">An R
            Markdown Template</a>
        -   <a href="#an-output-format" id="toc-an-output-format">An Output
            Format</a>
        -   <a href="#a-knit-function" id="toc-a-knit-function">A Knit Function</a>
    -   <a href="#other-helpful-tips" id="toc-other-helpful-tips">Other Helpful
        Tips</a>
    -   <a href="#enhancing-this-package"
        id="toc-enhancing-this-package">Enhancing This Package</a>
        -   <a href="#create-a-new-template-in-this-package"
            id="toc-create-a-new-template-in-this-package">Create a New Template in
            This Package</a>
        -   <a href="#create-a-new-output-format"
            id="toc-create-a-new-output-format">Create a New Output Format</a>
        -   <a href="#create-a-new-reference-doc"
            id="toc-create-a-new-reference-doc">Create a New Reference Doc</a>
        -   <a href="#create-a-new-knit-function"
            id="toc-create-a-new-knit-function">Create a New Knit Function</a>

<!-- README.md is generated from README.Rmd. Please edit that file -->

# bscContentHelpers

<!-- badges: start -->
<!-- badges: end -->

`bscContentHelpers` provides templates and utilities for creating,
editing, rendering, and storing documents for the UIC CCTS Biostatistics
Core.

## Quick Start

This section walks through the process of creating a draft R Markdown
document from a template, customizing the document, and “knitting” it to
an output format.

### Install Software and R Packages

The primary workflow described here relies on
[R](https://www.r-project.org/) and [RStudio](https://www.rstudio.com/),
so be sure to install those first. Workarounds to RStudio are possible
but probably not worth the hassle. You’ll also want to install the
`devtools` package:

``` r
install.packages("devtools")
```

You can install the development version of `bscContentHelpers` from
[Github](https://github.com/) with:

``` r
devtools::install_github("UIC-CCTS-BSC/bscContentHelpers")
```

Note that this package isn’t on CRAN, so updates won’t be picked up by
running `update.packages()`. However, once it’s installed, you should be
able to run `devtools::update_packages()`.

The current package relies on several underlying packages and software
products (pandoc, `rmarkdown`, `bookdown`, a LaTeX engine). These should
be automatically installed with RStudio and `bscContentHelpers`. If you
run into trouble, you can install manually:

``` r
# install R markdown
install.packages('rmarkdown')

# install the TinyTex LaTeX engine
install.packages('tinytex')
tinytex::install_tinytex()
```

### Create a Draft

This package contains several document templates–that is, boilerplate
outlines for tipsheets, generic articles, slide presentations, and more.
These are in a subfolder called `templates` and can be accessed with the
`rmarkdown::draft()` function.

Currently available templates in this package:

-   article
-   slides

To use the RStudio `New File` add-in to create a document draft,
navigate to `File > New File > R Markdown... > From Template`. Select
one of the templates from the `bscContentHelpers` package (for example,
Article or Slides).

![Create a new doc from a
template.](man/figures/new_doc_from_template.png)

You can also create a new draft by manually calling `rmarkdown::draft()`
with the template and package name as arguments:

``` r
rmarkdown::draft("my_file_name", template = "article", package = "bscContentHelpers")
```

### Edit

Do a little editing of the file you just created, making use of
[markdown syntax](https://rmarkdown.rstudio.com/authoring_basics.html)
and [R code chunks](https://rmarkdown.rstudio.com/lesson-3.html).

You can also edit fields in the YAML header or leave them as is.

### Knit

Convert the .Rmd draft to a formatted HTML document by clicking
RStudio’s `Knit` button or using the `Ctrl + Shift + K` keyboard
shortcut. The document is ready for previewing or sharing.

There are many other output file types (.docx, .pptx, .pdf) and formats
possible. \[See below\] for details.

### For More Detail…

The internet is full of great explanations of what R Markdown is, how to
use it, and how to extend it. Some references:

-   [R Markdown: The Definitive
    Guide](https://bookdown.org/yihui/rmarkdown/)
-   [R Markwod Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/)
-   [The Epidemiologist R
    Handbook](https://epirhandbook.com/en/reports-with-r-markdown.html)

## Under the Hood

The document development and rendering process relies on three files:
[an .Rmd template](#an-r-markdown-template), [an output
format](#an-output-format), and [a knit function](#a-knit-function).

### An R Markdown Template

At its most basic, an .Rmd template is a sample file, written in R
Markdown, that may include standard headers, sample code, or boilerplate
text. An Rmd template defines the content and structure of a document.

Templates defined in this package include:

-   Article. This could be used for a tipsheet or other short article.
-   Slides. This is set up to create a Powerpoint document.

Like all R Markdown documents, templates start with a section called a
YAML header, bordered by three tick marks (`---`). This section defines
the settings of your final document, including metadata (e.g., title,
author, date) and output format and behavior (e.g., Word document with a
certain set of fonts, saved with a specific file name in a specific
location on your computer. Custom templates in this package have some
default settings, so you can probably edit your document’s title,
author, and date information and leave the rest of the settings alone.

The rest of the document is written in R Markdown. Study the boilerplate
text that each template contains; it will give you pointers about how to
craft your own document in R Markdown. Delete the boilerplate text and
add your own.

### An Output Format

Once the content has been developed, one or more output formats can be
applied. In this context, an “output format” is an R function that
defines the file type (e.g., docx or pptx) and the look and feel (e.g.,
colors, fonts) of your final document.

Note that multiple different formats can be applied to the same
template. (This is one of the benefits of using R Markdown!) For
example, you might have an .Rmd report that can be knit as an html draft
during content development. The final version could be knit to a pdf
with custom headers, fonts, and colors. Each format has default
settings, some of which can be customized at the document level.

You will rarely, if ever, execute the function directly. Instead,
include the format namein your draft’s YAML header. To use default
settings, just include the name:

    output: word_document

To declare custom settings (“options”), include those in the header too,
indented by two spaces. For example, to include a table of contents, you
might include:

    output:
      word_document:
        toc: true

There are several [output
formats](https://bookdown.org/yihui/rmarkdown/output-formats.html)
native to the `rmarkdown` package. You can use any of these by including
them in the YAML header. There are also a few custom output formats in
this package; they incorporate components like CCTS or UIC branding
(colors, fonts, logos) and standardized naming conventions. Any
package-specific formats need to have the package name prepended:

    output: 
      bscContentHelpers:word_document:
        toc: false
        theme: teal

Output formats defined in this package:

-   `html_draft`. This can be used while developing content to avoid
    focusing too much on the final aesthetic details. Customization
    options:
    -   `toc`. Include a table of contents at the start of the document?
    -   `theme`. Name of the CSS style to use. Defaults to a plain,
        clean style.
-   `pptx_presentation`
    -   `theme`
-   `word_document`
    -   `theme`
    -   `toc`

TODO: full explanation of available output formats settings and
customizable options

TODO:

-   pdf_document
-   html_webpage (or md_webpage) – for static site
    -   [ ] consider whether this needs a separate knit function

### A Knit Function

A knit function is an R function that controls the behavior of the knit
button; in other words, it determines what steps get taken, and in what
order, to turn the Rmd draft into the pdf (or html or docx or pptx)
document. Like with an output format, you don’t usually execute a knit
function directly. Instead, you include it in a document’s YAML header:

`knit: function_name`

It gets executed when you knit the document by clicking the `knit`
button or typing `Ctrl + Shift + k`.

Currently, this package includes one knit function (`bsc_knit`). This
knit function is declared in all package templates. It allows you to
knit multiple formats at once with some custom options (see below). If
you would prefer to use [R Markdown’s default knitting
behavior](https://bookdown.org/yihui/rmarkdown/compile.html), simply
delete this YAML option.

All arguments passed to the knit function have defaults, but some can be
updated by explicitly setting parameters in the YAML header. These
include:

-   `output_file: NULL`. This sets the output document name (minus the
    file extension). This will be the same for all output formats. If
    not explicitly set, it will default to the document title, minus
    spaces and special characters.
-   `output_dir: NULL`. This sets the location where output documents
    are produced. Defaults to the same directory as the Rmd source. If
    stating explicitly, use a reference relative to the knit location.
-   `dated_file: FALSE`. Append the date to the end of the file name?
-   `file_date: Sys.Date()`. Date to be appended to the end of the file
    name, if applicable. Defaults to today’s date but can be explicitly
    overridden. To avoid errors, pass as a date object.

One Rmd file can be knit to multiple output formats simultaneously. To
allow for this, include all outputs under `output:` in the YAML header.

TODO: More robust explanation of output options TODO: knitting for
website \[html/md (with subfolder code snippet appended) plus pdf\]

## Other Helpful Tips

By default, documents refer to an external bibliography, held in
`references.bib`. Add references in
[BibTeX](https://www.bibtex.com/g/bibtex-format/) format. Reference them
as `[@source]`.

## Enhancing This Package

The sections below explain how to structure new templates, formats, and
more. The instructions don’t go into detail about principles of package
development or version control, but please keep these things in mind!
It’s a good idea to make changes on a development branch and test them
before committing them to the master branch (i.e., the source of the
distributed package). For more about package development, see the [R
Packages book](https://r-pkgs.org/Introduction.html). For more about
GitHub and version control, see the [GitHub
docs](https://docs.github.com).

### Create a New Template in This Package

TODO: expand to a vignette

*See the note above about templates (e.g., “article”) and source
documents (e.g., REDCap Terms of Use). Though these categories of Rmd
files are conceptually different, they’re created, stored, accessed, and
edited in the same way.*

#### Step 0 \[Optional but Recommended\]: Sync and Switch Branches

Sync the remote repository (i.e., the current version of the files on
GitHub) with your local copy. Then create and switch to a new
development branch.

    $ git fetch
    $ git pull
    $ git checkout -b new-working-branch

#### Create the Template

Generate a new Rmd template and supporting structures by calling
`use_rmarkdown_template()`, part of the `usethis` package. A template
should describe a type of document; for example, you might create a
template for an article or for a slide presentation.

``` r
usethis::use_rmarkdown_template("Article")
```

You’ll see some messages in the console:

    ✔ Setting active project to '~/bscContentHelpers'
    ✔ Creating 'inst/rmarkdown/templates/article/skeleton/'
    ✔ Writing 'inst/rmarkdown/templates/article/template.yaml'
    ✔ Writing 'inst/rmarkdown/templates/article/skeleton/skeleton.Rmd'

#### Edit

Navigate to the newly created folder, located under
`inst/rmarkdown/templates/article`. It should be structured as:

    inst/rmarkdown/templates/article
    |  template.yaml
    |--skeleton/
    |  |  skeleton.Rmd

The file `template.yaml` contains the template name and a few
configurations. Edit the description, but otherwise this file can be
left alone.

To edit the .Rmd template file (which will be the shell of any documents
based on this template), open `skeleton/skeleton.Rmd`. This is where you
should put any boilerplate text or section titles that will be available
each time a new document is created based on the template.

The header block, surrounded by three ticks (`---`), includes parameters
that will be used when rendering the document to its final form. Some,
like title and date, are placeholders and may be edited every time a new
document is created. Others, like the output format and knit function,
can be standardized in this document so they will be the same every time
a document of this type is created. For more about formats and knit
functions, see below. Some suggested settings:

``` r
author: "UIC CCTS Biostatistics Core"
date: "`r format(Sys.Date(), '%B %d, %Y')`"
output: 
  bscContentHelpers::html_draft: default
  bscContentHelpers::word_document:
    toc: FALSE
    theme: "teal"
knit: bscContentHelpers::bsc_knit
```

Put supporting documents (e.g., image files or document-specific
stylesheets that should be copied every time the template is used) in
the `/skeleton` subfolder. Import an image:

    ![Image alt text](image-file-name.png)

Note that you don’t need to include files that are part of the output
format (like header logos or stylesheets). Those should be in
`inst/rmd_files` and referred to in R scripts by
`system.file("rmd_files/filename.ext", package = "bscContentHelpers")`.

#### Preview

Knit the file to see what the final version will look like. Use the
`knit` button or the `Ctrl+Shift+K` shortcut.

After you preview the file, be sure to delete the output (e.g.,
skeleton.html).

#### Deploy

Do any package checks you want (e.g., run `devtools::check()` or
`devtools::load_all()`). When you’re happy, commit and push the changes.

#### Merge \[Recommended - If On a Development Branch\]

On GitHub, compare the changes and initiate a pull request from the
development branch to the main/master branch. Merge. Confirm. Delete the
development branch.

Locally, switch to the master branch. Sync the changes. Then delete the
local version of the development branch.

    git checkout main
    git fetch
    git pull
    git branch -d new-working-branch

#### Update the Installed Package

If you’ve made changes to the `main` branch of the package, you’ll need
to fetch them to update your installed version. In the console:

    devtools::update_packages()

#### For More…

See the excellent [R Markdown
book](https://bookdown.org/yihui/rmarkdown/document-templates.html) for
more detail on document templates.

-   TODO: more about updating the package and templates. Simple guides:
    -   <https://catbirdanalytics.wordpress.com/2021/08/16/how-to-create-a-custom-r-markdown-template/>
    -   <https://cran.r-project.org/web/packages/indiedown/vignettes/walkthrough.html>

### Create a New Output Format

Remember that an output format is an R function that defines the output
file type and specs. Initiate the new format file by calling:

``` r
# create a new format; this is where you'll define output type and look & feel 
usethis::use_r("pptx_presentation")
```

In the format file, create a function that defines the format. In most
cases, this function will base R Markdown format with some custom
options.

``` r
pptx_presentation <- function() {
 
  # call the base powerpoint_presentation format
  rmarkdown::powerpoint_presentation(
    reference_doc = "my_reference.pptx"
  )
   
}
```

Supporting files to be called by the format function should be put in
`inst/rmd_files/`. This way, they’ll be installed with the
`bscContentHelpers` package and will be accessible to any users of your
format function. See examples in `R/` (e.g., `html_draft()`) or, again,
the [R Markdown
documentation](https://bookdown.org/yihui/rmarkdown/new-formats.html)
for more examples.

### Create a New Reference Doc

You might want to do this to set up a new set of styles but leave an
output format otherwise the same. The reference doc might be a
reference.docx, a reference.ppt, or a reference.css.

#### Docx

It’s best to start from a fresh pandoc template. In the terminal (not
the R console):

    $ pandoc -o custom-reference.docx --print-default-data-file reference.docx

Open the new file (`custom-reference.docx`). Built-in styles are listed
in the ribbon. To edit a style, right-click its name and select
`Modify...`. Change font or paragraph options or add header images.
Later documents based on this reference document will have the updated
styles applied.

![.docx styles](man/figures/docx_styles.png)

![.docx styles](man/figures/modify_docx_styles.png)

Save the reference document in this package’s `inst/rmd_files/`
directory with a descriptive name. Check and reinstall the package. The
name will become a theme name that can be referenced in the yaml header
(e.g., reference `teal.docx` with the yaml option `theme: "teal"`).

Note that just changing the formatting of the text in the document,
without editing the underlying style, **will not** extend to documents
based on this template.

#### .pptx

*TODO: Edit the slide masters.*

#### .css

*TODO: Add a css stylesheet.*

### Create a New Knit Function

*TODO*
