select
  date('{from_timestamp}') as report_date,
  case cxc_origin
    when 'scratch' then 'No machine translation'
    else cxc_origin
    end
    as engine,
  count(distinct(cxc_translation_id)) as translations
from
  cx_corpora
where
  cxc_timestamp between '{from_timestamp}' and '{to_timestamp}' and
  cxc_origin not in (
    'disable-mt',
    'no-mt',
    'source',
    'TestClient',
    'source-mt',
    'user'
  )
group by
  cxc_origin;
