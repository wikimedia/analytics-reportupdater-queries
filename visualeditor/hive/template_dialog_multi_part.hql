WITH

template_dialog_events AS (
    SELECT
        CASE
            WHEN event.action = 'add-template' THEN 'open'
            WHEN event.action = 'edit' THEN 'open'
            WHEN event.action = 'save' THEN 'save'
            ELSE 'other'
        END AS action,

        (SIZE(event.template_names) > 1) AS is_multi_part,

        wiki
    FROM
        event.VisualEditorTemplateDialogUse
    WHERE
        useragent.is_bot = false
        AND year = {year}
        AND month = {month}
        AND day = {day}
)

SELECT
    '{from_date}' AS `date`,
    COUNT(1) AS total,
    action,
    is_multi_part,
    wiki
FROM
    template_dialog_events
GROUP BY
    action,
    is_multi_part,
    wiki;
