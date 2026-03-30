# AGENTS.md

This is a personal writing system. The author writes in Emacs Org-mode
and produces PDF output through a pipeline of pandoc, a custom Lua
filter, and Typst. The visual identity uses IBM Plex fonts and a
grayscale broadsheet aesthetic.

Do not create, rename, or reorganize files without being asked. This
repository has a deliberate structure and naming convention.

## Project Layout

```
.org              -- source documents (write here)
style/ajd.typ     -- Typst document template
style/ajd.mplstyle -- matplotlib style sheet
ajd.lua           -- pandoc Lua filter (Org to Typst transforms)
plots/ajd.py      -- shared Python plotting helpers and theme
plots/*.py        -- individual visualization scripts
diagrams/*.typ    -- Typst source for diagrams (compiled to SVG)
images/*.svg      -- generated images consumed by documents
docs/             -- published site: PDFs, index.html, style.css
.cache/typst-build/ -- intermediate .typ files (gitignored)
plots/index.py    -- generates docs/index.html from .org metadata
Makefile          -- orchestrates the full pipeline
setup.sh          -- installs all dependencies via Homebrew and uv
```

## Dependencies

Run `./setup.sh` to install everything. The system requires:

- pandoc (Org to Typst conversion)
- typst (PDF rendering and diagram compilation)
- uv (Python environment and package management for plots/)
- IBM Plex fonts: Serif, Sans, Mono (installed via Homebrew cask)
- Python 3.14+ with matplotlib and plotnine (managed by uv in plots/)

## Build Commands

Build a PDF from an Org file:

    make myfile.pdf

This runs pandoc with the Lua filter, writes intermediate Typst to
`.cache/typst-build/`, then compiles the PDF into `docs/`.

Compile a diagram to SVG:

    make images/pipeline.svg

Generate the site index:

    make site

Clean build artifacts:

    make clean

## Writing Conventions

Documents are Org-mode files in the repository root. The first `*`
heading becomes the document title when no `#+title:` is set. The
author defaults to "Aldrin D'Souza" and the date defaults to the build
date. Override either with `#+author:` or `#+date:` in the Org header.

Follow these rules for prose:

- Keep sentences under 30 words.
- Use active voice with subject-verb-object structure.
- No emojis, em-dashes, or semicolons.
- Replace vague modifiers with concrete data.
- Write in narrative paragraphs, not bullet lists, for document content.

## Template and Filter

The Typst template (`style/ajd.typ`) defines page geometry, font
stacks, heading styles, and custom blocks. The Lua filter (`ajd.lua`)
handles seven transforms:

1. Promotes the first h1 to document title when `#+title` is absent
2. Shifts remaining headings up one level to compensate
3. Strips the empty "Footnotes" heading that Org generates
4. Sets default author and date metadata
5. Converts `[[#label]]` links to Typst `@label` cross-references
6. Rewrites relative image paths to root-relative for `typst --root`
7. Converts special blocks (aside, callout, key, twocol) to Typst

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

Generated files are gitignored: `plots/.venv/`, `.cache/`. Checked-in artifacts include `images/*.svg`
because documents reference them directly, and `docs/index.html`,
`docs/style.css`, `docs/.nojekyll` for GitHub Pages.

## Site

The `docs/` directory is served by GitHub Pages. To publish an Org
file, add `#+publish: true` to its header along with `#+title:`,
`#+date:`, and `#+description:`. Then run `make site` to regenerate
the index. The `plots/index.py` script scans all `.org` files for these
headers and builds `docs/index.html` with links to the matching PDFs.
