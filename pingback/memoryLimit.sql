SELECT
	DATE('{from_timestamp}') AS date,
	SUM(normalizedMemoryLimit > 0 AND normalizedMemoryLimit <= 1) AS 'limit <= 1M',
	SUM(normalizedMemoryLimit > 1 AND normalizedMemoryLimit <= 32) AS '1M < limit <= 32M',
	SUM(normalizedMemoryLimit > 32 AND normalizedMemoryLimit <= 64) AS '32M < limit <= 64M',
	SUM(normalizedMemoryLimit > 64 AND normalizedMemoryLimit <= 128) AS '64M < limit <= 128M',
	SUM(normalizedMemoryLimit > 128 AND normalizedMemoryLimit <= 256) AS '128M < limit <= 256M',
	SUM(normalizedMemoryLimit > 256 AND normalizedMemoryLimit <= 512) AS '256M < limit <= 512M',
	SUM(normalizedMemoryLimit > 512 AND normalizedMemoryLimit <= 1024) AS '512M < limit <= 1G',
	SUM(normalizedMemoryLimit > 1024) AS 'limit > 1G',
	SUM(normalizedMemoryLimit < 0) AS 'Non-numeric'
FROM
	( SELECT
			id AS id,
			timestamp AS timestamp,
			CASE
				WHEN event_memoryLimit LIKE '%M' THEN
					CASE
						WHEN LEFT(event_memoryLimit, CHAR_LENGTH(event_memoryLimit) - 1) REGEXP '^[0-9]+$' THEN
							CAST(LEFT(event_memoryLimit, CHAR_LENGTH(event_memoryLimit) - 1) AS UNSIGNED)
						WHEN LEFT(event_memoryLimit, CHAR_LENGTH(event_memoryLimit) - 1) REGEXP '^[0-9]+([.][0-9]+)*$' THEN
							CAST(LEFT(event_memoryLimit, LOCATE('.', event_memoryLimit) - 1) AS UNSIGNED)
						ELSE -1
					END
				WHEN event_memoryLimit LIKE '%G' THEN
					CASE
						WHEN LEFT(event_memoryLimit, CHAR_LENGTH(event_memoryLimit) - 1) REGEXP '^[0-9]+$' THEN
							CAST(LEFT(event_memoryLimit, CHAR_LENGTH(event_memoryLimit) - 1) AS UNSIGNED)/1024
						WHEN LEFT(event_memoryLimit, CHAR_LENGTH(event_memoryLimit) - 1) REGEXP '^[0-9]+([.][0-9]+)*$' THEN
							CAST(LEFT(event_memoryLimit, LOCATE('.', event_memoryLimit) - 1) AS UNSIGNED)/1024
						ELSE -1
					END
				WHEN event_memoryLimit REGEXP '^[0-9]+$' THEN
					CAST(event_memoryLimit AS UNSIGNED)/(1024*1024)
				WHEN event_memoryLimit REGEXP '^[0-9]+([.][0-9]+)*$' THEN
					CAST(LEFT(event_memoryLimit, LOCATE('.', event_memoryLimit) - 1) AS UNSIGNED)/(1024*1024)
				ELSE -1
			END AS normalizedMemoryLimit
		FROM MediaWikiPingback_15781718
		WHERE event_memoryLimit != ''
	) AS result
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
