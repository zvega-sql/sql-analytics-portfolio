-- ============================================================
-- Query:       PRS for Music Earnings (UK Performing Rights)
-- Table:       [operations].[PRSEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized PRS performance royalties for a
--              specific artist, grouped by usage, work title,
--              interested parties, ISWC, territory, and source file.
--              Also extracts the PRS account number and statement
--              date from the import filename.
-- Notes:       PRS filenames embed two pieces of metadata:
--
--              Account_Number — extracted by locating a pattern of
--              '_<digits>_YYYYMM' near the end of the filename and
--              reading the segment between the two underscores.
--              Returns NULL if the pattern is absent.
--
--              Distribution_Date — derived from two possible filename
--              date formats:
--                Format 1: '...YYYY-MM...' → reads 7 chars directly,
--                          appends '-01' for a valid DATE.
--                Format 2: '...YYYYMM...'  → reads YYYY (4 chars)
--                          and MM (2 chars) separately, assembles
--                          'YYYY-MM-01'.
--              MAX() is used because Distribution_Date is a derived
--              expression and is not in the GROUP BY; since it is
--              deterministic per filename, MAX() is safe here.
--
--              IP1 and IP2 are PRS Interested Party identifiers
--              (writer/publisher CAE/IPI numbers).
--              ISWC is the International Standard Musical Work Code.
-- ============================================================

SELECT 
    USAGE_NARRATIVE,        -- Description of how the work was performed/used
    WORK_TITLE, 
    IP1,                    -- Primary interested party (writer/publisher identifier)
    IP2,                    -- Secondary interested party
    ISWC,                   -- International Standard Musical Work Code
    TERRITORY_NAME, 
    SUM(AMOUNT_PERFORMANCE_REVENUE) AS Amount_Performance_Revenue, 
    IMPORT_FILENAME,

    -- Extract PRS account number from the filename.
    -- Pattern: '_<accountNum>_YYYYMM' near the end of the filename.
    -- Reads the token between the two underscores flanking the account number.
    CASE 
        WHEN PATINDEX('%_[0-9]%_20[0-9][0-9][0-1][0-9]%', IMPORT_FILENAME) > 0 THEN
            SUBSTRING(
                IMPORT_FILENAME, 
                LEN(LEFT(IMPORT_FILENAME, PATINDEX('%_[0-9]%_20[0-9][0-9][0-1][0-9]%', IMPORT_FILENAME))) + 1,
                CHARINDEX('_', IMPORT_FILENAME, PATINDEX('%_[0-9]%_20[0-9][0-9][0-1][0-9]%', IMPORT_FILENAME) + 1) 
                - (PATINDEX('%_[0-9]%_20[0-9][0-9][0-1][0-9]%', IMPORT_FILENAME) + 1)
            )
        ELSE NULL 
    END AS Account_Number,

    -- Derive the distribution date from two possible filename date patterns.
    -- MAX() is required because this computed value isn't in the GROUP BY;
    -- it is deterministic per filename, so MAX() safely returns the single value.
    MAX(TRY_CAST(
        CASE 
            -- Format 1: 'YYYY-MM' already hyphen-separated in the filename
            WHEN PATINDEX('%20[0-9][0-9]-[0-1][0-9]%', IMPORT_FILENAME) > 0 THEN
                SUBSTRING(IMPORT_FILENAME, PATINDEX('%20[0-9][0-9]-[0-1][0-9]%', IMPORT_FILENAME), 7) + '-01'

            -- Format 2: 'YYYYMM' compact format — read year and month separately
            WHEN PATINDEX('%_20[0-9][0-9][0-1][0-9][0-9A-Z]_%', IMPORT_FILENAME) > 0 THEN
                SUBSTRING(IMPORT_FILENAME, PATINDEX('%_20[0-9][0-9][0-1][0-9][0-9A-Z]_%', IMPORT_FILENAME) + 1, 4)  -- YYYY
                + '-'
                + SUBSTRING(IMPORT_FILENAME, PATINDEX('%_20[0-9][0-9][0-1][0-9][0-9A-Z]_%', IMPORT_FILENAME) + 5, 2) -- MM
                + '-01'

            ELSE NULL 
        END 
    AS DATE)) AS Distribution_Date

FROM 
    [operations].[PRSEarnings]
WHERE 
    Artist_Id = [ARTIST_ID]
GROUP BY 
    USAGE_NARRATIVE, 
    WORK_TITLE, 
    IP1, 
    IP2, 
    ISWC, 
    TERRITORY_NAME, 
    IMPORT_FILENAME
