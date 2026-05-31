# sql-analytics-portfolio
SQL queries for music royalty data analysis, covering PROs, distributors, and publishers.

# SQL Analytics Portfolio

Production SQL queries written for music royalty data analysis across 
multiple rights organizations and distributors.

## Environment
- **Database:** SQL Server (T-SQL)
- **Tools:** SSMS, Power Query (M), Excel Data Model

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