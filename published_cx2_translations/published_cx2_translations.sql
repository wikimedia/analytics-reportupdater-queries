select
    DATE('{from_timestamp}') AS report_date,
    count(translation_id) as cx2_published_translations
from
    cx_translations
where
    translation_start_timestamp between '{from_timestamp}' and '{to_timestamp}' and
    translation_cx_version = 2 and
    (translation_status = 'published' or translation_target_url is not null);
