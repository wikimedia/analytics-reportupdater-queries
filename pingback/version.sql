SELECT
	DATE('{from_timestamp}') AS date,
	CASE
		WHEN event_MediaWiki REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+$'
			THEN event_MediaWiki
		WHEN event_MediaWiki REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+-wmf'
			THEN CONCAT(LEFT(event_MediaWiki, POSITION('-wmf' IN event_MediaWiki) - 1), ' (WMF)')
		WHEN event_MediaWiki REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+-rc'
			THEN CONCAT(LEFT(event_MediaWiki, POSITION('-rc' IN event_MediaWiki) - 1), ' (RC)')
		WHEN event_MediaWiki REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+-alpha'
			THEN CONCAT(LEFT(event_MediaWiki, POSITION('-alpha' IN event_MediaWiki) - 1), ' (ALPHA)')
		ELSE LEFT(event_MediaWiki, 6)
	END AS version,
	COUNT(*) AS count
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
GROUP BY version
ORDER BY count DESC
