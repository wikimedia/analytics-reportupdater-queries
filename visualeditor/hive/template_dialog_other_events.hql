WITH all_events AS (
    SELECT
        wiki,
        event.action,
        event.user_id,
        event.user_editcount
    FROM
        event.VisualEditorFeatureUse
    WHERE
        event.feature = 'transclusion'
        and event.is_oversample = false
        and useragent.is_bot = false
        and year = {year}
        and month = {month}
        and day = {day}
),

bucketed_events AS (
    SELECT
        wiki,
        action,
        CASE WHEN user_id = 0 THEN 'anonymous'
            WHEN user_editcount > 1000 THEN '1000_or_more_edits'
            WHEN user_editcount > 100 THEN '100-999_edits'
            WHEN user_editcount > 4 THEN '5-99_edits'
            WHEN user_editcount > 0 THEN '1-4_edits'
            ELSE '0_edits'
        END edit_count_bucket
    FROM
        all_events
)

SELECT
    '{from_date}' AS `date`,
    wiki,
    edit_count_bucket,
    -- Compensate for sampling by multiplying by 1 / 6.25% = 16
    SUM(
        CASE
            WHEN action = 'edit-parameter-value' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_edit_parameter,
    SUM(
        CASE
            WHEN action = 'template-doc-link-click' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_doc_click
FROM
    bucketed_events
GROUP BY
    wiki,
    edit_count_bucket
