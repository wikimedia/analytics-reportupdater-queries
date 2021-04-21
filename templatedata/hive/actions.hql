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
        event.action IN (
            'parameter-type-change',
            'parameter-priority-change',
            'parameter-label-change',
            'parameter-description-change',
            'parameter-example-change',
            'parameter-default-change',
            'template-description-change',
            'parameter-reorder'
        )
        and useragent.is_bot = false
        and year = {year}
        and month = {month}
        and day = {day}
)

SELECT
    '{from_date}' AS `date`,
    wiki,
    -- T279046 - replace illegal characters
    replace(replace(edit_count_bucket, '+', ' or more'), ' ', '_') as edit_count_bucket,
    action,
    COUNT(*) AS count
FROM
    events
GROUP BY
    wiki,
    edit_count_bucket,
    action;
