SELECT DATE('{from_timestamp}') AS date, SUM(notifications_sent) AS notifications_sent, SUM(notifications_read) AS notifications_read
FROM
(
	# amount of sent notifications per month
	SELECT
		COUNT(*) AS notifications_sent,
		0 AS notifications_read
	FROM {wiki_db}.echo_notification
	WHERE notification_timestamp BETWEEN '{from_timestamp}' AND '{to_timestamp}'

	UNION

	# amount of read notifications per month is harder: notifications
	# are bundled and only one of the gets the read timestamp, so we'll
	# have to group them based on how they're bundled & get that timestamp,
	# then have another query to fetch the unbundled notifications
	SELECT
		0 AS notifications_sent,
		COUNT(*) AS notifications_read
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
	WHERE notification.notification_read_timestamp BETWEEN '{from_timestamp}' AND '{to_timestamp}'
) AS temp;
