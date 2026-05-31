-- ============================================================
-- Query:       Sonosuite Earnings
-- Table:       [operations].[SonosuiteEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Sonosuite earnings for a specific
--              artist, grouped by country, track, channel, label,
--              release, sales month, and source file.
-- Notes:       SALES_DATE is a datetime column; FORMAT(..., 'yyyy-MM')
--              truncates it to year-month for grouping, avoiding
--              splits caused by differing day or time components.
--              ROYALTIES_CLIENT_CURRENCY is stored as a string and
--              is cast to DECIMAL(18,4) before aggregation to
--              preserve cent-level precision.
--              TENANT_NAME identifies the Sonosuite sub-account or
--              label tenant the earnings are attributed to.
--              CONFIRMATION_DATE is the date Sonosuite confirmed
--              the payment, which may differ from the sales period.
-- ============================================================

SELECT
    COUNTRY, 
    ISRC, 
    ARTIST, 
    CHANNEL_NAME,           -- DSP or distribution channel
    LABEL_NAME, 
    RELEASE_TITLE, 
    TRACK_TITLE, 
    TENANT_NAME,            -- Sonosuite sub-account or label tenant

    -- Truncate SALES_DATE to year-month to prevent grouping splits
    -- caused by differing day or time values within the same period
    FORMAT(SALES_DATE, 'yyyy-MM') AS SALES_DATE,

    CONFIRMATION_DATE,      -- Date Sonosuite confirmed the payment

    -- Cast required: ROYALTIES_CLIENT_CURRENCY is stored as a string;
    -- DECIMAL(18,4) preserves precision through the aggregation
    SUM(CAST(ROYALTIES_CLIENT_CURRENCY AS DECIMAL(18, 4))) AS ROYALTIES_CLIENT_CURRENCY,

    IMPORT_FILENAME

FROM [operations].[SonosuiteEarnings] 
WHERE Artist_ID = [ARTIST_ID]
GROUP BY
    COUNTRY, 
    ISRC, 
    ARTIST, 
    CHANNEL_NAME, 
    LABEL_NAME, 
    RELEASE_TITLE, 
    TRACK_TITLE, 
    TENANT_NAME, 
    FORMAT(SALES_DATE, 'yyyy-MM'),   -- Must match the SELECT expression exactly
    CONFIRMATION_DATE,
    IMPORT_FILENAME
