SELECT
    DATE('{from_timestamp}') AS DATE,
    COUNT(*) AS users_codemirror_and_wikitext
FROM
    {wiki_db}.user_properties AS up1,
    {wiki_db}.user_properties AS up2
WHERE
    up1.up_user = up2.up_user
    AND up1.up_property = 'usecodemirror'
    AND up2.up_property = 'usebetatoolbar'
    AND up1.up_value = 1
    AND up2.up_value = 1;
