SELECT
	DATE('{from_timestamp}') AS weekstart,
	COUNT(DISTINCT workflow_id) AS num_topics
FROM
(
	SELECT workflow_id
	FROM flow_revision AS a
	LEFT JOIN flow_revision AS b ON a.rev_type = b.rev_type AND a.rev_type_id = b.rev_type_id # join needed to exclude moderated posts
	INNER JOIN flow_tree_node ON tree_descendant_id = a.rev_type_id
	INNER JOIN flow_workflow ON workflow_id = tree_ancestor_id
	WHERE
		a.rev_user_wiki NOT IN ('testwiki', 'test2wiki') AND
		a.rev_change_type = 'reply' AND
		DATE_FORMAT(FROM_UNIXTIME((conv(substring(hex(a.rev_id),1,12),16,10)>>2)/1000),"%Y%m%d%H%i%S") BETWEEN '{from_timestamp}' AND '{to_timestamp}'
	GROUP BY a.rev_type, a.rev_type_id HAVING SUBSTRING_INDEX(GROUP_CONCAT(b.rev_change_type), ',', -1) NOT IN ('hide-post', 'delete-post', 'suppress-post') # exclude posts where last revision was moderation
) AS temp;