WITH

-- Templates that were modified on a given day and whether they have template data
template_data_events AS (
    SELECT
        -- Remove any namespace prefixes from the template names
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

-- Entry per template and whether it had template data at some point on a given day
template_data_events_grouped AS (
    SELECT
        MAX(has_template_data) AS has_template_data,
        template_name,
        wiki
    FROM
        template_data_events
    GROUP BY
        template_name,
        wiki
),

-- Template usages categorized by dialog action
template_wizard_events AS (
    SELECT
        -- Categorize as an edit or save event
        CASE
            WHEN event.action = 'insert-template' THEN 'open'
            WHEN event.action = 'save-page' THEN 'save'
        END AS action,
        -- Remove any namespace prefixes from the template names
        SUBSTR(
            event.template_names[0],
            LOCATE(':', event.template_names[0]) + 1
        ) AS template_name,
        wiki
    FROM
        event.TemplateWizard
    WHERE
        (
            event.action = 'insert-template'
            OR event.action = 'save-page'
        )
        AND SIZE(event.template_names) = 1
        AND useragent.is_bot = false
        AND year = {year}
        AND month = {month}
        AND day = {day}
)

SELECT
    '{from_date}' AS `date`,
    action,
    COALESCE(has_template_data, false) AS has_template_data,
    COUNT(1) AS total,
    template_wizard_events.wiki AS wiki
FROM template_wizard_events
LEFT JOIN template_data_events
    ON template_data_events.wiki = template_wizard_events.wiki
    AND template_data_events.template_name = template_wizard_events.template_name
GROUP BY
    action,
    COALESCE(has_template_data, false),
    template_wizard_events.wiki;
