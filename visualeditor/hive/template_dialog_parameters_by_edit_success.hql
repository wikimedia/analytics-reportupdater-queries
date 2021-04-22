WITH edit_events AS (
    SELECT
        wiki,
        event.editing_session_id AS session,
        event.action
    FROM
        event.EditAttemptStep
    WHERE
        (
            event.action = 'saveSuccess'
            OR event.action = 'abort'
        )
        AND useragent.is_bot = false
        AND event.is_oversample = false
        and year = {year}
        and month = {month}
        and day = {day}
),
ve_events AS (
    SELECT
        wiki,
        event.editingSessionId AS session,
        event.user_id,
        event.user_editcount,
        event.action
    FROM
        event.VisualEditorFeatureUse
    WHERE
        (
            event.action = 'add-known-parameter'
            OR event.action = 'add-unknown-parameter'
        )
        AND useragent.is_bot = false
        AND event.feature = 'transclusion'
        AND year = {year}
        AND month = {month}
        AND day = {day}
),

bucketed_events AS (
    SELECT
        wiki,
        user_id,
        CASE WHEN user_id = 0 THEN 'anonymous'
            WHEN user_editcount > 1000 THEN '1000_or_more_edits'
            WHEN user_editcount > 100 THEN '100-999_edits'
            WHEN user_editcount > 4 THEN '5-99_edits'
            WHEN user_editcount > 0 THEN '1-4_edits'
            ELSE '0_edits'
        END edit_count_bucket
    FROM
        ve_events
)

SELECT
    '{from_date}' AS `date`,
    ve_events.wiki,
    edit_count_bucket,
    -- Compensate for sampling by multiplying by 1 / 6.25% = 16
    SUM(
        CASE
            WHEN edit_events.action = 'saveSuccess' AND ve_events.action = 'add-known-parameter' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_add_known_param_success,
    SUM(
        CASE
            WHEN edit_events.action = 'saveSuccess' AND ve_events.action = 'add-unknown-parameter' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_add_unknown_param_success,
    SUM(
        CASE
            WHEN edit_events.action = 'abort' AND ve_events.action = 'add-known-parameter' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_add_known_param_abort,
    SUM(
        CASE
            WHEN edit_events.action = 'abort' AND ve_events.action = 'add-unknown-parameter' THEN 1
            ELSE 0
        END
    ) * 16 AS template_dialog_add_unknown_param_abort
FROM
    edit_events,
    ve_events,
    bucketed_events
WHERE
    edit_events.session = ve_events.session
    AND edit_events.wiki = ve_events.wiki
    AND edit_events.wiki = bucketed_events.wiki
    AND ve_events.user_id = bucketed_events.user_id
GROUP BY
    ve_events.wiki,
    edit_count_bucket;
