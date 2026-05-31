-- ============================================================
-- Query:       Virgin Music Group Earnings
-- Table:       [operations].[VirginMusicGroupEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Virgin Music Group earnings for a
--              specific artist, grouped by period, retailer, label,
--              track metadata, and territory. Derives a proper
--              first-of-month DATE from Virgin's proprietary period
--              string format.
-- Notes:       [period] is Virgin's internal period identifier, stored
--              as a fixed-length proprietary string. The date is
--              reconstructed by reading two substrings from known
--              positions within it:
--                SUBSTRING([period], 5, 2) → 2-digit year  (YY)
--                SUBSTRING([period], 2, 2) → 2-digit month (MM)
--              These are assembled into 'YYYY-MM-01' using '20' + YY
--              as the full year. TRY_CAST handles any rows where the
--              [period] string does not match the expected structure.
--
--              Important: [period] appears in the GROUP BY but NOT
--              in the SELECT list — only the derived Period_Date is
--              returned. Grouping on the raw [period] ensures rows
--              with identical derived dates but different raw values
--              are not collapsed.
--
--              AMOUNT_AFTER_FEES is the net amount after Virgin Music
--              Group's distribution fees have been deducted.
--              UPCEAN stores both UPC and EAN barcodes in a single
--              field depending on the release's country of origin.
-- ============================================================

SELECT
    -- Reconstruct a first-of-month DATE from Virgin's proprietary period format.
    -- Positions 5-6 hold the 2-digit year; positions 2-3 hold the 2-digit month.
    TRY_CAST(
        '20' + SUBSTRING([period], 5, 2)   -- YY → YYYY (e.g., '24' → '2024')
        + '-' + SUBSTRING([period], 2, 2)  -- MM (e.g., '03' → March)
        + '-01'
    AS DATE) AS [Period_Date],

    RETAILER,           -- DSP or distribution channel
    LABEL,
    Artist,
    ALBUM,
    UPCEAN,             -- UPC (North America) or EAN (international) barcode
    song,
    isrc,
    territory,
    SUM(AMOUNT_AFTER_FEES) AS Amount_After_Fees,  -- Net earnings after Virgin's fees
    IMPORT_FILENAME

FROM
    [operations].[VirginMusicGroupEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    [period],           -- Raw period string used for grouping (not shown in SELECT)
    RETAILER,
    LABEL,
    Artist,
    ALBUM,
    UPCEAN,
    song,
    isrc,
    territory,
    IMPORT_FILENAME
