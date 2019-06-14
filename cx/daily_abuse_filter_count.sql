-- As we're using RU to populate another table,
-- instead of updating a report, we have to trick it to make
-- it think that it is generating a report.
-- See https://phabricator.wikimedia.org/T189475#4770686
select
  date('{from_timestamp}') as date,
  true as done;

-- Create a table for storing the counts
create table if not exists staging.cx_abuse_filter_daily (
  id bigint(20) not null auto_increment,
  date date,
  project varbinary(1024),
  abuse_filter_id bigint(20),
  count bigint(20),
  primary key (id)
);

-- Get the daily counts without any personal
-- or article data and insert it into the storage table
insert into
  staging.cx_abuse_filter_daily (date, project, abuse_filter_id, count)
select
  date('{from_timestamp}') as date,
  wiki as project,
  abuse_filter_id,
  count(wiki) as count
from (
  select
    distinct(concat(
      event_filterId,
      event_sourceLanguage,
      event_sourceTitle,
      event_targetLanguage,
      event_token
    )) as session,
    event_filterId as abuse_filter_id,
    wiki
  from
    log.ContentTranslationAbuseFilter_18472730
  where
    timestamp >= '{from_timestamp}' and timestamp < '{to_timestamp}'
) as source
group by
  abuse_filter_id;
