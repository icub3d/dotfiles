---
name: xlsx
description: Use this skill any time a spreadsheet file is the primary input or output. Includes opening, reading, editing, or creating .xlsx, .xlsm, .csv, or .tsv files — adding columns, computing formulas, formatting, charting, cleaning messy data, or converting between tabular formats. Trigger when the user references a spreadsheet file and wants something done to it or produced from it.
---

# XLSX Processing

## Python Dependencies

Always use `uv run --with` — never install globally:

```bash
uv run --with pandas python script.py                    # data analysis, bulk ops
uv run --with openpyxl python script.py                  # formulas, formatting
uv run --with pandas --with openpyxl python script.py    # combined workflows
```

## Reading and Analyzing

```bash
uv run --with pandas - <<'EOF'
import pandas as pd

df = pd.read_excel("file.xlsx")                         # first sheet
all_sheets = pd.read_excel("file.xlsx", sheet_name=None) # all sheets as dict

df.head()
df.info()
df.describe()

df.to_excel("output.xlsx", index=False)
EOF
```

## Creating New Files (openpyxl)

```bash
uv run --with openpyxl - <<'EOF'
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
ws = wb.active

ws["A1"] = "Revenue"
ws["B1"] = 1000
ws["C1"] = "=SUM(B1:B10)"   # always use formulas, not hardcoded Python values

ws["A1"].font = Font(bold=True, color="000000")
ws["A1"].fill = PatternFill("solid", start_color="FFFF00")
ws["A1"].alignment = Alignment(horizontal="center")
ws.column_dimensions["A"].width = 20

wb.save("output.xlsx")
EOF
```

## Editing Existing Files

```bash
uv run --with openpyxl - <<'EOF'
from openpyxl import load_workbook

wb = load_workbook("existing.xlsx")
ws = wb.active  # or wb["SheetName"]

ws["A1"] = "Updated"
ws.insert_rows(2)
ws.delete_cols(3)

new_ws = wb.create_sheet("NewSheet")
new_ws["A1"] = "Data"

wb.save("modified.xlsx")
EOF
```

**Warning**: Never open with `data_only=True` and then save — formulas are permanently replaced with their last-calculated values.

## Formulas vs. Hardcoded Values

Always write Excel formulas instead of computing values in Python and hardcoding results:

```python
# Wrong
sheet["B10"] = df["Sales"].sum()          # hardcodes 5000

# Right
sheet["B10"] = "=SUM(B2:B9)"             # stays dynamic
sheet["C5"] = "=(C4-C2)/C2"              # growth rate
sheet["D20"] = "=AVERAGE(D2:D19)"        # average
```

## Formula Recalculation

openpyxl writes formulas as strings without evaluating them. To recalculate, use LibreOffice:

```bash
soffice --headless --calc --infilter="Calc MS Excel 2007 XML" \
    --convert-to xlsx output.xlsx

# Or via Python
uv run --with subprocess-run - <<'EOF'
import subprocess
subprocess.run([
    "soffice", "--headless", "--calc",
    "--infilter=Calc MS Excel 2007 XML",
    "--convert-to", "xlsx", "output.xlsx"
])
EOF
```

Arch package: `sudo pacman -S libreoffice-fresh`

After recalculating, verify there are no formula errors (#REF!, #DIV/0!, #VALUE!, #N/A, #NAME?) before declaring success.

## Financial Model Conventions

When building financial models, follow industry-standard color coding (unless the file has its own established conventions — always match existing templates):

| Color | Meaning |
|-------|---------|
| Blue text `RGB(0,0,255)` | Hardcoded inputs users will change |
| Black text `RGB(0,0,0)` | All formulas and calculations |
| Green text `RGB(0,128,0)` | Links from other worksheets in the same workbook |
| Red text `RGB(255,0,0)` | External links to other files |
| Yellow background `RGB(255,255,0)` | Key assumptions needing attention |

### Number Formatting
- **Years**: Format as text strings (`"2024"` not `"2,024"`)
- **Currency**: `$#,##0` — always include units in headers (`"Revenue ($mm)"`)
- **Zeros**: Use `$#,##0;($#,##0);-` so zeros display as `-`
- **Percentages**: `0.0%` (one decimal)
- **Negative numbers**: Parentheses `(123)`, not minus `-123`

### Formula Rules
- Place all assumptions (growth rates, margins, multiples) in separate cells; reference them — never hardcode inside formulas
- Document hardcoded values in adjacent cells: `Source: Company 10-K, FY2024, Page 45`
- Check for circular references before saving

## Library Selection Guide

| Use | Library |
|-----|---------|
| Data analysis, bulk operations | pandas |
| Formulas, formatting, Excel-specific | openpyxl |
| Both | pandas + openpyxl |

## Quick Reference

| Task | uv invocation |
|------|---------------|
| Read / analyze | `uv run --with pandas` |
| Create with formulas | `uv run --with openpyxl` |
| Full workflow | `uv run --with pandas --with openpyxl` |
