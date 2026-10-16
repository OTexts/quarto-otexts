# quarto-otexts

A Quarto format extension with the shared HTML styling for the OTexts books
(*That's Weird!*, *fpp3*, *fpppy*): theme, fonts, citation style, analytics and
HTML post-processing.

## Installing

In a book's project directory:

```bash
quarto add OTexts/quarto-otexts          # once it is on GitHub
quarto add ~/git/OTexts/quarto-otexts    # from a local clone
```

This copies the extension into the book's `_extensions/` folder, which should
be committed with the book. To pull in later changes, run `quarto update` with
the same source.

## Using

In `_quarto.yml`, replace `format: html:` with `format: otexts-html:`, and
delete the options the format already sets:

```yaml
format:
  otexts-html:
    code-fold: true          # book-specific options only
```

Render with `quarto render` or `quarto render --to otexts-html`. **Not**
`--to html`: that silently uses Quarto's plain `html` format, without any of
this styling. The same goes for options in a chapter's front matter: put them
at the top level (e.g. `other-links:`), not under `format: html:`, or they are
ignored.

The format sets the Cosmo theme with `otexts.scss`, the Libron / Fira Sans / Hack
fonts, font size and line spacing, KaTeX maths, kate syntax highlighting,
`number-depth: 2`, `toc-title`, `published-title`, `date-format`,
`code-link: false`, `fig-responsive: true`, `csl: apa-single-spaced.csl`, the
GoatCounter script, and a script that puts the year in a `[]{#current-year}`
span (for the page footer). Any of these can be overridden in the book.

The fonts are added to each page as an HTML dependency (`otexts.lua`,
`fonts.css`), and end up in `site_libs/quarto-contrib/otexts-fonts-*/`.

### Book colours and extra styles

Each book keeps a small SCSS file of its own with its theme colour and any
book-specific rules. Every variable in `otexts.scss` is `!default`, so the book's
values win:

```scss
/*-- scss:defaults --*/
$theme-main: #6e3232;
$theme-orange: #ff9100;

/*-- scss:rules --*/
.hk-algorithm td { padding-top: 2px !important; }
```

Then add it to the theme, using the `light:` form (the format's theme is
written that way, and a plain list gives an error):

```yaml
format:
  otexts-html:
    theme:
      light: [book.scss]
```

Quarto puts the book's file after the format's `cosmo` and `otexts.scss`.

Variables that are derived from `$theme-main` (`$theme-tint`,
`$theme-header-bg`, `$link-hover-color`, …) follow the book's colour unless the
book sets them too.

### HTML post-processing

`htmlreplace.pl` tidies the rendered HTML: it removes "Retrieved from", restyles
the author line, shortens chapter cross-references on unnumbered pages, adds the
OTexts affiliate tag to Amazon links in the bibliography (both `url` fields,
which citeproc links, and ISBNs, which the CSL prints as bare Amazon URLs), and
turns bibliography links into icons. Format extensions can't add a post-render
step, so a book's post-render script calls it directly:

```r
# post-render.R
files <- strsplit(Sys.getenv("QUARTO_PROJECT_OUTPUT_FILES"), "\n")[[1]]
files <- files[endsWith(files, ".html")]
system2("perl", c("-i", "_extensions/OTexts/otexts/htmlreplace.pl", shQuote(files)))
```

(The path is `_extensions/otexts/` when the extension was added from a local
clone, and `_extensions/OTexts/otexts/` when it was added from GitHub.)

## Not included

- Plot styling (fonts and themes for figures) is R or Python code in each book.
- Book-specific options: `execute`, `bibliography`, figure sizes, `code-fold`,
  `embed-resources`, extra header includes (e.g. fpp3's `youtube.html`), and
  the PDF format (fpppy).

## Testing

The repo root is a small test book that uses the format:

```bash
quarto render
perl -i _extensions/otexts/htmlreplace.pl _book/*.html
```
