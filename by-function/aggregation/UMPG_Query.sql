-- ============================================================
-- Query:       Universal Music Publishing Group (UMPG) Earnings
-- Table:       [operations].[UMPGEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized UMPG publishing earnings for a
--              specific artist, grouped by payee, song, composer,
--              revenue source, country, period, and source file.
-- Notes:       PAYEE_CODE is UMPG's internal identifier for the
--              specific royalty payee on the account (useful when
--              an artist has multiple participant roles or sub-codes).
--              SOURCE_DESCRIPTION is UMPG's label for the revenue
--              type (e.g., performance, mechanical, sync, print).
--              COUNTRY_DESCRIPTION is the full country name as
--              UMPG reports it, not an ISO code.
--              [PERIOD] is bracketed because PERIOD is a reserved
--              word in SQL Server; it is stored in UMPG's native
--              period format (exact format varies by statement type).
-- ============================================================

SELECT
    PAYEE_CODE,             -- UMPG internal payee identifier
    SONG_TITLE,
    composer,
    SOURCE_DESCRIPTION,     -- Revenue type (e.g., performance, mechanical, sync)
    COUNTRY_DESCRIPTION,    -- Full country name as reported by UMPG
    [PERIOD],               -- Bracketed: PERIOD is a reserved word in SQL Server
    import_filename,
    SUM(ROYALTIES_PAYABLE) AS Total
FROM 
    [operations].[UMPGEarnings]
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY 
    PAYEE_CODE,
    song_title,
    composer,
    SOURCE_DESCRIPTION,
    COUNTRY_DESCRIPTION,
    [PERIOD],
    import_filename
