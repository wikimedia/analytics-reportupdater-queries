SELECT
	DATE('{from_timestamp}') AS date,
	SUM(event_database LIKE 'mysql%') AS 'mysql',
	SUM(event_database = 'sqlite') AS 'sqlite',
	SUM(event_database = 'postgres') AS 'postgres',
	SUM(event_database = 'mssql') AS 'mssql',
	SUM(event_database NOT LIKE 'mysql%' AND
		event_database != 'sqlite' AND
		event_database != 'postgres' AND
		event_database != 'mssql') AS 'Other'
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
	event_database != ''
