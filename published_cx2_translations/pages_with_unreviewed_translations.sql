select
  DATE('{from_timestamp}') AS date,
  count(distinct(concat(
    event_sourceLanguage,
    ':',
    event_sourceTitle,
    ' to ',
    event_targetLanguage,
    ':',
    event_targetTitle,
    ' by ',
    event_token)
  )) pages_with_unreviewed_translations
from
  log.ContentTranslation_18999884
where
  event_action = 'need-review' and
  timestamp >= '{from_timestamp}' and timestamp < '{to_timestamp}';
