-- ============================================================
-- Query:       CD Baby Earnings
-- Table:       [operations].[CDBabyEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized CD Baby earnings for a specific
--              artist, grouped by track, distribution partner,
--              country, and report date.
-- Notes:       REPORT_DATE is stored as a native date column in
--              this table, so no string parsing is required.
--              PARTNER_NAME corresponds to the DSP or distributor
--              that originated the sale.
-- ============================================================

SELECT
    track_name,
    partner_name,       -- DSP or sub-distributor (e.g., Spotify, Apple Music)
    delivery_country,
    report_date,        -- Statement period date; stored as DATE in this table
    SUM(SUBTOTAL) AS Total
FROM
    [operations].[CDBabyEarnings]
WHERE 
    Artist_Id = [ARTIST_ID]
GROUP BY 
    track_name,
    partner_name,
    delivery_country,
    report_date
