SELECT DATE('{from_timestamp}') AS date,
COUNT(*) AS {wiki_db}
FROM mediawiki_page_create_2
WHERE `database`='{wiki_db}'
AND rev_timestamp >= STR_TO_DATE('{from_timestamp}', '%Y%m%d%H%i%s')
AND rev_timestamp < STR_TO_DATE('{to_timestamp}', '%Y%m%d%H%i%s')
