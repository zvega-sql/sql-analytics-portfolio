-- ============================================================
-- Query:       Curve Royalties Earnings
-- Table:       [operations].[CurveRoyaltiesEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Curve Royalties earnings for a
--              specific artist, grouped by contract, source,
--              territory, track metadata, and transaction date.
--              Includes a derived distribution date built from the
--              quarterly period string embedded in the filename.
-- Notes:       Curve filenames include a period string in the format
--              'YYYY - QN' (e.g., '2024 - Q3'). CROSS APPLY extracts
--              this 9-character segment via PATINDEX, and the CASE
--              expression maps Q1–Q4 to the first month of each
--              quarter to produce a valid first-of-month DATE.
-- ============================================================

SELECT
    [CONTRACT_NAME],           -- Curve contract identifier
    SOURCE,                    -- Revenue source/usage type
    TERRITORY, 
    TRACK_TITLE, 
    TRACK_ARTIST, 
    TRACK_LABEL, 
    isrc, 
    barcode,                   -- UPC/EAN barcode for the release
    cat_no,                    -- Catalogue number
    transaction_date,          -- Date of the individual transaction
    SUM(NET_PAYABLE) AS NET_PAYABLE, 

    Extracted.Period AS Distribution_Period,  -- Raw period string from filename, e.g. '2024 - Q3'

    -- Convert the 'YYYY - QN' period to a first-of-month DATE
    -- Q1→January, Q2→April, Q3→July, Q4→October
    TRY_CAST(
        LEFT(Extracted.Period, 4) + '-'   -- Extract the 4-digit year
        + CASE RIGHT(Extracted.Period, 1)
            WHEN '1' THEN '01'            -- Q1 → January
            WHEN '2' THEN '04'            -- Q2 → April
            WHEN '3' THEN '07'            -- Q3 → July
            WHEN '4' THEN '10'            -- Q4 → October
            ELSE '01'                     -- Fallback to January if unrecognized
          END
        + '-01'
    AS DATE) AS Distribution_Date,

    IMPORT_FILENAME

FROM
    [operations].[CurveRoyaltiesEarnings]

-- CROSS APPLY extracts the 'YYYY - QN' pattern from the filename once,
-- making it available both as a GROUP BY column and in the CASE expression
-- without repeating the PATINDEX/SUBSTRING logic
CROSS APPLY (
    SELECT SUBSTRING(
        IMPORT_FILENAME, 
        PATINDEX('%[0-9][0-9][0-9][0-9] - Q[0-9]%', IMPORT_FILENAME),  -- Locate 'YYYY - QN'
        9  -- Capture exactly 9 characters: 'YYYY - QN'
    ) AS Period
) AS Extracted

WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    [CONTRACT_NAME], 
    SOURCE, 
    TERRITORY, 
    TRACK_TITLE, 
    TRACK_ARTIST, 
    TRACK_LABEL, 
    isrc, 
    barcode, 
    cat_no, 
    transaction_date, 
    Extracted.Period,
    IMPORT_FILENAME
