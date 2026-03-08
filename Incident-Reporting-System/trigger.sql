USE dv1587;

DROP TRIGGER IF EXISTS trg_incident_status_change;

DELIMITER $$

CREATE TRIGGER trg_incident_status_change
AFTER UPDATE ON incident
FOR EACH ROW
BEGIN
  IF NOT (OLD.status_id <=> NEW.status_id) THEN
    INSERT INTO incident_status_history
      (incident_id, old_status_id, new_status_id, changed_by_guard_id, changed_at, note)
    VALUES
      (NEW.incident_id, OLD.status_id, NEW.status_id, NEW.guard_id, NOW(), 'Status updated');
  END IF;
END$$

DELIMITER ;