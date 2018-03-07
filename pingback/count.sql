SELECT
	DATE('{from_timestamp}') AS date,
	COUNT(*) AS 'Unique Wiki Count'
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
