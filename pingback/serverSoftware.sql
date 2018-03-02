SELECT
	DATE('{from_timestamp}') AS date,
	SUM(event_ServerSoftware LIKE 'Apache%') AS 'Apache',
	SUM(event_ServerSoftware LIKE 'Microsoft-IIS%') AS 'Microsoft-IIS',
	SUM(event_ServerSoftware LIKE 'nginx%') AS 'nginx',
	SUM(event_ServerSoftware LIKE 'lighttpd%') AS 'lighttpd',
	SUM(event_ServerSoftware LIKE 'LiteSpeed%') AS 'LiteSpeed',
	SUM(event_ServerSoftware NOT LIKE 'Apache%' AND
		event_ServerSoftware NOT LIKE 'Microsoft-IIS%' AND
		event_ServerSoftware NOT LIKE 'nginx%' AND
		event_ServerSoftware NOT LIKE 'lighttpd%' AND
		event_ServerSoftware NOT LIKE 'LiteSpeed%') AS 'Other'
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
	event_serverSoftware != ''
