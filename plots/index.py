"""Generate docs/index.html from publishable .org files."""

import html
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"

HEADER_RE = re.compile(r"^#\+(\w+):\s*(.+)$", re.IGNORECASE)


HEADING_RE = re.compile(r"^\*\s+(.+)$")


def read_metadata(path):
    """Extract #+key: value headers and first heading from an Org file."""
    meta = {}
    first_heading = None
    with open(path) as f:
        for line in f:
            stripped = line.strip()
            if not stripped:
                continue
            m = HEADER_RE.match(stripped)
            if m:
                meta[m.group(1).lower()] = m.group(2).strip()
                continue
            if not first_heading:
                h = HEADING_RE.match(stripped)
                if h:
                    first_heading = h.group(1).strip()
                    break
    if "title" not in meta and first_heading:
        meta["title"] = first_heading
    return meta


def gather_entries():
    """Find all .org files with #+publish: true and return sorted entries."""
    entries = []
    for org in sorted(ROOT.glob("*.org")):
        meta = read_metadata(org)
        if meta.get("publish", "").lower() != "true":
            continue
        pdf = DOCS / f"{org.stem}.pdf"
        if not pdf.exists():
            continue
        entries.append(
            {
                "title": meta.get("title", org.stem),
                "date": meta.get("date", ""),
                "description": meta.get("description", ""),
                "pdf": pdf.name,
            }
        )
    entries.sort(key=lambda e: e["date"], reverse=True)
    return entries


PAGE_ICON = (
    '<svg class="icon" viewBox="0 0 16 16">'
    '<path d="M3 1h7l4 4v10H3z" fill="none" stroke="currentColor" stroke-width="1.2"/>'
    '<path d="M10 1v4h4" fill="none" stroke="currentColor" stroke-width="1.2"/>'
    "</svg>"
)


def render(entries):
    """Render the index HTML."""
    items = []
    for i, e in enumerate(entries, 1):
        t = html.escape(e["title"])
        date = html.escape(e["date"])
        date_html = f"<time>{date}</time>" if date else ""
        items.append(
            f'<a class="entry" href="{html.escape(e["pdf"])}">'
            f'<span class="num">{i:02d}</span>'
            f"{PAGE_ICON}"
            f'<span class="title">{t}</span>'
            f"{date_html}"
            f"</a>"
        )

    body = "\n".join(items) if items else "<p>Nothing published yet.</p>"

    return f"""\
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Aldrin's Pages</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="page">
    <header>
      <h1>Aldrin's Pages</h1>
    </header>
    <main>
{body}
    </main>
    <footer>
      <p>Notes on software and related topics, written in my free time
      and published as PDFs. All opinions expressed here are my own.
      <a href="https://github.com/aldrin/pages">Source on GitHub.</a></p>
    </footer>
  </div>
</body>
</html>
"""


def main():
    entries = gather_entries()
    index = DOCS / "index.html"
    index.write_text(render(entries))


if __name__ == "__main__":
    main()
