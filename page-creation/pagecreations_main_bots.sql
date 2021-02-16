SELECT DATE('{from_timestamp}') AS report_date,
COUNT(*) AS {wiki_db}
FROM mediawiki_page_create_3
WHERE `database`='{wiki_db}'
AND page_namespace = 0
AND performer_user_is_bot = 1
AND rev_timestamp >= STR_TO_DATE('{from_timestamp}', '%Y%m%d%H%i%s')
AND rev_timestamp < STR_TO_DATE('{to_timestamp}', '%Y%m%d%H%i%s')
