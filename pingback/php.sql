SELECT
	DATE('{from_timestamp}') AS date,
	SUM(event_PHP LIKE '5.5%') AS '5.5',
	SUM(event_PHP LIKE '5.6%') AS '5.6',
	SUM(event_PHP LIKE '7.0%') AS '7.0',
	SUM(event_PHP LIKE '7.1%') AS '7.1',
	SUM(event_PHP LIKE '7.2%') AS '7.2',
	SUM(event_PHP NOT LIKE '5.5%' AND
		event_PHP NOT LIKE '5.6%' AND
		event_PHP NOT LIKE '7.0%' AND
		event_PHP NOT LIKE '7.1%' AND
		event_PHP NOT LIKE '7.2%') AS 'Other'
FROM MediaWikiPingback_15781718
JOIN (
	SELECT
		MAX(id) AS id
	FROM MediaWikiPingback_15781718
	WHERE
		timestamp < '{to_timestamp}'
	GROUP BY wiki
) AS latest
USING (id)
WHERE
	event_PHP != ''
