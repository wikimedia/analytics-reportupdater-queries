 select date('{from_timestamp}') as date,
        count(*) as {wiki_db}
   from {wiki_db}.user_properties
  where up_property='echo-cross-wiki-notifications'
    and up_value=1
;
