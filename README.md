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
- Book-specific options: `bibliography`, `code-fold`, extra header includes (e.g. fpp3's `youtube.html`), and the PDF format (fpppy).

## Testing

The repo root is a small test book that uses the format:

```bash
quarto render
```
