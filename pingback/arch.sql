SELECT
	DATE('{from_timestamp}') AS date,
	SUM(event_arch = '32') AS '32',
	SUM(event_arch = '64') AS '64',
	SUM(event_arch != '32' AND event_arch != '64') AS 'Other'
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
	event_arch IS NOT NULL
