import pandas as pd
from pathlib import Path

def split_workbook(xlsx_path, output_dir):
    xl = pd.ExcelFile(xlsx_path)
    for sheet in xl.sheet_names:
        df = xl.parse(sheet)
        if df.dropna(how="all").empty:
            continue
        period = extract_period(xlsx_path.stem)  # reuse from your other scripts
        out_name = f"{period} - {sheet}.csv"
        df.to_csv(Path(output_dir) / out_name, index=False)
