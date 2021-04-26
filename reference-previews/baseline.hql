--
-- Estimate the relative frequency of user interactions with Extension:Cite
-- references:
--   * How many times does a user click on the footnote marker, per pageview?
--   * How many times does a user click on a link in reference content, per pageview?
--
-- Eventlogging actions are tallied.  We discard events where Reference Previews
-- is enabled, to establish a baseline for evaluating the feature.
--
-- EventLogging schema definition:
--   https://meta.wikimedia.org/wiki/Schema:ReferencePreviewsBaseline
--
-- This monitoring will be removed again in a few months, once we've validated
-- the Reference Previews feature,
--   https://phabricator.wikimedia.org/T231529
--
with

event_counts as (
    select
        sum(case when event.action = 'pageview' then 1 else 0 end) as pageview,
        sum(case when event.action = 'clickedFootnote' then 1 else 0 end) as clickedFootnote,
        sum(case when event.action = 'clickedReferenceContentLink' then 1 else 0 end) as clickedReferenceContentLink,
        wiki
    from event.referencepreviewsbaseline
    where
        useragent.is_bot = false
        and year = {year}
        and month = {month}
        and day = {day}
    group by
        wiki
)

select
    '{from_date}' AS `date`,
    wiki,
    pageview as pageviews,
    clickedFootnote / pageview as footnote_clicks_per_pageview,
    clickedReferenceContentLink / pageview as content_clicks_per_pageview
from event_counts
;
