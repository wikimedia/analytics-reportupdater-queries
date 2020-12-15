SELECT
    DATE('{from_timestamp}') AS DATE,
    COUNT(*) AS users_gadget_wiked
FROM
    {wiki_db}.user_properties
WHERE
    up_property = 'gadget-wikEd'
    AND up_value = 1;
