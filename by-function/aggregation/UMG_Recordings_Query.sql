-- ============================================================
-- Query:       UMG Recordings Earnings
-- Table:       [operations].[UMGRecordingsEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized UMG Recordings earnings for a
--              specific artist, grouped by account, accounting
--              quarter, title, revenue source, and DSP.
-- Notes:       IMPORT_FILENAME is intentionally excluded from this
--              query. UMG Recordings data may be consolidated across
--              multiple files for the same period, making filename-
--              level grouping less meaningful here; the accounting
--              quarter (acct_qtr) serves as the period dimension.
--              acct_no is UMG's internal account number identifying
--              the specific royalty account or deal.
--              acct_qtr is the accounting quarter (format varies;
--              may be 'YYYY-QN' or a UMG-specific period string).
--              source describes the revenue type or income category
--              as UMG classifies it internally (e.g., streaming,
--              physical, sync).
-- ============================================================

SELECT
    acct_no,    -- UMG internal account/deal number
    acct_qtr,   -- Accounting quarter for the earnings period
    title,
    source,     -- UMG revenue category (e.g., streaming, physical, sync)
    DSP,
    SUM(net_roy_earn) AS Net_Roy_Earn   -- Net royalty earnings after UMG deductions
FROM
    [operations].[UMGRecordingsEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    acct_no,
    acct_qtr,
    title,
    source,
    DSP
