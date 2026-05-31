-- ============================================================
-- Query:       Payor Keyword Search
-- Table:       [dbo].[Payor_Earnings]
-- Description: Ad-hoc search against the Payor_Earnings lookup
--              table to find records whose PAYOR_NAME contains a
--              specific keyword. Used to discover payor entries
--              before linking them to artist earnings, or to
--              audit how a given company's payments are labeled.
-- Usage:       Replace '%[PAYOR_KEYWORD]%' with the target keyword.
--              The % wildcards allow a match anywhere in the name
--              (prefix, suffix, or mid-string). LIKE is
--              case-insensitive by default on most SQL Server
--              collations.
-- ============================================================

SELECT *
FROM [dbo].[Payor_Earnings]
WHERE PAYOR_NAME LIKE '%[PAYOR_KEYWORD]%'   -- Swap keyword as needed; % = wildcard on both sides
