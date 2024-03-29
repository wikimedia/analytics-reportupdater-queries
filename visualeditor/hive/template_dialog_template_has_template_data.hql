WITH

-- Templates that were modified on a given day and whether they have template data
template_data_events AS (
    SELECT
        -- Extract and strip namespace from template names
        SUBSTR(
            event.template_name,
            LOCATE(':', event.template_name) + 1
        ) AS template_name,
        event.has_template_data,
        wiki
    FROM
        event.TemplateDataApi
    WHERE
        useragent.is_bot = false
        AND year = {year}
        AND month = {month}
        AND day = {day}
),

-- Entry per template and whether it had template data at any point during the day.
template_data_daily AS (
    SELECT
        MAX(template_data_events.has_template_data) has_template_data,
        template_name,
        wiki
    FROM
        template_data_events
    GROUP BY
        template_name,
        wiki
),

-- Template usages categorized by dialog action
template_dialog_events AS (
    SELECT
        CASE
            WHEN event.action = 'add-template' THEN 'open'
            WHEN event.action = 'edit' THEN 'open'
            WHEN event.action = 'save' THEN 'save'
            ELSE 'other'
        END AS action,
        -- Extract and strip namespace from the first template name
        SUBSTR(
            event.template_names[0],
            LOCATE(':', event.template_names[0]) + 1
        ) AS template_name,
        wiki
    FROM
        event.VisualEditorTemplateDialogUse
    WHERE
        useragent.is_bot = false
        AND year = {year}
        AND month = {month}
        AND day = {day}
        AND SIZE(event.template_names) = 1
)

SELECT
    '{from_date}' AS `date`,
    template_dialog_events.wiki AS wiki,
    COUNT(1) AS total,
    COALESCE(template_data_daily.has_template_data, false) AS has_template_data,
    action
FROM template_dialog_events
LEFT JOIN template_data_daily
    ON template_data_daily.wiki = template_dialog_events.wiki
    AND template_data_daily.template_name = template_dialog_events.template_name
GROUP BY
    action,
    COALESCE(template_data_daily.has_template_data, false),
    template_dialog_events.wiki;
