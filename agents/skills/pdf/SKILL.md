---
name: pdf
description: Use this skill whenever the user wants to do anything with PDF files. This includes reading or extracting text/tables from PDFs, combining or merging multiple PDFs into one, splitting PDFs apart, rotating pages, adding watermarks, creating new PDFs, encrypting/decrypting PDFs, extracting images, and OCR on scanned PDFs. If the user mentions a .pdf file or asks to produce one, use this skill.
---

# PDF Processing

## Python Dependencies

Always run Python via `uv run --with` — never install globally or use bare `python`:

```bash
uv run --with pypdf python script.py                              # merge/split/rotate/encrypt
uv run --with pdfplumber --with pandas python script.py          # table extraction
uv run --with reportlab python script.py                         # create PDFs
uv run --with pytesseract --with pdf2image python script.py      # OCR
```

For inline one-liners use a heredoc:

```bash
uv run --with pypdf - <<'EOF'
from pypdf import PdfReader
reader = PdfReader("document.pdf")
print(len(reader.pages))
EOF
```

## Extracting Text and Tables

### Text (pypdf)
```python
from pypdf import PdfReader
reader = PdfReader("document.pdf")
text = "".join(page.extract_text() for page in reader.pages)
```

### Tables (pdfplumber)
```python
import pdfplumber, pandas as pd
with pdfplumber.open("document.pdf") as pdf:
    frames = []
    for page in pdf.pages:
        for table in page.extract_tables():
            frames.append(pd.DataFrame(table[1:], columns=table[0]))
combined = pd.concat(frames, ignore_index=True)
```

## Merge, Split, Rotate

```python
from pypdf import PdfReader, PdfWriter

# Merge
writer = PdfWriter()
for f in ["a.pdf", "b.pdf"]:
    for page in PdfReader(f).pages:
        writer.add_page(page)
with open("merged.pdf", "wb") as out:
    writer.write(out)

# Split
reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    w = PdfWriter()
    w.add_page(page)
    with open(f"page_{i+1}.pdf", "wb") as out:
        w.write(out)

# Rotate
page = reader.pages[0]
page.rotate(90)
```

## Creating PDFs (reportlab)

```bash
uv run --with reportlab - <<'EOF'
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = [
    Paragraph("Title", styles['Title']),
    Spacer(1, 12),
    Paragraph("Body content.", styles['Normal']),
]
doc.build(story)
EOF
```

**Subscripts/Superscripts**: Never use Unicode characters (₀₁₂, ⁰¹²) — they render as black boxes in built-in fonts. Use ReportLab XML tags inside `Paragraph`: `H<sub>2</sub>O`, `x<super>2</super>`.

## OCR (Scanned PDFs)

Requires system packages: `sudo pacman -S tesseract tesseract-data-eng poppler`

```bash
uv run --with pytesseract --with pdf2image - <<'EOF'
import pytesseract
from pdf2image import convert_from_path
images = convert_from_path("scanned.pdf")
for i, img in enumerate(images):
    print(f"--- Page {i+1} ---")
    print(pytesseract.image_to_string(img))
EOF
```

## Watermark and Encrypt

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("document.pdf")
watermark = PdfReader("watermark.pdf").pages[0]
writer = PdfWriter()
for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)
writer.encrypt("userpassword", "ownerpassword")  # omit to skip encryption
with open("output.pdf", "wb") as out:
    writer.write(out)
```

## CLI Tools (poppler / qpdf)

```bash
# Text extraction
pdftotext -layout input.pdf output.txt
pdftotext -f 1 -l 5 input.pdf output.txt   # pages 1–5

# Merge / split / rotate
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf
qpdf input.pdf output.pdf --rotate=+90:1

# Extract images
pdfimages -j input.pdf output_prefix
```

Arch packages: `sudo pacman -S poppler qpdf`

## Quick Reference

| Task | uv invocation |
|------|---------------|
| Extract text | `uv run --with pypdf` |
| Extract tables | `uv run --with pdfplumber --with pandas` |
| Merge / split / rotate | `uv run --with pypdf` |
| Create PDF | `uv run --with reportlab` |
| OCR | `uv run --with pytesseract --with pdf2image` |
