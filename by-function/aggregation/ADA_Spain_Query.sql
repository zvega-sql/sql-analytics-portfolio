-- ============================================================
-- Query:       ADA Spain Earnings
-- Table:       [operations].[ADASpainEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized royalties from ADA Spain for a
--              specific artist, grouped by product, DSP, country,
--              ISRC, and source file.
-- Notes:       No date column is present in this table; period
--              context must be inferred from IMPORT_FILENAME.
-- ============================================================

SELECT
    Product_Title,
    Digital_Service_Provider_DSP_,  -- DSP name (column name retains raw header formatting)
    Country,
    DSP_Number,
    ISRC,
    IMPORT_FILENAME,
    SUM(Royalty_Payable) AS Royalty_Payable
FROM
    [operations].[ADASpainEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    Product_Title,
    Digital_Service_Provider_DSP_,
    Country,
    DSP_Number,
    ISRC,
    IMPORT_FILENAME
