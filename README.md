# quarto-otexts

A Quarto format extension with the shared styling for OTexts books, in HTML (`otexts-html`) and PDF (`otexts-pdf`): theme, fonts, citation style, front page cover, language and software selectors, analytics, and post-processing.

## Installing

For a new book, start from the template in an empty directory:

```bash
quarto use template OTexts/quarto-otexts
```

This installs the extension in `_extensions/` and copies a small starter book: `_quarto.yml`, `book.scss`, `post-render.R` and a front page with a cover, a preface and a few chapters.

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

### Front page (HTML)

`index.qmd` is the front page.
It shows the book cover beside a short introduction, set up like this (the template has one):

```markdown
---
date-modified: today
---

# Home {.unnumbered .unlisted}

:::: {.otexts-cover}
[Third edition · Free to read online]{.eyebrow}

One or two short paragraphs about the book.

[Start reading](preface.qmd){.btn .btn-primary}
[Buy a print version](print.qmd){.btn .btn-outline-primary}
::::
```

- `[...]{.eyebrow}` is the small line above the text, such as the edition.
- The buttons are ordinary links with `.btn .btn-primary` (solid) or `.btn .btn-outline-primary` (outline).
  Use as many as you like.
- The text ends with the page's `date-modified`, labelled with `published-title` ("Last updated" unless the book sets another).
  Drop the YAML header to leave it out.
- The preface is a separate file, `preface.qmd`, which the "Start reading" button links to.

Set the cover image in `_quarto.yml`, and list it under `resources` so it is copied into the book:

```yaml
project:
  resources:
    - figs/*.jpg
book:
  cover-image: figs/cover.jpg
```

It is used if the file exists, with alt text made from the title and authors ("Front cover of *title*, by *A and B*").
Without an image, a stand-in cover is drawn from the book's title and authors in the theme colour; `$title-block-bg` in `book.scss` sets the grey band behind its title.

Attributes on the `.otexts-cover` div override the book's settings:

- `image="figs/other.jpg"`: use this image instead of `cover-image`.
- `alt="..."`: use this alt text instead of the generated one.
- `logo="figs/hex.png"`: for the stand-in cover only, show this image (e.g. a hex sticker) below the title.

Since the cover shows the title and authors, the title block and the page's own heading are hidden on that page (the title block stays in the page for screen readers).

### Front matter (PDF)

The PDF has no cover: the cover and the page's heading are dropped from `index.qmd`, so the book starts with the next chapter, such as the preface.
The title page, running head and copyright page are built from the metadata: `title`, `subtitle`, `authors` (names only), `runningtitle` (default: the title), `isbn`, `print-edition` and `book: site-url`.

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

- **Other engines:** set `pdf-engine: lualatex` (or `xelatex`) for right-to-left or non-Latin books.
  The pdfTeX-only packages are then skipped, and book strings (chapter label, title page, copyright page, bibliography) are macros a book can redefine.
- **Figures:** R plots use `cairo_pdf`, so they pick up the same fonts as the HTML figures (set up by `otexts::setup_book()`).
- **Code and output:** code and R output are in shaded blocks.
  A code block of up to 4 lines, or an output block of up to 16 lines, is kept in one piece.
  A longer code block may break across pages only between R commands (a comment stays with the command after it).
  This is done by `code-blocks.lua` and `\otextscodebreaks` in `fpp.sty`.
- **Cover:** the front-page cover is dropped, so the PDF starts at the next chapter.
- **Customising:** a book can append its own LaTeX, such as maths macros in a `macros.tex`, with `include-in-header` and `include-after-body`, which are added to the format's.
  The preamble sets `\graphicspath{{../_book}}` so `pdflatex` also works when run by hand in the `LaTeX/` folder.

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
