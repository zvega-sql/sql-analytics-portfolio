-- ============================================================
-- Query:       STEM Earnings
-- Table:       [operations].[STEMEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized STEM earnings for a specific
--              artist, grouped by ingest period, track metadata,
--              territory, platform, and source file.
-- Notes:       STEM stores the statement period as separate integer
--              year (ingest_year) and month (ingest_month) columns
--              rather than a single date. DATEFROMPARTS reconstructs
--              these into a proper DATE for downstream filtering
--              or sorting.
--              [platform] is bracketed because PLATFORM is a
--              reserved word in some SQL Server contexts.
--              ARTISTS may contain multiple featured artists as a
--              delimited string, depending on how STEM formats the
--              field in their exports.
-- ============================================================

SELECT
    import_filename,
    ingest_year,            -- Integer year of the earnings period
    ingest_month,           -- Integer month of the earnings period
    -- Reconstruct a proper DATE from the split year/month columns
    DATEFROMPARTS(ingest_year, ingest_month, 1) AS ingest_date,
    upc,
    isrc,
    title,
    ARTISTS,                -- May contain multiple artists as a delimited string
    territory_code,
    [platform],             -- DSP or streaming platform; bracketed (reserved word)
    SUM(net_earnings) AS net_earnings
FROM
    [operations].[STEMEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    import_filename,
    ingest_year,
    ingest_month,
    upc,
    isrc,
    title,
    ARTISTS,
    territory_code,
    [platform]
