USE dv1587;

DROP PROCEDURE IF EXISTS update_incident_status;

DELIMITER $$

CREATE PROCEDURE update_incident_status(
    IN p_incident_id INT,
    IN p_new_status_id INT,
    IN p_guard_id INT,
    IN p_note VARCHAR(255)
)
BEGIN
    UPDATE incident
    SET status_id = p_new_status_id,
        guard_id = p_guard_id
    WHERE incident_id = p_incident_id;

    UPDATE incident_status_history
    SET note = p_note
    WHERE incident_id = p_incident_id
    ORDER BY history_id DESC
    LIMIT 1;
END$$

DELIMITER ;