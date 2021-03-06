WITH events AS (
    SELECT
        wiki,
        event.action,
        CASE
            WHEN event.user_id = 0 THEN 'anonymous'
            -- TODO: after the user_edit_count_bucket producer is fully migrated, probably in
            -- wmf/1.36.0-wmf.29, we can remove transitional logic and trust the bucket label.
            WHEN event.user_edit_count_bucket IS NOT null THEN event.user_edit_count_bucket
            WHEN event.user_edit_count >= 1000 THEN '1000+ edits'
            WHEN event.user_edit_count >= 100 THEN '100-999 edits'
            WHEN event.user_edit_count >= 5 THEN '5-99 edits'
            WHEN event.user_edit_count >= 1 THEN '1-4 edits'
            WHEN event.user_edit_count = 0 THEN '0 edits'
            ELSE 'unknown'
        END AS edit_count_bucket
    FROM
        event.TemplateDataEditor
    WHERE
        useragent.is_bot = false
        AND year = {year}
        AND month = {month}
        AND day = {day}
),
metrics AS (
    SELECT
        wiki,
        edit_count_bucket,
        SUM(
            CASE
                WHEN action = 'dialog-open-create' THEN 1
                ELSE 0
            END
        ) AS dialog_open_create,
        SUM(
            CASE
                WHEN action = 'dialog-open-edit' THEN 1
                ELSE 0
            END
        ) AS dialog_open_edit,
        SUM(
            CASE
                WHEN action = 'save-page-create' THEN 1
                ELSE 0
            END
        ) AS save_dialog_create,
        SUM(
            CASE
                WHEN action = 'save-page-edit' THEN 1
                ELSE 0
            END
        ) AS save_dialog_edit
    FROM
        events
    GROUP BY
        wiki,
        edit_count_bucket
)

SELECT
    '{from_date}' AS `date`,
    wiki,
    -- T279046 - replace illegal characters
    replace(replace(edit_count_bucket, '+', ' or more'), ' ', '_') as edit_count_bucket,
    save_dialog_create AS create_and_save,
    (dialog_open_create - save_dialog_create) AS create_and_abandon,
    save_dialog_edit AS edit_and_save,
    (dialog_open_edit - save_dialog_edit) AS edit_and_abandon
FROM
    metrics;
