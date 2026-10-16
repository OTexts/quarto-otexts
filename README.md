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

### HTML post-processing

`htmlreplace.pl` tidies the rendered HTML to OTexts house style.
Format extensions can't add a post-render step, so the book runs it from [`post-render.R`](post-render.R), set in `_quarto.yml`:

```yaml
project:
  post-render: post-render.R
```

An existing book can copy `post-render.R` from this repo.

## Not included

- Plot styling (fonts and themes for figures) is R or Python code in each book.
- Book-specific options: `execute`, `bibliography`, figure sizes, `code-fold`, `embed-resources`, extra header includes (e.g. fpp3's `youtube.html`), and the PDF format (fpppy).

## Testing

The repo root is a small test book that uses the format:

```bash
quarto render
```
