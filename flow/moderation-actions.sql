SELECT
	DATE('{from_timestamp}') AS Week,
	SUM(IF(rev_change_type = 'restore-post', 1, 0)) AS "Restore Post",
	SUM(IF(rev_change_type = 'hide-post', 1, 0)) AS "Hide Post",
	SUM(IF(rev_change_type = 'delete-post', 1, 0)) AS "Delete Post",
	SUM(IF(rev_change_type = 'restore-topic', 1, 0)) AS "Restore Topic",
	SUM(IF(rev_change_type = 'hide-topic', 1, 0)) AS "Hide Topic",
	SUM(IF(rev_change_type = 'delete-topic', 1, 0)) AS "Delete Topic"
FROM (
	SELECT DATE_FORMAT(FROM_UNIXTIME((conv(substring(hex(rev_id),1,12),16,10)>>2)/1000),"%Y%m%d%H%i%S") AS timestamp,
	       rev_change_type
	FROM flow_revision
	WHERE rev_user_wiki NOT IN ('testwiki', 'test2wiki')
	HAVING timestamp >= '{from_timestamp}'
	AND timestamp < '{to_timestamp}'
) x;
