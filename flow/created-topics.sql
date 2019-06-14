SELECT DATE('{from_timestamp}') AS weekstart,
	COUNT(DISTINCT workflow_id) AS num_topics
FROM
(
	SELECT *
	FROM flow_workflow
	INNER JOIN flow_revision ON rev_type_id = workflow_id AND rev_type = 'post' # join needed to exclude moderated topics
	WHERE
		workflow_wiki NOT IN ('testwiki', 'test2wiki') AND
		workflow_type = 'topic' AND
		DATE_FORMAT(FROM_UNIXTIME((conv(substring(hex(workflow_id),1,12),16,10)>>2)/1000),"%Y%m%d%H%i%S") BETWEEN '{from_timestamp}' AND '{to_timestamp}'
	GROUP BY rev_type, rev_type_id HAVING SUBSTRING_INDEX(GROUP_CONCAT(rev_change_type), ',', -1) NOT IN ('hide-topic', 'delete-topic', 'suppress-topic') # exclude topics where last revision was moderation
) AS temp;
