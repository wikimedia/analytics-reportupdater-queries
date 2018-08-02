SELECT
	DATE('{from_timestamp}') AS date,
	SUM(event_MediaWiki LIKE '1.28%') AS '1.28',
	SUM(event_MediaWiki LIKE '1.29%') AS '1.29',
	SUM(event_MediaWiki LIKE '1.30%') AS '1.30',
	SUM(event_MediaWiki LIKE '1.31%') AS '1.31',
	SUM(event_MediaWiki LIKE '1.32%') AS '1.32',
	SUM(event_MediaWiki NOT LIKE '1.28%' AND
		event_MediaWiki NOT LIKE '1.29%' AND
		event_MediaWiki NOT LIKE '1.30%' AND
		event_MediaWiki NOT LIKE '1.31%' AND
		event_MediaWiki NOT LIKE '1.32%') AS 'Other'
FROM MediaWikiPingback_15781718
JOIN (
	SELECT
		MAX(id) AS id
	FROM MediaWikiPingback_15781718
	WHERE
		timestamp < '{to_timestamp}' AND
		(event_MediaWiki NOT LIKE '1.31.0%' OR event_database LIKE 'mysql%')
	GROUP BY wiki
) AS latest
USING (id)
WHERE
	event_MediaWiki != ''
