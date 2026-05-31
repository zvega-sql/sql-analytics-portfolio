-- ============================================================
-- Query:       TuneCore Earnings
-- Table:       [operations].[TunecoreEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized TuneCore earnings for a specific
--              artist, grouped by song, store, country, sale period,
--              posted date, and source file.
-- Notes:       TuneCore provides two date columns with distinct
--              meanings:
--                sales_period  → the month/period the streams or
--                               sales occurred (when usage happened)
--                posted_date   → the date TuneCore posted/credited
--                               the earnings to the account (when
--                               money moved); typically lags sales_period
--                               by one or more months.
--              Both are retained for full audit traceability.
--              optional_isrc reflects that TuneCore does not require
--              ISRC registration for distribution; this column may
--              be NULL or blank for older releases.
--              Both are retained in the GROUP BY so rows are not
--              collapsed across different posting cycles for the
--              same sales period.
-- ============================================================

SELECT
    song_title,
    artist,
    upc,
    optional_isrc,      -- ISRC is optional in TuneCore; may be NULL for older releases
    store_name,         -- DSP or retail channel (e.g., Spotify, iTunes)
    country_of_sale,
    sales_period,       -- Period in which the usage/sale occurred
    posted_date,        -- Date TuneCore credited the earnings (typically lags sales_period)
    import_filename,
    SUM(total_earned) AS Total
FROM 
    [operations].[TunecoreEarnings]
WHERE 
    Artist_ID = [ARTIST_ID] 
GROUP BY 
    song_title,
    artist,
    upc,
    optional_isrc,
    store_name,
    country_of_sale,
    sales_period,
    posted_date,
    import_filename
