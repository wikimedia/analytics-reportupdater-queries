WITH events AS (
SELECT
    event.editor_interface,
    event.user_id,
    event.user_editcount,
    event.action,
    wiki
FROM
    event.EditAttemptStep
WHERE
    event.action = 'ready'
    AND event.editor_interface IN (
        'visualeditor',
        'wikitext-2017'
    )
    AND useragent.is_bot = false
    AND event.is_oversample = false
    AND year = {year}
    AND month = {month}
    AND day = {day}
),
bucketed_events AS (
    SELECT
        wiki,
        action,
        CASE WHEN user_id = 0 THEN 'anonymous'
            WHEN user_editcount >= 1000 THEN '1000_or_more_edits'
            WHEN user_editcount >= 100 THEN '100-999_edits'
            WHEN user_editcount >= 5 THEN '5-99_edits'
            WHEN user_editcount >= 1 THEN '1-4_edits'
            ELSE '0_edits'
        END AS edit_count_bucket
    FROM
        events
)

SELECT
    '{from_date}' AS `date`,
    wiki,
    edit_count_bucket,
    -- Multiply by 16 to compensate for sampling.
    COUNT(*) * 16 AS visual_editor_sessions
FROM
    bucketed_events
GROUP BY
    wiki,
    edit_count_bucket;
