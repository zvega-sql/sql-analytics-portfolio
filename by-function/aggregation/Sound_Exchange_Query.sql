-- ============================================================
-- Query:       SoundExchange Earnings (Digital Performance Rights)
-- Table:       [operations].[SoundExchangeEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized SoundExchange earnings for a
--              specific artist, grouped by track, licensee, usage
--              type, and source file. Derives the artist's role
--              (Featured Artist vs. Rights Owner) and the payment
--              date from the import filename.
-- Notes:       SoundExchange files include role information encoded
--              as a single letter in the filename immediately before
--              '_Detail':
--                'A' → Featured Artist payment
--                'R' → Rights Owner payment
--              This allows a single artist to have earnings under
--              both roles across different import files.
--
--              Payment_Date is parsed from a 'MMMYYYY' pattern in
--              the filename (e.g., 'JAN2024'). The 3-letter month
--              abbreviation and 4-digit year are extracted via
--              PATINDEX, then reassembled as 'MMM 01 YYYY' so
--              TRY_CONVERT can parse it as a DATE.
--
--              [period] and [type] are bracketed because PERIOD
--              and TYPE are reserved words in SQL Server.
-- ============================================================

SELECT
    Track_Name, 
    artist_name, 
    Licensee_Name,          -- Digital service that paid SoundExchange (e.g., Pandora, Sirius)
    ISRC, 
    Release_UPC, 
    [period],               -- Bracketed: PERIOD is a reserved word
    [type],                 -- Bracketed: TYPE is a reserved word

    -- Derive artist role from the character immediately before '_Detail' in the filename.
    -- SoundExchange encodes 'A' (Featured Artist) or 'R' (Rights Owner) at this position.
    CASE 
        WHEN SUBSTRING(IMPORT_FILENAME, 
            CHARINDEX('_Detail', IMPORT_FILENAME) - 1, 1) = 'A' THEN 'Featured Artist'
        WHEN SUBSTRING(IMPORT_FILENAME, 
            CHARINDEX('_Detail', IMPORT_FILENAME) - 1, 1) = 'R' THEN 'Rights Owner'
        ELSE 'Unknown'
    END AS Role_Type,

    SUM(Your_Payment_Amount) AS Your_Payment_Amount, 
    IMPORT_FILENAME,

    -- Parse payment date from a 'MMMYYYY' pattern in the filename (e.g., 'JAN2024').
    -- Extracts the 3-letter month and 4-digit year, then builds 'MMM 01 YYYY'
    -- so TRY_CONVERT can interpret it as a date string.
    TRY_CONVERT(DATE, 
        -- Extract 3-letter month abbreviation (immediately after the leading underscore)
        SUBSTRING(IMPORT_FILENAME, 
            PATINDEX('%_[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9]_%', IMPORT_FILENAME) + 1, 
            3)
        + ' 01 '  -- Insert day to form a parseable date string
        -- Extract 4-digit year (follows immediately after the month abbreviation)
        + SUBSTRING(IMPORT_FILENAME, 
            PATINDEX('%_[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9]_%', IMPORT_FILENAME) + 4, 
            4)
    ) AS Payment_Date

FROM
    [operations].[SoundExchangeEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    Track_Name, 
    artist_name, 
    Licensee_Name, 
    ISRC, 
    Release_UPC, 
    [period], 
    [type], 
    IMPORT_FILENAME
