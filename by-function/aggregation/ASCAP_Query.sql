-- ============================================================
-- Query:       ASCAP Earnings
-- Table:       [operations].[ASCAPEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized ASCAP performance royalties for
--              a specific artist, grouped by work, music user,
--              territory, party, and source file.
-- Notes:       DOLLAR_AMOUNT and DOLLARS are two separate columns
--              that map to the same concept across different file
--              formats; COALESCE + SUM handles both safely.
--              Formatted_Date is parsed from the filename using a
--              fixed-position substring (7 chars ending 10 from EOF)
--              and appending '-01' to produce a valid DATE.
-- ============================================================

SELECT
    Work_Title, 
    MUSIC_USER, 
    TERRITORY, 
    Party_Name, 
    PARTY_ID,
    SERIES_NAME, 
    PROGRAM_NAME, 
    import_filename,

    -- Extract statement month from filename: pulls 'YYYY-MM' from a known
    -- position near the end of the filename, then appends '-01' for DATE cast
    TRY_CAST(
        SUBSTRING(import_filename, LEN(import_filename) - 10, 7) + '-01'
    AS DATE) AS Formatted_Date,

    -- ASCAP files may populate either DOLLAR_AMOUNT or DOLLARS depending on format;
    -- COALESCE treats NULL as 0 so both are captured in the sum
    SUM(COALESCE(DOLLAR_AMOUNT, 0) + COALESCE(DOLLARS, 0)) AS Total_Dollar

FROM 
    [operations].[ASCAPEarnings]
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY 
    Work_Title, 
    MUSIC_USER, 
    TERRITORY, 
    Party_Name, 
    PARTY_ID,
    SERIES_NAME, 
    PROGRAM_NAME, 
    IMPORT_FILENAME
