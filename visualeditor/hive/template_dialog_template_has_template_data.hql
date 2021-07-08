WITH

-- Most recent event for each template
latest_template_data_events AS (
    SELECT
        event.template_name AS template_name,
        MAX(dt) AS latest_dt,
        wiki
    FROM
        event.TemplateDataApi
    WHERE
        useragent.is_bot = false
        AND year = {year}
        AND month = {month}
        AND day = {day}
    GROUP BY
        event.template_name,
        wiki
),

-- Deduplicated templates and whether they now have any template data
template_data_events AS (
    SELECT
        event.has_template_data,
        -- Remove any namespace prefixes from the template names
        SUBSTR(
            event.template_name,
            LOCATE(':', event.template_name) + 1,
            LENGTH(event.template_name)
        ) AS template_name,
        all_events.wiki
    FROM
        event.TemplateDataApi AS all_events
    JOIN latest_template_data_events AS latest_events
        ON latest_events.template_name = event.template_name
            AND latest_events.latest_dt = all_events.dt
            AND latest_events.wiki = all_events.wiki
    WHERE
        useragent.is_bot = false
        AND year = {year}
        AND month = {month}
        AND day = {day}
),

-- Deduplicated templates which were used in a save/edit template dialog session
template_dialog_events AS (
    SELECT
        event.action,
        -- Remove any namespace prefixes from the template names
        SUBSTR(
            template_name,
            LOCATE(':', template_name) + 1,
            LENGTH(template_name)
        ) AS template_name,
        wiki
    FROM
        event.VisualEditorTemplateDialogUse
    LATERAL VIEW EXPLODE(event.template_names) template_names AS template_name
    WHERE
        (
            event.action = 'save'
            OR event.action = 'edit'
        )
        AND useragent.is_bot = false
        AND year = {year}
        AND month = {month}
        AND day = {day}
    GROUP BY
        event.action,
        template_name,
        wiki
)

SELECT
    '{from_date}' AS `date`,
    template_data_events.wiki as wiki,
    SUM(
        CASE
            WHEN has_template_data = false AND action = 'edit' THEN 1
            ELSE 0
        END
    ) AS no_template_data_on_edit,
    SUM(
        CASE
            WHEN has_template_data = true AND action = 'edit' THEN 1
            ELSE 0
        END
    ) AS has_template_data_on_edit,
    SUM(
        CASE
            WHEN has_template_data = false AND action = 'save' THEN 1
            ELSE 0
        END
    ) AS no_template_data_on_save,
    SUM(
        CASE
            WHEN has_template_data = true AND action = 'save' THEN 1
            ELSE 0
        END
    ) AS has_template_data_on_save
FROM
    template_data_events,
    template_dialog_events
WHERE
    template_data_events.wiki = template_dialog_events.wiki
    AND template_data_events.template_name = template_dialog_events.template_name
GROUP BY
    template_data_events.wiki;
