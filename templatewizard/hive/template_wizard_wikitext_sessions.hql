with events AS (
select
    wiki,
    event.user_id,
    event.user_editcount
from
    event.EditAttemptStep
where
    event.action = 'ready'
    and useragent.is_bot = false
    and event.is_oversample = false
    and event.editor_interface = 'wikitext'
    and year = {year}
    and month = {month}
    and day = {day}
),
bucketed_events as (
    select
        wiki,
        case when user_id = 0 then 'anonymous'
            when user_editcount >= 1000 then '1000_or_more_edits'
            when user_editcount >= 100 then '100-999_edits'
            when user_editcount >= 5 then '5-99_edits'
            when user_editcount >= 1 then '1-4_edits'
            else '0_edits'
        end as edit_count_bucket
    from
        events
)

select
    '{from_date}' as `date`,
    wiki,
    edit_count_bucket,
    count(*) as total_template_wizard_wikitext_sessions
from
    bucketed_events
group by
    wiki,
    edit_count_bucket;

