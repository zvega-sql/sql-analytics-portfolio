"""
Batch-converts .xlsx, .xls, .xlsm, and .txt files in a folder to .csv.
Pandas rewrite of Convert-XlsToCsv.ps1.

Requires: pandas, openpyxl (xlsx/xlsm), xlrd (legacy .xls)
    pip install pandas openpyxl xlrd
"""

import csv
from pathlib import Path

import pandas as pd

# ── CONFIGURE ────────────────────────────────────────────
# Point this at any folder containing Excel/TXT files to convert.
FOLDER_PATH = r"C:\Users\example\Documents\SourceFiles"
# ─────────────────────────────────────────────────────────

EXCEL_EXTS = {".xlsx", ".xls", ".xlsm"}
VALID_EXTS = EXCEL_EXTS | {".txt"}


def detect_delimiter(txt_path: Path) -> str:
    """Read the first line and pick whichever delimiter appears most often.
    Mirrors the original script's tab/semicolon/comma/pipe count-and-compare."""
    with open(txt_path, "r", encoding="utf-8", errors="replace") as f:
        first_line = f.readline()

    counts = {
        "\t": first_line.count("\t"),
        ";": first_line.count(";"),
        ",": first_line.count(","),
        "|": first_line.count("|"),
    }
    return max(counts, key=counts.get)


def convert_file(path: Path) -> tuple[bool, str]:
    csv_path = path.with_suffix(".csv")

    try:
        if path.suffix == ".txt":
            delimiter = detect_delimiter(path)
            df = pd.read_csv(path, sep=delimiter, engine="python")
        else:
            # First sheet by default, same as opening the workbook with no
            # sheet specified. Point sheet_name= at a name if you need a
            # specific tab, e.g. "Digital Sales Details".
            df = pd.read_excel(path)

        df.to_csv(csv_path, index=False, quoting=csv.QUOTE_MINIMAL)
        return True, ""
    except Exception as e:
        return False, str(e)


def main():
    folder = Path(FOLDER_PATH)

    if not folder.exists():
        print("STOPPING: Folder not found.")
        return

    files = sorted(p for p in folder.iterdir() if p.suffix.lower() in VALID_EXTS)

    if not files:
        print("STOPPING: No Excel or TXT files found.")
        return

    print(f"Found {len(files)} file(s).")

    for file in files:
        print(f"  Converting: {file.name} ... ", end="")
        ok, error = convert_file(file)
        print("OK" if ok else f"ERROR: {error}")

    print("Process complete.")


if __name__ == "__main__":
    main()
