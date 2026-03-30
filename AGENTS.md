# AGENTS.md

This is a personal writing system. The author writes in Emacs Org-mode
and publishes documents as both PDF and HTML through a pipeline of
pandoc, a custom Lua filter, and Typst. The visual identity uses IBM
Plex fonts and a grayscale broadsheet aesthetic.

Do not create, rename, or reorganize files without being asked. This
repository has a deliberate structure and naming convention.

## Project Layout

```
*.org              -- source documents (write here)
index.org          -- site index (manually maintained)
style/ajd.typ      -- Typst document template (PDF rendering)
style/document.css -- HTML document stylesheet
style/ajd.mplstyle -- matplotlib style sheet
ajd.lua            -- pandoc Lua filter (Org to Typst/HTML transforms)
plots/ajd.py       -- shared Python plotting helpers and theme
plots/*.py         -- individual visualization scripts
diagrams/*.typ     -- Typst source for diagrams (compiled to SVG)
images/*.svg       -- generated images consumed by documents
docs/              -- published site: HTML pages, PDFs, document.css
.cache/typst-build/ -- intermediate .typ files (gitignored)
Makefile           -- orchestrates the full pipeline
setup.sh           -- installs all dependencies via Homebrew and uv
.dir-locals.el     -- Emacs config: sets compile-command per Org buffer
```

## Dependencies

Run `./setup.sh` to install everything. The system requires:

- pandoc (Org to Typst and HTML conversion)
- typst (PDF rendering and diagram compilation)
- uv (Python environment and package management for plots/)
- IBM Plex fonts: Serif, Sans, Mono (installed via Homebrew cask)
- Python 3.14+ with matplotlib and plotnine (managed by uv in plots/)

## Build Commands

Build a single document in both formats:

    make myfile.pdf myfile.html

The PDF pipeline runs pandoc to Typst, writes intermediate markup to
`.cache/typst-build/`, then compiles the PDF into `docs/`. The HTML
pipeline runs pandoc to HTML with `document.css` linked and SVG images
inlined directly into the page.

Build the full site (all `.org` files to HTML):

    make site

Compile a diagram to SVG:

    make images/pipeline.svg

Clean build artifacts:

    make clean

## Writing Conventions

Documents are Org-mode files in the repository root. The first `*`
heading becomes the document title when no `#+title:` is set. The
author defaults to "Aldrin D'Souza" and the date defaults to the build
date. Override either with `#+author:` or `#+date:` in the Org header.
Setting either to blank (e.g. `#+author:` with no value) suppresses
it from the HTML title block.

Use `#+description:` for the HTML meta description tag.

Links to other pages in the site use the `file:` prefix in Org:
`[[file:README.html][link text]]`. Without the prefix, pandoc treats
the target as an unresolvable internal link.

Follow these rules for prose:

- Keep sentences under 30 words.
- Use active voice with subject-verb-object structure.
- No emojis, em-dashes, or semicolons.
- Replace vague modifiers with concrete data.
- Write in narrative paragraphs, not bullet lists, for document content.

## Template and Filter

The Typst template (`style/ajd.typ`) defines page geometry, font
stacks, heading styles, and custom blocks. The HTML stylesheet
(`style/document.css`) mirrors the same visual language for the web.

The Lua filter (`ajd.lua`) adapts pandoc output for both formats:

1. Sets default `lang`, `author`, and `date` metadata
2. Clears `author`/`date` when set to blank in the Org header
3. Promotes the first h1 to document title when `#+title` is absent
4. Shifts remaining headings up one level to compensate
5. Strips the empty "Footnotes" heading that Org generates
6. Injects a home link on all HTML pages except the index
7. Converts `[[#label]]` links to Typst `@label` cross-references
8. Rewrites image paths: root-relative for Typst, inlines SVGs for HTML
9. Passes explicit figure widths through to Typst
10. Converts special blocks (aside, callout, key, twocol) per format
11. Injects Typst imports for custom blocks that were used

Available custom blocks in Org source:

- `#+begin_aside` / `#+end_aside` -- subdued background box
- `#+begin_note`, `#+begin_tip`, `#+begin_warning`, `#+begin_important` -- callout with colored left border
- `#+begin_key` / `#+end_key` -- highlighted key-point box
- `#+begin_twocol` / `#+end_twocol` -- two-column layout, split by `-----`

Cross-reference tables and figures by adding `#+name: label` above
them and writing `[[#label]]` in the text.

## Visualization

Visualization scripts live in `plots/` and share a common style
through `plots/ajd.py`, which automatically applies `style/ajd.mplstyle`
on import. All plots use the grayscale broadsheet palette. Data is
defined inline in each script. Scripts output SVG files to `images/`.

When writing a new plot script:

1. Import `ajd` to get the style, palette constants, and helpers
2. Define data inline as a DataFrame or list
3. Use `ajd.figure()` or `ajd.half_figure()` for correct sizing
4. Use `ajd.save(fig_or_plot, "name")` to write to `images/`
5. For plotnine, apply `ajd.THEME` to the plot
6. Manage dependencies through `plots/pyproject.toml` and `uv sync`

Diagrams are standalone Typst files in `diagrams/` that compile to SVG
via `make images/name.svg`.

## Git

Follow the seven rules for commit messages: separate subject from
body, limit subject to 50 characters, capitalize it, no trailing
period, imperative mood, wrap body at 72 characters, explain what and
why in the body. Sign all commits with SSH keys.

Generated files are gitignored: `plots/.venv/`, `.cache/`. Checked-in
artifacts include `images/*.svg` because documents reference them
directly, and `docs/.nojekyll` for GitHub Pages. The files in `docs/`
(HTML, PDF, `document.css`) are build outputs from `make`.

## Site

The `docs/` directory is served by GitHub Pages. The site index is
`index.org`, a manually maintained Org file. To publish a new document,
add a `file:` link to `index.org` and run `make site`. This builds
HTML for every `.org` file in the repository root.

HTML pages get a home link back to `index.html` automatically. The
index page itself does not get this link.
