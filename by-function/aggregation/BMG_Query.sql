-- ============================================================
-- Query:       BMG Earnings
-- Table:       [operations].[BMGEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized BMG royalties for a specific
--              artist, grouped by song, source, country, and file.
--              Includes a derived distribution date parsed from
--              the import filename.
-- Notes:       BMG uses two distinct filename date formats:
--              1. Quarterly:  '...YYYY-QN...'  → maps Q1-Q4 to
--                 the first month of that quarter (01, 04, 07, 10)
--              2. Monthly:    '...YYYYMMx.csv' → reads YYYY and MM
--                 directly from the 6-digit date block.
--              TRY_CAST returns NULL for rows that match neither
--              pattern, which is expected for non-standard files.
--              ROYALTY_PAYABLE is stored as a string and must be
--              cast to FLOAT before aggregation.
-- ============================================================

SELECT
    song_title,
    payee_code,
    client_code,
    song_code,
    artist,
    source_name,
    royalty_country_description,
    isrc,
    import_filename,
    SUM(TRY_CONVERT(FLOAT, ROYALTY_PAYABLE)) AS Royalty_Payable,  -- Cast required; column stored as string

    -- Derive a first-of-month DATE from the import filename.
    -- Two filename patterns are handled:
    CASE
        -- Pattern 1: Quarterly format, e.g. '2024-Q3'
        -- Maps quarter number to the starting month of that quarter
        WHEN import_filename LIKE '%[0-9][0-9][0-9][0-9]-Q[1-4]%'
        THEN TRY_CAST(
            -- Extract the 4-digit year
            SUBSTRING(import_filename, PATINDEX('%[0-9][0-9][0-9][0-9]-Q[1-4]%', import_filename), 4)
            + '-'
            -- Map Q1→01, Q2→04, Q3→07, Q4→10 (first month of each quarter)
            + CASE SUBSTRING(import_filename, PATINDEX('%[0-9][0-9][0-9][0-9]-Q[1-4]%', import_filename) + 6, 1)
                WHEN '1' THEN '01'
                WHEN '2' THEN '04'
                WHEN '3' THEN '07'
                WHEN '4' THEN '10'
              END
            + '-01'
        AS DATE)

        -- Pattern 2: Monthly format, e.g. '202403X.csv' (6-digit YYYYMM block + letter suffix)
        WHEN import_filename LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][A-Z].csv'
        THEN TRY_CAST(
            -- Extract YYYY (first 4 digits of the 6-digit block)
            SUBSTRING(import_filename, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][A-Z].csv%', import_filename), 4)
            + '-'
            -- Extract MM (digits 5-6 of the 6-digit block)
            + SUBSTRING(import_filename, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][A-Z].csv%', import_filename) + 4, 2)
            + '-01'
        AS DATE)

        ELSE NULL  -- No recognizable date pattern in filename
    END AS Distribution_Date

FROM
    [operations].[BMGEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    song_title,
    payee_code,
    client_code,
    song_code,
    artist,
    source_name,
    royalty_country_description,
    isrc,
    import_filename
