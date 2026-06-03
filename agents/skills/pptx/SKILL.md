---
name: pptx
description: Use this skill whenever the user wants to read, create, or edit PowerPoint presentations (.pptx files). Includes content extraction, creating slides from scratch, editing templates, adding charts/tables/images, and visual QA.
---

# PPTX Processing

## Strategy by Task

| Task | Approach |
|------|----------|
| Read / analyze content | `uv run --with "markitdown[pptx]"` |
| Edit existing template | Unpack XML → edit → repack |
| Create from scratch | `pptxgenjs` npm package |
| Visual inspection | Convert to images via LibreOffice + pdftoppm |

## Reading Content

```bash
# Text extraction — best option
uv run --with "markitdown[pptx]" -m markitdown presentation.pptx

# Check for leftover placeholder text
uv run --with "markitdown[pptx]" -m markitdown output.pptx | grep -iE "xxxx|lorem|ipsum"

# Raw XML access — unpack the ZIP
mkdir unpacked && cp presentation.pptx unpacked/prs.zip
cd unpacked && unzip prs.zip -d contents
# slides are in contents/ppt/slides/slide*.xml
```

## Creating from Scratch (pptxgenjs)

Use when there is no template to start from.

```bash
npm install -g pptxgenjs
```

```javascript
const pptxgen = require("pptxgenjs");
const prs = new pptxgen();

let slide = prs.addSlide();
slide.addText("Title Text", { x: 0.5, y: 0.5, w: 9, h: 1, fontSize: 44, bold: true, color: "1E2761" });
slide.addText("Body content.", { x: 0.5, y: 2, w: 9, h: 4, fontSize: 16 });

// Image
slide.addImage({ path: "photo.jpg", x: 5, y: 1.5, w: 4, h: 3 });

// Table
slide.addTable(
    [["Col A", "Col B"], ["Row 1", "Data"]],
    { x: 0.5, y: 1.5, w: 4, colW: [2, 2], border: { pt: 1, color: "CFCFCF" } }
);

prs.writeFile({ fileName: "output.pptx" });
```

## Editing Existing Presentations (XML)

```bash
# Unpack
mkdir unpacked && cp input.pptx unpacked/prs.zip
cd unpacked && unzip prs.zip -d contents

# Edit ppt/slides/slide1.xml, ppt/slideLayouts/, ppt/theme/theme1.xml

# Repack
cd contents && zip -r ../../output.pptx .
```

```bash
# Python XML editing
uv run --with lxml - <<'EOF'
from lxml import etree
tree = etree.parse("contents/ppt/slides/slide1.xml")
# modify tree ...
tree.write("contents/ppt/slides/slide1.xml", xml_declaration=True, encoding="UTF-8")
EOF
```

## Design Principles

**Don't create boring slides.** Plain bullets on white are forgettable. Pick a deliberate palette and stick to it.

### Color Strategy
- One color dominates (60–70% visual weight), 1–2 supporting tones, one sharp accent
- Dark backgrounds for title and conclusion slides, light for content
- Pick colors matched to the topic — not default blue

| Theme | Primary | Secondary | Accent |
|-------|---------|-----------|--------|
| Midnight Executive | `1E2761` | `CADCFC` | `FFFFFF` |
| Forest & Moss | `2C5F2D` | `97BC62` | `F5F5F5` |
| Coral Energy | `F96167` | `F9E795` | `2F3C7E` |
| Charcoal Minimal | `36454F` | `F2F2F2` | `212121` |

### Typography
- Slide title: 36–44pt bold
- Body: 14–16pt
- Avoid Arial for everything — pair a header font with a clean body font (e.g., Georgia + Calibri)

### Layout Ideas (every slide needs a visual element)
- Two-column: text left, image/chart right
- Icon rows: colored-circle icon + bold header + description
- Large stat callout: 60–72pt number with small label below
- Half-bleed image with content overlay

### Avoid
- Repeating the same layout across slides
- Centering body text (center titles only)
- Accent lines under titles (hallmark of AI-generated slides — use whitespace instead)
- Text-only slides
- Low-contrast text or icons

## Visual QA (Required)

Assume there are problems. Convert slides to images and inspect.

```bash
# Convert to images
soffice --headless --convert-to pdf output.pptx
pdftoppm -jpeg -r 150 output.pdf slide
# produces slide-01.jpg, slide-02.jpg, ...

# Re-render specific slides after a fix
pdftoppm -jpeg -r 150 -f 2 -l 2 output.pdf slide-fixed
```

Arch packages: `sudo pacman -S libreoffice-fresh poppler`

Use a subagent to inspect the images with fresh eyes — prompt it to look for: overlapping elements, text overflow, elements too close to edges, uneven gaps, low-contrast text, leftover placeholders.

### QA Loop
1. Generate → convert to images → inspect
2. List every issue found (if none found, look again)
3. Fix issues → re-verify affected slides
4. Repeat until a full pass is clean

## Quick Reference

| Task | uv invocation |
|------|---------------|
| Read text | `uv run --with "markitdown[pptx]" -m markitdown` |
| XML manipulation | `uv run --with lxml` |
| Thumbnail generation | `uv run --with Pillow` |
