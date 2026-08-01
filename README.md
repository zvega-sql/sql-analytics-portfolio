# SQL Analytics Portfolio

Production SQL queries written for music royalty data analysis across 
multiple rights organizations and distributors.

## Environment
- **Database:** SQL Server (T-SQL)
- **Tools:** SSMS, Power Query (M), Excel Data Model, Python (pandas)

## What's in Here

### by-function/
Queries organized by the type of analytical problem they solve:
- `date-conversion/` — Normalizing inconsistent date formats across reporting sources
- `aggregation/` — Earnings rollups, multi-source SUM/GROUP BY logic
- `deduplication/` — Identifying and removing duplicate imports
- `data-cleaning/` — TRIM, COALESCE, null handling, REPLACE patterns

### by-source/
Same queries cross-referenced by the data source they target:
- SoundExchange, BMI, TuneCore, The Orchard, Kobalt

### utilities/
- PowerShell scripts for bulk file renaming and batch processing

## Notes
Proprietary values (artist IDs, internal identifiers) have been replaced 
with `[ARTIST_ID]` placeholders. Schema and table names reflect a real 
enterprise SQL Server environment.

### python/
Pandas rewrites of PowerShell and manual workflows, replacing COM automation
and file-by-file extraction with a few lines of pandas.

- `extract_apra_data.py` — Extracts royalty totals and remittance payments
  from APRA AMCOS PDF statements, previously a manual per-file process
- `convert_to_csv.py` — Batch-converts Excel/TXT files to CSV, pandas
  rewrite of Convert-XlsToCsv.ps1
- `split_onerpm_workbook.py` — Splits multi-tab ONErpm earnings workbooks
  into per-sheet CSVs, pandas rewrite of a COM-based splitter with retry
  handling
