-- Get all CodeMirror usage events for the day.
with all_events as (
    select
        wiki,
        event.editor,
        event.enabled,
        event.session_token,
        event.edit_start_ts_ms,
        case
            when event.user_id = 0 then 'anonymous'
            when event.user_edit_count_bucket is not null then event.user_edit_count_bucket
            -- TODO: Remove this temporary fallback once migration is complete.
            else 'unknown'
        end as edit_count_bucket,
        seqid
    from
        event.CodeMirrorUsage
    where
        useragent.is_bot = false
        and year = {year}
        and month = {month}
        and day = {day}
),

-- Group by edit session.
grouped_sessions as (
    select
        wiki,
        editor,
        enabled,
        edit_count_bucket,
        row_number()
            over (
                partition by
                    wiki, session_token, edit_start_ts_ms
                order by
                    seqid desc
            )
            as rownum
    from
        all_events
),

-- Take the latest event.
latest_events as (
    select
        wiki,
        editor,
        enabled,
        edit_count_bucket
    from
        grouped_sessions
    where
        rownum = 1
)

-- Sum each possible combination of attributes.
select
    '{from_date}' as `date`,
    wiki,
    -- T279046 - replace illegal characters
    replace(replace(edit_count_bucket, '+', ' or more'), ' ', '_') as edit_count_bucket,
    sum(case when editor = 'wikitext' and enabled = true then 1 else 0 end) as enabled_in_wikitext_session,
    sum(case when editor = 'wikitext' and enabled = false then 1 else 0 end) as disabled_in_wikitext_session,
    sum(case when editor = 'wikitext-2017' and enabled = true then 1 else 0 end) as enabled_in_wikitext_2017_session,
    sum(case when editor = 'wikitext-2017' and enabled = false then 1 else 0 end) as disabled_in_wikitext_2017_session
from
    latest_events
group by
    wiki,
    edit_count_bucket;
