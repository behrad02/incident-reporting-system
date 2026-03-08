-- =====================================
-- DATABASE
-- =====================================

CREATE DATABASE IF NOT EXISTS dv1587;
USE dv1587;

-- =====================================
-- STATUS TABLE
-- =====================================

CREATE TABLE status (
  status_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
);

-- =====================================
-- GUARD TABLE
-- =====================================

CREATE TABLE guard (
  guard_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  phone VARCHAR(30),
  email VARCHAR(120),
  employee_no VARCHAR(20) NOT NULL UNIQUE,
  active BOOLEAN NOT NULL DEFAULT TRUE
);

-- =====================================
-- LOCATION TABLE
-- =====================================

CREATE TABLE location (
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  address VARCHAR(200),
  city VARCHAR(80),
  site_code VARCHAR(30) NOT NULL UNIQUE,
  active BOOLEAN NOT NULL DEFAULT TRUE
);

-- =====================================
-- INCIDENT TYPE TABLE
-- =====================================

CREATE TABLE incident_type (
  incident_type_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL UNIQUE,
  description VARCHAR(255),
  severity_level INT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  CHECK (severity_level BETWEEN 1 AND 5)
);

-- =====================================
-- INCIDENT TABLE
-- =====================================

CREATE TABLE incident (
  incident_id INT AUTO_INCREMENT PRIMARY KEY,
  occurred_at DATETIME NOT NULL,
  reported_at DATETIME NOT NULL,
  location_id INT NOT NULL,
  incident_type_id INT NOT NULL,
  guard_id INT NOT NULL,
  status_id INT NOT NULL,
  title VARCHAR(120) NOT NULL,
  description TEXT,
  reference_no VARCHAR(50) NOT NULL UNIQUE,

  CONSTRAINT fk_incident_location
    FOREIGN KEY (location_id) REFERENCES location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_incident_type
    FOREIGN KEY (incident_type_id) REFERENCES incident_type(incident_type_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_incident_guard
    FOREIGN KEY (guard_id) REFERENCES guard(guard_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_incident_status
    FOREIGN KEY (status_id) REFERENCES status(status_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =====================================
-- INCIDENT STATUS HISTORY TABLE
-- =====================================

CREATE TABLE incident_status_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  incident_id INT NOT NULL,
  old_status_id INT,
  new_status_id INT NOT NULL,
  changed_by_guard_id INT NOT NULL,
  changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  note VARCHAR(255),

  CONSTRAINT fk_hist_incident
    FOREIGN KEY (incident_id) REFERENCES incident(incident_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  CONSTRAINT fk_hist_old_status
    FOREIGN KEY (old_status_id) REFERENCES status(status_id)
    ON UPDATE CASCADE ON DELETE SET NULL,

  CONSTRAINT fk_hist_new_status
    FOREIGN KEY (new_status_id) REFERENCES status(status_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_hist_changed_by_guard
    FOREIGN KEY (changed_by_guard_id) REFERENCES guard(guard_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =====================================
-- INDEXES (FOR PERFORMANCE)
-- =====================================

CREATE INDEX idx_incident_status ON incident(status_id);
CREATE INDEX idx_incident_location ON incident(location_id);
CREATE INDEX idx_incident_type ON incident(incident_type_id);
CREATE INDEX idx_incident_guard ON incident(guard_id);
CREATE INDEX idx_hist_incident ON incident_status_history(incident_id);
