with bucketed_users as (
    select
        wiki,
        case
            when event.user_id = 0 then 'anonymous'
            when event.user_edit_count_bucket is not null then event.user_edit_count_bucket
            -- TODO: Remove this temporary fallback once migration is complete.
            else 'unknown'
        end as edit_count_bucket,
        event.editor,
        event.enabled
    from event.CodeMirrorUsage
    where
        useragent.is_bot = false
        and event.toggled = true
        and year = {year}
        and month = {month}
        and day = {day}
)
SELECT
    '{from_date}' as `date`,
    wiki,
    -- T279046 - replace illegal characters
    replace(replace(edit_count_bucket, '+', ' or more'), ' ', '_') as edit_count_bucket,
    SUM(CASE WHEN editor = 'wikitext' AND enabled = true THEN 1 ELSE 0 END) AS toggled_on_from_wikitext,
    SUM(CASE WHEN editor = 'wikitext' AND enabled = false THEN 1 ELSE 0 END) AS toggled_off_from_wikitext,
    SUM(CASE WHEN editor = 'wikitext-2017' AND enabled = true THEN 1 ELSE 0 END) AS toggled_on_from_wikitext_2017,
    SUM(CASE WHEN editor = 'wikitext-2017' AND enabled = false THEN 1 ELSE 0 END) AS toggled_off_from_wikitext_2017
FROM bucketed_users
GROUP BY
    wiki,
    edit_count_bucket;
