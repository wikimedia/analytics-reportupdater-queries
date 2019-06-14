/* Note that limn will probably not graph this appropriatly, it expects each column to be
 * a data point but in this query the data is per row. The hope is limn will still offer
 * up the table view of this data without graphing.
 */
SELECT DATE('{from_timestamp}') as Date,
       event_entrypoint,
       event_action,
       count(event_action)
  FROM FlowReplies_10561344_15423246
 WHERE wiki NOT IN ('testwiki', 'test2wiki', 'officewiki')
   AND timestamp >= '{from_timestamp}'
   AND timestamp < '{to_timestamp}'
 GROUP BY event_entrypoint, event_action

UNION ALL

SELECT DATE('{from_timestamp}') as Date,
       event_entrypoint,
       event_action,
       count(event_action)
  FROM FlowReplies_10561344
 WHERE wiki NOT IN ('testwiki', 'test2wiki', 'officewiki')
   AND timestamp >= '{from_timestamp}'
   AND timestamp < '{to_timestamp}'
 GROUP BY event_entrypoint, event_action;

;
