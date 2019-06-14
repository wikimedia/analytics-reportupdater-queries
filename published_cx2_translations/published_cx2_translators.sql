select
    DATE('{from_timestamp}') AS date,
    count(distinct(translation_last_update_by)) AS cx2_published_translators
from
    cx_translations
where
    translation_start_timestamp between '{from_timestamp}' and '{to_timestamp}' and
    translation_cx_version = 2 and
    (translation_status = 'published' or translation_target_url is not null);
