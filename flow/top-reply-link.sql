/* Are people actually clicking on the top Reply link? */
SELECT DATE('{from_timestamp}') as Date,
       SUM(IF(event_entrypoint = 'reply-top' AND event_action = 'initiate', 1, 0)) as "Top reply initiated",
       SUM(IF(event_entrypoint = 'reply-top' AND event_action = 'save-attempt', 1, 0)) as "Top reply save attempt",

       SUM(IF(event_entrypoint = 'reply-top' AND event_action = 'save-success', 1, 0))  as "Top reply save success",
       SUM(IF(event_entrypoint = 'reply-bottom' AND event_action = 'initiate', 1, 0)) as "Bottom reply initiated",
       SUM(IF(event_entrypoint = 'reply-bottom' AND event_action = 'save-attempt', 1, 0))  as "Bottom reply save attempt",
       SUM(IF(event_entrypoint = 'reply-bottom' AND event_action = 'save-success', 1, 0))  as "Bottom reply save success"
  FROM FlowReplies_10561344_15423246
 WHERE event_entrypoint IN ('reply-top', 'reply-bottom')
   AND event_action IN ('initiate', 'save-attempt', 'save-success')
   AND wiki NOT IN ('testwiki', 'test2wiki', 'officewiki')
   AND timestamp >= '{from_timestamp}'
   AND timestamp < '{to_timestamp}'

UNION ALL

SELECT DATE('{from_timestamp}') as Date,
       SUM(IF(event_entrypoint = 'reply-top' AND event_action = 'initiate', 1, 0)) as "Top reply initiated",
       SUM(IF(event_entrypoint = 'reply-top' AND event_action = 'save-attempt', 1, 0)) as "Top reply save attempt",

       SUM(IF(event_entrypoint = 'reply-top' AND event_action = 'save-success', 1, 0))  as "Top reply save success",
       SUM(IF(event_entrypoint = 'reply-bottom' AND event_action = 'initiate', 1, 0)) as "Bottom reply initiated",
       SUM(IF(event_entrypoint = 'reply-bottom' AND event_action = 'save-attempt', 1, 0))  as "Bottom reply save attempt",
       SUM(IF(event_entrypoint = 'reply-bottom' AND event_action = 'save-success', 1, 0))  as "Bottom reply save success"
  FROM FlowReplies_10561344
 WHERE event_entrypoint IN ('reply-top', 'reply-bottom')
   AND event_action IN ('initiate', 'save-attempt', 'save-success')
   AND wiki NOT IN ('testwiki', 'test2wiki', 'officewiki')
   AND timestamp >= '{from_timestamp}'
   AND timestamp < '{to_timestamp}';

;
