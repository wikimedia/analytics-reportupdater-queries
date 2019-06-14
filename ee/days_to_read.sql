SELECT
	DATE('{from_timestamp}') AS date,
	SUM(notification_read_timestamp IS NOT NULL AND days_to_read <= 2 ) AS 0_to_2,
	SUM(notification_read_timestamp IS NOT NULL AND days_to_read BETWEEN 3 and 5) AS 3_to_5,
	SUM(notification_read_timestamp IS NOT NULL AND days_to_read BETWEEN 6 AND 10) AS 6_to_10,
	SUM(notification_read_timestamp IS NOT NULL AND days_to_read BETWEEN 11 AND 20) AS 11_to_20,
	SUM(notification_read_timestamp IS NOT NULL AND days_to_read BETWEEN 21 AND 30) AS 21_to_30,
	SUM(days_to_read >= 31) AS 31_plus
FROM
(
	SELECT
		notification.notification_event,
		notification.notification_timestamp,
		IFNULL(bundle.notification_read_timestamp, notification.notification_read_timestamp) AS notification_read_timestamp,
		# days (rounded down) between notification time & read time (or now, if it hasn't been read yet)
		TIMESTAMPDIFF(
			DAY,
			STR_TO_DATE(
				notification.notification_timestamp,
				'%Y%m%d%H%i%S'
			),
			STR_TO_DATE(COALESCE(
				bundle.notification_read_timestamp,
				notification.notification_read_timestamp,
				DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')
				), '%Y%m%d%H%i%S'
			)
		) AS days_to_read
	FROM {wiki_db}.echo_notification AS notification
	LEFT JOIN
	(
		SELECT
			notification_read_timestamp,
			notification_bundle_display_hash
		FROM {wiki_db}.echo_notification
		WHERE notification_bundle_base = 1
		GROUP BY notification_bundle_display_hash
	) bundle ON notification.notification_bundle_display_hash = bundle.notification_bundle_display_hash AND notification.notification_bundle_display_hash != ''
	WHERE notification.notification_timestamp BETWEEN '{from_timestamp}' AND '{to_timestamp}'
) AS temp;
