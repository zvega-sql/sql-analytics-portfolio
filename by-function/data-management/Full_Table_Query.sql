-- ============================================================
-- Query:       Full Table Pull — Kobalt Earnings
-- Table:       [operations].[KobaltEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns all raw columns and rows for a specific
--              artist from the Kobalt earnings table. Used for
--              ad-hoc investigation, column discovery, or when
--              building a new grouped query against this table.
-- ⚠ Note:      SELECT * should be replaced with explicit column
--              names for any production or recurring use to avoid
--              issues if the table schema changes. Filter on
--              additional columns (e.g., date range, territory)
--              once the full dataset has been reviewed.
-- ============================================================

SELECT * 
FROM [operations].[KobaltEarnings] 
WHERE Artist_ID = [ARTIST_ID]
