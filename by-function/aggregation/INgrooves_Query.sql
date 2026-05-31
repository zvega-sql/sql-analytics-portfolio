-- ============================================================
-- Query:       INgrooves Earnings
-- Table:       [operations].[INGroovesEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized INgrooves earnings for a specific
--              artist, grouped by period, song, retailer, territory,
--              and source file.
-- Notes:       [Period] is bracketed because PERIOD is a reserved
--              word in SQL Server. It is stored as a native date or
--              formatted string depending on the file version.
--              USDOLLAR_AFTER_FEES represents the net amount after
--              INgrooves' distribution fees have been deducted.
-- ============================================================

SELECT
    [Period],                           -- Statement period; bracketed (reserved word)
    SONG,
    RETAILER,                           -- DSP or distribution channel
    ARTIST,
    UPC_EAN,
    ISRC,
    TERRITORY,
    IMPORT_FILENAME,
    SUM(USDOLLAR_AFTER_FEES) AS AMOUNT_AFTER_FEES  -- Net earnings after INgrooves fees
FROM
    [operations].[INGroovesEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    [Period],
    SONG,
    RETAILER,
    ARTIST,
    UPC_EAN,
    ISRC,
    TERRITORY,
    IMPORT_FILENAME
