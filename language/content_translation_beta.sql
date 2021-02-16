select date('{from_timestamp}') as report_date,
       count(*) as {wiki_db}
  from {wiki_db}.user_properties
 where up_property = 'cx'
   and up_value = 1;
