-- Estimate the relative frequency of user interactions with Extension:Popups
-- references, when ReferencePreviews is enabled for that user:
--
-- * How often do people look at a reference pop up relative to the pages being
--   opened? E.g. On average, there were 0.03 showings of a reference pop up per
--   page opened where Reference Previews was deployed.
-- * In how many percent of the cases do users click on “go to references
--   section” when they see a reference preview?
-- * In how many percent of the cases do users click on a link inside the
--   reference itself when they see a reference preview?
-- * How often (absolute number per page being opened) do people (who have
--   referencepreview enabled) click on a link inside the reference itself when
--   they see a reference preview?
-- * In how many percent of the cases does an opened reference pop up contain
--   scroll bars?
-- * Of those times, how often do users scroll? (For now, let’s not separate
--   between horizontally and vertically)
--
-- EventLogging schema definition:
--   https://meta.wikimedia.org/wiki/Schema:ReferencePreviewsPopups
--
-- This monitoring will be removed again in a few months, once we've validated
-- the Reference Previews feature,
--   https://phabricator.wikimedia.org/T214493
--
with

popups_counts as (
    select
        sum(case when event.action = 'pageview' then 1 else 0 end) as pageview,
        sum(case when event.action = 'poppedOpen' then 1 else 0 end) as poppedOpen,
        sum(case when event.action = 'clickedGoToReferences' then 1 else 0 end) as clickedGoToReferences,
        sum(case when event.action = 'clickedReferencePreviewsContentLink' then 1 else 0 end) as clickedReferencePreviewsContentLink,
        sum(case when event.action = 'poppedOpen' and event.scrollbarsPresent = true then 1 else 0 end) as scrollbarsPresent,
        sum(case when event.action = 'scrolled' then 1 else 0 end) as scrolled,
        wiki
    from event.referencepreviewspopups
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
    poppedOpen / pageview as popups_opened_per_pageview,
    clickedGoToReferences / pageview as nav_to_reference_section_per_pageview,
    clickedReferencePreviewsContentLink / pageview as content_clicks_from_popup_per_pageview,
    scrollbarsPresent / poppedOpen as reference_popup_has_scrollbars_proportion,
    scrolled / poppedOpen as reference_popup_is_scrolled_proportion
from popups_counts
;
