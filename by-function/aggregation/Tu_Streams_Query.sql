-- ============================================================
-- Query:       Tu Streams Earnings
-- Table:       [operations].[TuStreamsEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Tu Streams earnings for a specific
--              artist, grouped by reporting period, territory, track,
--              and release metadata. Derives the DSP name and a
--              proper reporting date from the filename and the raw
--              period string respectively.
-- Notes:
--   DSP Extraction:
--     Tu Streams filenames follow a pattern:
--       ..._Tu-Streams_<DSP>-<something>-<date>.csv
--     The logic locates 'Tu-Streams_' in the filename and takes
--     everything after it, then removes a trailing segment by
--     finding the hyphen that sits 10 characters from the end of
--     that substring (using REVERSE + CHARINDEX). This isolates
--     the DSP portion of the filename between 'Tu-Streams_' and
--     the last meaningful separator.
--
--   Reporting_Date:
--     REPORTING_PERIOD is stored as 'Month-YYYY' (e.g., 'January-2024').
--     - RIGHT(REPORTING_PERIOD, 4) extracts the 4-digit year as an INT.
--     - The MONTH() call converts the full string to a DATE after
--       replacing '-' with ' ' (→ '01 January 2024'), then reads the
--       month number from that intermediate DATE.
--     - DATEFROMPARTS assembles year + month + 1 into a proper DATE.
-- ============================================================

SELECT
    IMPORT_FILENAME,
    REPORTING_PERIOD,   -- Raw period string, e.g., 'January-2024'

    -- Extract the DSP name from the filename.
    -- Locates 'Tu-Streams_' and takes the substring following it,
    -- then strips the trailing segment from the last relevant hyphen
    -- (searching backward 10 chars from the end via REVERSE + CHARINDEX).
    LEFT(
        SUBSTRING(
            IMPORT_FILENAME,
            CHARINDEX('Tu-Streams_', IMPORT_FILENAME) + LEN('Tu-Streams_'),
            LEN(IMPORT_FILENAME)
        ),
        LEN(
            SUBSTRING(
                IMPORT_FILENAME,
                CHARINDEX('Tu-Streams_', IMPORT_FILENAME) + LEN('Tu-Streams_'),
                LEN(IMPORT_FILENAME)
            )
        ) - CHARINDEX(
                '-',
                REVERSE(
                    SUBSTRING(
                        IMPORT_FILENAME,
                        CHARINDEX('Tu-Streams_', IMPORT_FILENAME) + LEN('Tu-Streams_'),
                        LEN(IMPORT_FILENAME)
                    )
                ),
                10  -- Search for the hyphen starting 10 chars from the end (reversed)
            )
    ) AS DSP,

    -- Convert 'Month-YYYY' period string to a first-of-month DATE:
    --   RIGHT(4)            → extract 4-digit year as INT
    --   REPLACE('-',' ')    → 'January 2024', prepend '01 ' → '01 January 2024'
    --   CAST AS DATE        → parse the full date, then MONTH() reads the month number
    --   DATEFROMPARTS       → assemble year, month, 1 into a proper DATE
    DATEFROMPARTS(
        CAST(RIGHT(REPORTING_PERIOD, 4) AS INT),
        MONTH(CAST('01 ' + REPLACE(REPORTING_PERIOD, '-', ' ') AS DATE)),
        1
    ) AS Reporting_Date,

    TERRITORY,
    UPC,
    ISRC,
    TRACK_TITLE,
    release_title,
    LABEL_NAME,
    ARTIST,
    SUM(NET_EARNINGS) AS Net_Earnings

FROM [operations].[TuStreamsEarnings]
WHERE Artist_ID = [ARTIST_ID]
GROUP BY
    IMPORT_FILENAME,
    REPORTING_PERIOD,
    TERRITORY,
    UPC,
    ISRC,
    TRACK_TITLE,
    release_title,
    LABEL_NAME,
    ARTIST
