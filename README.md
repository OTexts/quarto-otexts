# quarto-otexts

A Quarto format extension with the shared HTML styling for OTexts books: theme, fonts, citation style, analytics and HTML post-processing.

## Installing

For a new book, start from the template in an empty directory:

```bash
quarto use template OTexts/quarto-otexts
```

This installs the extension in `_extensions/` and copies a small starter book: `_quarto.yml`, `book.scss`, `post-render.R` and a few chapters.

For an existing book, add just the extension in the book's project directory:

```bash
quarto add OTexts/quarto-otexts
```

Either way, commit `_extensions/` with the book.
To pull in later changes, run `quarto update OTexts/quarto-otexts`.

## Using

Render with `quarto render` or `quarto render --to otexts-html` (not `--to html`, which uses Quarto's plain format).

### Book colours and extra styles

Edit any book-specific rules in [`book.scss`](book.scss).

### Figures

The format sets the figure defaults for R books: 7.5in wide with a golden-ratio aspect (`fig-asp: 0.618`), 150 dpi (doubled for retina screens), centred, `ragg_png`, shown at 100% width with lazy loading, and no `##` before printed output.
A book or chunk can override any of these (e.g. `fig-width: 7` in `_quarto.yml`), but don't also set them with `knitr::opts_chunk$set()`, which overrides the YAML.
Python books ignore the knitr options.

### Wide tables and equations

On narrow screens, a table wider than the text column shrinks to fit (down to 9px text) and then scrolls, and a long display equation scrolls within its own box.
Inline maths can't do that by default, since it has to wrap with the text.
For a wide inline equation that should stay on the same line as a list item's letter, mark it with the `wide-math` class:

```markdown
a. [$\displaystyle \mathbf{X}'\mathbf{X} = \frac{1}{6}\begin{bmatrix} ... \end{bmatrix}$]{.wide-math}
```

It still breaks after `=`, and scrolls only if a piece is still too wide.

### Today's date

Write `[]{#current-date}` where the page should show the reader's date, such as the access date in a "how to cite" note; a script fills it in as e.g. "18 October 2026".
Likewise `[]{#current-year}` shows the current year.

### Title block

The front page shows the book's title in a rounded box, as on the old bookdown sites: the title on a grey band, then a band in the theme colour with the authors on one line ("A, B and C", linked where an author has a `url`) and each affiliation once.
A `subtitle` (e.g. `subtitle: "(3rd ed)"` under `book:`) appears in small type after the title.
The word joining the last two authors follows the book's `lang` (English, Italian, Spanish, Portuguese, French, German, Greek, Persian, Chinese, Japanese and Korean); other languages get "and".
Set `$title-block-bg` in `book.scss` to change the grey.
Other pages keep Quarto's usual title block.

### Front page cover

To open the front page with the book cover, wrap a short introduction in an `otexts-cover` div:

```markdown
---
date-modified: today
---

# Home {.unnumbered .unlisted}

:::: {.otexts-cover image="figs/cover.jpg" alt="Front cover of ..."}
[Third edition · Free to read online]{.eyebrow}

One or two short paragraphs about the book.

[Start reading](preface.qmd){.btn .btn-primary}
[Buy a print version](print.qmd){.btn .btn-outline-primary}
::::
```

The cover is shown as a book beside the text, and above it on phones.
The text ends with the page's `date-modified`, labelled with `published-title` ("Last updated" unless the book sets another).
Without `image`, a stand-in cover is drawn from the book's title and authors in the theme colour.
Since the cover shows the title and authors, the title block and the page's own heading are hidden on that page (the title block stays in the page for screen readers).
The cover is for the web book only: in other formats (e.g. `otexts-pdf`) the cover and the page's heading are dropped, so the PDF starts with the next chapter, such as the preface.

### Language editions

A book with translations can show a language selector in the sidebar, between the title and the search box.
List every edition, this one included, in `_quarto.yml`:

```yaml
languages:
  - lang: en
    name: English
    url: https://OTexts.com/fpp2/
  - lang: zh
    name: 中文
    url: https://OTexts.com/fppcn/
```

The edition whose `lang` matches the book's `lang` (default `en`) is shown as selected.
Choosing another one opens the same page in that edition, at the section, figure or table the reader is at, so the editions need the same file names and ids.
If that edition has no such page, it opens its home page.
Each edition needs the same `languages:` list.

### R and Python versions

A book with both an R and a Python version can show their icons above the language selector: the current book's in full colour, the other faint and linking to its counterpart.
List both in `_quarto.yml`:

```yaml
software:
  - lang: r
    name: R
    url: https://OTexts.com/fpp3/
    current: true
  - lang: python
    name: Python
    url: https://OTexts.com/fpppy/
    pages:
      intro: 01-intro
      graphics: 02-graphics
```

Clicking the faint icon opens the same section of the other book.
If the two books name their pages differently, `pages` maps this book's page names (without `.html`) to the other's; with `pages`, a page not listed opens the other book's home page.
Without `pages`, the page name is kept.
Each book needs its own `software:` list, with `current: true` on itself and its own `pages` on the other.

### PDF

`otexts-pdf` loads the OTexts LaTeX style (`fpp.sty`, which Quarto copies to the project root when rendering, so a book can ignore it in git), a preamble (`preamble.tex`) and the index, and sets the shared PDF options: `book` class, pdfLaTeX, biblatex citations, numbered sections to depth 2, 2cm margins, wide figures and `keep-tex`.
Render with `quarto render --to otexts-pdf`.
The preamble sets `\graphicspath{{../_book}}` so `pdflatex` also works when run by hand in the `LaTeX/` folder after a render.
A book can append its own LaTeX, such as its maths macros in a `macros.tex`, with `include-in-header` and `include-after-body`, which are added to the format's.

### HTML post-processing

`htmlreplace.pl` tidies the rendered HTML to OTexts house style.
Format extensions can't add a post-render step, so the book runs one from [`post-render.R`](post-render.R), set in `_quarto.yml`:

```yaml
project:
  post-render: post-render.R
```

`post-render.R` calls `post_render()` from the [otexts R package](https://github.com/OTexts/otexts), which runs `htmlreplace.pl` on the rendered HTML and then compresses the figures with [pngquant](https://pngquant.org).
It needs the otexts package (`pak::pak("OTexts/otexts")`), Perl and pngquant installed.
An existing book can copy `post-render.R` from this repo.
A Python book can run `perl -i _extensions/OTexts/otexts/htmlreplace.pl` on the HTML files from its own post-render script instead.

## Not included

- Plot styling (fonts and themes for figures): R books get it from the [otexts R package](https://github.com/OTexts/otexts) (`otexts::setup_book()`); Python books set their own.
- Book-specific options: `bibliography`, `code-fold`, extra header includes (e.g. fpp3's `youtube.html`).

## Testing

The repo root is a small test book that uses the format:

```bash
quarto render
```
