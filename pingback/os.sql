SELECT
	DATE('{from_timestamp}') AS date,
	SUM(event_OS LIKE 'Linux%') AS 'Linux',
	SUM(event_OS LIKE 'WINNT%') AS 'WINNT',
	SUM(event_OS LIKE 'Darwin%') AS 'Darwin',
	SUM(event_OS LIKE 'FreeBSD%') AS 'FreeBSD',
	SUM(event_OS LIKE 'SunOS%') AS 'SunOS',
	SUM(event_OS LIKE 'CYGWIN%') AS 'CYGWIN',
	SUM(event_OS LIKE 'NetBSD%') AS 'NetBSD',
	SUM(event_OS LIKE 'OpenBSD%') AS 'OpenBSD',
	SUM(event_OS NOT LIKE 'Linux%' AND
		event_OS NOT LIKE 'WINNT%' AND
		event_OS NOT LIKE 'Darwin%' AND
		event_OS NOT LIKE 'FreeBSD%' AND
		event_OS NOT LIKE 'SunOS%' AND
		event_OS NOT LIKE 'CYGWIN%' AND
		event_OS NOT LIKE 'NetBSD%' AND
		event_OS NOT LIKE 'OpenBSD%') AS 'Other'
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
	event_OS != ''
