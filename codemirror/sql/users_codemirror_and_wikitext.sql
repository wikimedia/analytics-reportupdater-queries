WITH
    editor_preference AS (
        SELECT
            up_user AS user_id,

            -- Get raw preferences, and interpret depending on the default value.
            -- Preference rows are only stored when the actual value differs from the
            -- default.

            -- These default to 0, only 1 is recorded as a row.
            MAX(up_property = 'usecodemirror' AND up_value = '1') AS syntax_enabled,
            MAX(up_property = 'visualeditor-newwikitext' AND up_value = '1') AS 2017_enabled,
            MAX(up_property = 'gadget-wikEd' AND up_value = '1') AS wiked_enabled
            -- 'usebetatoolbar' defaults to 1
            ! MAX(up_property = 'usebetatoolbar' AND up_value = '0') AS 2010_enabled,
        FROM user_properties
        GROUP BY user_id
        -- Suppress the default of ordering by the `group by` column.
        ORDER BY NULL
    )
    SELECT
        DATE('{from_timestamp}') AS `date`,
        SUM(wiked_enabled) AS users_gadget_wiked,

        -- Apply precedence logic to calculate the expected editor experience:
        --   * wikEd editor has precedence over wikitext 2010 editor
        --   * wikitext 2017 editor has precedence over wikEd and the wikitext 2010 editor.
        --   * codemirror syntax highlighting only runs on wikitext 2010 and 2017 editors, and not wikEd
        SUM(2010_enabled && ! 2017_enabled && ! wiked_enabled) AS users_wikitext_2010,
        SUM(2017_enabled) AS users_wikitext_2017,
        SUM(syntax_enabled && ((2010_enabled && ! wiked_enabled) || 2017_enabled)) AS use_syntax_highlighting,

        -- How many in each editor have highlighting enabled?
        SUM(2010_enabled && ! 2017_enabled && ! wiked_enabled && syntax_enabled) AS users_wikitext_2010_and_codemirror,
        SUM(2017_enabled && syntax_enabled) AS users_wikitext_2017_and_codemirror
    FROM editor_preference;
