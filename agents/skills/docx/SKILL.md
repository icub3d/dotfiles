---
name: docx
description: Use this skill whenever the user wants to create, edit, or extract content from Word documents (.docx files). Includes creating new documents, editing existing ones, extracting text, working with tables, images, tracked changes, headers/footers, and format conversion.
---

# DOCX Processing

## Strategy by Task

| Task | Approach |
|------|----------|
| Create new document | JavaScript `docx` npm package |
| Edit existing document | Unpack XML → edit → repack |
| Extract text | `pandoc` or unpack |
| Convert to other formats | `pandoc` |

## Text Extraction

```bash
# Best option — pandoc converts to plain text or markdown
pandoc input.docx -t plain -o output.txt
pandoc input.docx -t markdown -o output.md

# Python alternative
uv run --with python-docx - <<'EOF'
from docx import Document
doc = Document("input.docx")
for para in doc.paragraphs:
    print(para.text)
EOF
```

## Creating New Documents (docx npm)

Preferred for new documents — richer API than python-docx.

```bash
npm install docx
```

```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, WidthType } = require("docx");
const fs = require("fs");

const doc = new Document({
    sections: [{
        properties: {
            page: {
                size: { width: 12240, height: 15840 },  // US Letter in DXA (1440 DXA = 1 inch)
            },
        },
        children: [
            new Paragraph({
                children: [new TextRun({ text: "Hello World", bold: true })],
            }),
        ],
    }],
});

Packer.toBuffer(doc).then(buffer => fs.writeFileSync("output.docx", buffer));
```

### Critical Rules for docx-js

- **Page size**: Default is A4; use `{ width: 12240, height: 15840 }` for US Letter
- **Tables**: Set both `columnWidths` array AND individual cell `width` with `WidthType.DXA` — never use percentage widths (breaks Google Docs compatibility)
- **Bullet lists**: Use `LevelFormat.BULLET` with numbering config; never insert Unicode bullet characters `•`
- **Page breaks**: Must be nested inside `Paragraph` elements
- **Images**: Require explicit `type` parameter: `png`, `jpg`, `gif`, `bmp`, or `svg`

## Editing Existing Documents (XML)

.docx files are ZIP archives — unpack, edit XML, repack:

```bash
# Unpack
mkdir unpacked && cp input.docx unpacked/input.zip
cd unpacked && unzip input.zip -d contents

# Edit word/document.xml (main body), word/styles.xml, etc.

# Repack
cd contents && zip -r ../output.docx .
```

### XML Editing Standards

- Use smart quotes as XML entities: `&#x2019;` (apostrophe), `&#x201C;`/`&#x201D;` (open/close quotes)
- Tracked changes: `<w:ins>` for insertions, `<w:del>` for deletions, preserving `<w:rPr>` formatting blocks
- Comments: marker elements are **siblings** of text runs, never nested inside them

```bash
# Python for XML manipulation
uv run --with lxml - <<'EOF'
from lxml import etree
tree = etree.parse("unpacked/contents/word/document.xml")
# ... modify tree ...
tree.write("unpacked/contents/word/document.xml", xml_declaration=True, encoding="UTF-8")
EOF
```

## Python (python-docx) for Simple Tasks

For straightforward creation/editing when the docx npm approach is overkill:

```bash
uv run --with python-docx - <<'EOF'
from docx import Document
from docx.shared import Inches, Pt

doc = Document()
doc.add_heading("Title", 0)
doc.add_paragraph("Body text.")

table = doc.add_table(rows=2, cols=3)
table.cell(0, 0).text = "Header"

doc.save("output.docx")
EOF
```

## Format Conversion (pandoc)

```bash
# docx → PDF (requires LaTeX or LibreOffice)
pandoc input.docx -o output.pdf

# docx → HTML
pandoc input.docx -o output.html

# Markdown → docx
pandoc input.md -o output.docx

# With a reference template
pandoc input.md --reference-doc=template.docx -o output.docx
```

Arch package: `sudo pacman -S pandoc`
