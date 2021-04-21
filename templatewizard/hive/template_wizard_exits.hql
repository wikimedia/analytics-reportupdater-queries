with all_events AS (
    select
        wiki,
        event.action,
        case
            when event.performer.user_id is null then 'anonymous'
            -- TODO: after the user_edit_count_bucket producer is fully migrated, probably in
            -- wmf/1.36.0-wmf.29, we can remove transitional logic and trust the bucket label.
            when event.performer.user_edit_count_bucket is not null then event.performer.user_edit_count_bucket
            when event.performer.user_edit_count >= 1000 then '1000+ edits'
            when event.performer.user_edit_count >= 100 then '100-999 edits'
            when event.performer.user_edit_count >= 5 then '5-99 edits'
            when event.performer.user_edit_count >= 1 then '1-4 edits'
            when event.performer.user_edit_count = 0 then '0 edits'
            else 'unknown'
        end as edit_count_bucket
    from
        event.TemplateWizard
    where
        event.action in (
            'cancel-dialog',
            'insert-template'
        )
        and useragent.is_bot = false
        and year = {year}
        and month = {month}
        and day = {day}
)

select
    '{from_date}' as `date`,
    wiki,
    -- T279046 - replace illegal characters
    replace(replace(edit_count_bucket, '+', ' or more'), ' ', '_') as edit_count_bucket,
    sum(case when action = 'insert-template' then 1 else 0 end) as save,
    sum(case when action = 'cancel-dialog' then 1 else 0 end) as abort
from
    all_events
group by
    wiki,
    edit_count_bucket;
