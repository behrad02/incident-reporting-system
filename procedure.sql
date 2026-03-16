USE dv1587;

DELIMITER $$

CREATE PROCEDURE update_incident_status()
BEGIN
    UPDATE incident
    SET status_id = @p_new_status_id,
        guard_id = @p_guard_id
    WHERE incident_id = @p_incident_id;
END$$

DELIMITER ;