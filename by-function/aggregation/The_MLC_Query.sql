-- ============================================================
-- Query:       The MLC Earnings (Mechanical Licensing Collective)
-- Table:       [operations].[TheMLCEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized mechanical royalty earnings from
--              The MLC for a specific artist, grouped by work title,
--              writer list, DSP, distribution identifier, territory,
--              and source file.
-- Notes:       The MLC administers blanket mechanical licenses for
--              digital music services in the United States under the
--              Music Modernization Act. DISTRIBUTED_AMOUNT reflects
--              the mechanical royalty allocated to this artist after
--              The MLC's matching and distribution process.
--              DISTRIBUTION_IDENTIFIER is The MLC's internal batch
--              or distribution run identifier, useful for tracing
--              a specific payment back to its source statement.
--              No date column is present in this table; period
--              context must be inferred from IMPORT_FILENAME.
-- ============================================================

SELECT
    WORK_PRIMARY_TITLE,         -- Song/work title as registered with The MLC
    WORK_WRITER_LIST,           -- Pipe- or comma-delimited list of writers on the work
    DSP_NAME,                   -- Digital service provider reporting the mechanical usage
    DISTRIBUTION_IDENTIFIER,    -- MLC internal ID for the distribution batch/run
    TERRITORY,
    import_filename,
    SUM(DISTRIBUTED_AMOUNT) AS DISTRIBUTED_AMOUNT
FROM 
    [operations].[TheMLCEarnings]
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY 
    WORK_PRIMARY_TITLE,
    WORK_WRITER_LIST,
    DSP_NAME,
    DISTRIBUTION_IDENTIFIER,
    TERRITORY,
    IMPORT_FILENAME
