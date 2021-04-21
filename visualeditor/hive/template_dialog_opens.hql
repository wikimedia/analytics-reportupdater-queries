WITH all_events AS (
    SELECT
        wiki,
        event.action,
        event.user_id,
        CASE WHEN event.user_id = 0 THEN 'anonymous'
            WHEN event.user_editcount > 1000 THEN '1000_or_more_edits'
            WHEN event.user_editcount > 100 THEN '100-999_edits'
            WHEN event.user_editcount > 4 THEN '5-99_edits'
            WHEN event.user_editcount > 0 THEN '1-4_edits'
            ELSE '0_edits'
        END edit_count_bucket
    FROM
        event.VisualEditorFeatureUse
    WHERE
        event.feature = 'transclusion'
        and useragent.is_bot = false
        and event.is_oversample = false
        and year = {year}
        and month = {month}
        and day = {day}
)

SELECT
    '{from_date}' AS `date`,
    wiki,
    edit_count_bucket,
    -- Compensate for sampling by multiplying by 1 / 6.25% = 16
    SUM(
        CASE
            WHEN action = 'window-open-from-tool' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_opens_from_menu,
    SUM(
        CASE
            WHEN action = 'window-open-from-sequence' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_opens_from_keyboard,
    SUM(
        CASE
            WHEN action = 'window-open-from-context'
                  OR action = 'window-open-from-command' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_opens_from_existing,
    SUM(
        CASE
            WHEN action = 'dialog-done' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_successes,
    SUM(
        CASE
            WHEN action = 'dialog-abort' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_aborts
FROM
    all_events
GROUP BY
    wiki,
    edit_count_bucket;
