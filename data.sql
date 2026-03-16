USE dv1587;

INSERT INTO status (name) VALUES
('Open'),
('In Progress'),
('Closed');

INSERT INTO guard (first_name, last_name, phone, email, employee_no, active) VALUES
('Farshid', 'Ghasemi', '0762357689', 'farshid.ghasemi@hotmail.com', 'G001', TRUE),
('Sara', 'Andreasson', '0709812365', 'saraandreasson@gmail.com', 'G002', TRUE),
('Ali', 'Rezaei', '0701234567', 'ali@gmail.com', 'G003', TRUE),
('Anna', 'Karlsson', '0709876543', 'karlsson12@gmail.com', 'G004', TRUE);

INSERT INTO location (name, address, city, site_code, active) VALUES
('Willys', 'blåportsgatan 20', 'Karlskrona', 'LOC01', TRUE),
('Karlskrona Hem', 'rådhusgatan 5', 'Karlskrona', 'LOC02', TRUE),
('Shopping Mall', 'Borgmästaregatan 12', 'Karlskrona', 'LOC03', TRUE),
('Parking Garage', 'Trossögatan 8', 'Karlskrona', 'LOC04', TRUE);

INSERT INTO incident_type (name, description, severity_level, active) VALUES
('Alarm', 'Alarm triggered on site', 3, TRUE),
('Vandalism', 'Damage to property', 4, TRUE),
('Disturbance', 'Public disturbance / conflict', 2, TRUE);

INSERT INTO incident
(occurred_at, reported_at, location_id, incident_type_id, guard_id, status_id, title, description, reference_no)
VALUES
(NOW(), NOW(), 1, 1, 1, 1, 'Night alarm', 'Alarm triggered at entrance', 'INC-001'),
(NOW(), NOW(), 1, 2, 3, 1, 'Broken window', 'Window broken at entrance', 'INC-002'),
(NOW(), NOW(), 2, 3, 4, 1, 'Noise complaint', 'People shouting outside building', 'INC-003');