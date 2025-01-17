-- For PKY
-- using individual events, accounting for Sunday being closed, not allowing 
-- appointments for Monday after 4pm Saturday, with a prefix on site_short_name
SELECT a.id, CONCAT('Tent ', b.site_short_name, ' - ', from_unixtime(a.appointment_block, '%m/%d/%Y %W %h:%i %p')) FROM
    (
        (SELECT * FROM redcap_entity_fr_appointment
            WHERE ( record_id IS NULL OR
                (record_id = [record-name])
                )
            AND project_id = [project-id]
            AND (
            ( appointment_block > UNIX_TIMESTAMP(
                     -- If it is later than 4pm, only show appointments at least 2 days from today
                    DATE( NOW() + INTERVAL IF(HOUR(NOW()) >= 16 AND WEEKDAY(NOW()) != 6, 2, 1) DAY ) +
                    -- if it's Saturday after 4, add an additional day
                    INTERVAL IF(WEEKDAY(NOW()) = 5 AND HOUR(NOW()) >= 16, 1, 0) DAY +
                    -- or if it's Sunday
                    INTERVAL IF(WEEKDAY(NOW()) = 6, 1, 0) DAY
                )
            )
            OR (
                IF([is-survey], 0, 1)
                AND
                record_id = [record-name]
               )
            )
            ORDER BY appointment_block
        ) as a
    INNER JOIN redcap_entity_test_site as b ON a.site = b.id
    )
    ORDER BY a.appointment_block, b.site_short_name
    ;
