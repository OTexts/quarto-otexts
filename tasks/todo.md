# quarto-otexts: shared format for the OTexts books

Baseline: weird's styling (as of 2026-10-16), with fpp3's Amazon-tag regex.

- [x] Copy weird's shared files into `_extensions/otexts/` (scss, fonts, CSL, goatcounter, htmlreplace.pl)
- [x] Add fpp3's Amazon-tag regex to `htmlreplace.pl` (kept weird's bare-URL step too; see review)
- [x] Make the theme colours `!default` so a book can override them
- [x] Write `_extension.yml` contributing the `otexts-html` format
- [x] Test book at repo root that renders with the format
- [x] Check how a book's own `theme:` layers on the extension's theme
- [x] Check the fonts are copied into the rendered site
- [x] Check weird renders identically with the extension (CSS diff against current build)
- [x] README: install, use, per-book overrides, updating
- [x] First commit

## Next

- [ ] Push to the OTexts GitHub org
- [ ] Switch weird to the extension (`_quarto.yml`, `post-render.R`, Makefile `--to otexts-html`, intro.qmd `other-links`, delete the copied files)
- [ ] Switch fpp3 (theme colours via a book SCSS layer; check its CSL change for ISBN entries)
- [ ] Switch fpppy (many chapters set options under `format: html:`; PDF format stays in the book)

## Review

- Fonts: Quarto resolves `url()` in theme SCSS against the project, not the
  extension, so the `@font-face` rules moved to `fonts.css`, added as an HTML
  dependency by `otexts.lua`. weird's compiled CSS is otherwise identical.
- Amazon links: fpp3's regex only tags existing links (fpp3 uses `url` fields).
  weird's CSL prints ISBNs as bare Amazon URLs, which only weird's regex
  handled, so the script now links bare URLs first, then tags all of them.
- Book themes must use `theme: light: [...]`; a plain list errors.
- `quarto render --to html` ignores the format; use `--to otexts-html`.
- Chapter-level `format: html:` options are ignored under `otexts-html`.
- Verified with a copy of weird: resolved format options match apart from paths;
  intro.html is identical except the fonts.css link and the year script.
