--
-- Estimate the relative frequency of user interactions with Extension:Cite
-- references, when ReferencePreviews is enabled for that user:
--
-- * How often do users explicitly click the footnote link?
-- * In how many percent of the cases do users click on a link inside the
--   reference itself when they see a reference preview?
--
-- EventLogging schema definition:
--   https://meta.wikimedia.org/wiki/Schema:ReferencePreviewsCite
--
-- This monitoring will be removed again in a few months, once we've validated
-- the Reference Previews feature,
--   https://phabricator.wikimedia.org/T214493
--
with

cite_counts as (
    select
        sum(case when event.action = 'pageview' then 1 else 0 end) as pageview,
        sum(case when event.action = 'clickedFootnote' then 1 else 0 end) as clickedFootnote,
        sum(case when event.action = 'clickedReferenceContentLink' then 1 else 0 end) as clickedReferenceContentLink,
        wiki
    from event.referencepreviewscite
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
    clickedReferenceContentLink / pageview as content_clicks_from_reference_section_per_pageview
from cite_counts
;
