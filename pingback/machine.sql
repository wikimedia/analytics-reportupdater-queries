SELECT
	DATE('{from_timestamp}') AS date,
	SUM(event_machine = 'x86_64') AS 'x86_64',
	SUM(event_machine = 'i386') AS 'i386',
	SUM(event_machine = 'i586') AS 'i586',
	SUM(event_machine = 'i686') AS 'i686',
	SUM(event_machine = 'amd64' OR event_machine ='AMD64') AS 'AMD64',
	SUM(event_machine LIKE 'arm%') AS 'ARM',
	SUM(event_machine LIKE 'ppc%') AS 'PPC',
	SUM(event_machine != 'x86_64' AND
		event_machine != 'i386' AND
		event_machine != 'i586' AND
		event_machine != 'i686' AND
		event_machine != 'amd64' AND event_machine !='AMD64' AND
		event_machine NOT LIKE 'arm%' AND
		event_machine NOT LIKE 'ppc%') AS 'Other'
FROM MediaWikiPingback_15781718
JOIN (
	SELECT
		MAX(id) AS id
	FROM MediaWikiPingback_15781718
	WHERE
		timestamp < '{to_timestamp}' AND
		(event_database LIKE 'mysql%' OR NOT (
			event_MediaWiki LIKE '1.31.0%' OR
			event_MediaWiki = '1.32.0-alpha'
		))
	GROUP BY wiki
) AS latest
USING (id)
WHERE
	event_machine != ''
