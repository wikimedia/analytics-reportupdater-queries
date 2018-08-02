SELECT
	DATE('{from_timestamp}') AS date,
	COUNT(*) AS 'Unique Wiki Count'
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
