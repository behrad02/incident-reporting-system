USE dv1587;

-- Query 1: Show incidents with related data

SELECT
    i.incident_id,
    i.reference_no,
    i.title,
    i.occurred_at,
    s.name AS status,
    CONCAT(g.first_name, ' ', g.last_name) AS guard,
    it.name AS incident_type,
    l.name AS location
FROM incident i
JOIN status s ON i.status_id = s.status_id
JOIN guard g ON i.guard_id = g.guard_id
JOIN incident_type it ON i.incident_type_id = it.incident_type_id
JOIN location l ON i.location_id = l.location_id
ORDER BY i.incident_id DESC;

-- Query 2: Show incident status history

SELECT
    h.history_id,
    h.incident_id,
    os.name AS old_status,
    ns.name AS new_status,
    CONCAT(g.first_name, ' ', g.last_name) AS changed_by,
    h.changed_at,
    h.note
FROM incident_status_history h
LEFT JOIN status os ON h.old_status_id = os.status_id
JOIN status ns ON h.new_status_id = ns.status_id
JOIN guard g ON h.changed_by_guard_id = g.guard_id
ORDER BY h.history_id DESC;

-- Query 3: Number of incidents per location

SELECT
    l.name AS location,
    COUNT(*) AS total_incidents
FROM incident i
JOIN location l ON i.location_id = l.location_id
GROUP BY l.location_id, l.name
ORDER BY total_incidents DESC;

-- Query 4: Number of incidents per type

SELECT
    it.name AS incident_type,
    COUNT(*) AS total_incidents
FROM incident i
JOIN incident_type it ON i.incident_type_id = it.incident_type_id
GROUP BY it.incident_type_id, it.name
ORDER BY total_incidents DESC;

-- Query 5: Incidents reported by each guard

SELECT
    CONCAT(g.first_name, ' ', g.last_name) AS guard,
    COUNT(i.incident_id) AS incidents_reported
FROM guard g
LEFT JOIN incident i ON g.guard_id = i.guard_id
GROUP BY g.guard_id
ORDER BY incidents_reported DESC;