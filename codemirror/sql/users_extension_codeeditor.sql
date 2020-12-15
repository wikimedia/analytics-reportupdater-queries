SELECT
    DATE('{from_timestamp}') AS DATE,
    COUNT(*) AS users_extensions_codeeditor
FROM
    {wiki_db}.user_properties
WHERE
    up_property = 'usecodeeditor'
    AND up_value = 1;
