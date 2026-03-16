from mysql.connector import Error
from datetime import datetime


def show_tables(conn):
    cursor = conn.cursor()
    try:
        cursor.execute("SHOW TABLES;")
        tables = cursor.fetchall()

        print("\n Tables in database:")
        if not tables:
            print("  (No tables found)")
            return

        for t in tables:
            print(" -", t[0])
    finally:
        cursor.close()


def show_guards(conn):
    cursor = conn.cursor()
    try:
        cursor.execute("""
            SELECT guard_id, first_name, last_name
            FROM guard
            ORDER BY guard_id;
        """)
        rows = cursor.fetchall()

        print("\n Guards:")
        if not rows:
            print("  (No guards found)")
            return

        for r in rows:
            print(f" - ID: {r[0]} | {r[1]} {r[2]}")
    except Error as err:
        print(" MySQL Error:", err)
    finally:
        cursor.close()


def show_incidents(conn):
    cursor = conn.cursor()
    query = """
    SELECT
        i.incident_id,
        i.reference_no,
        i.title,
        i.occurred_at,
        s.name AS status_name,
        CONCAT(g.first_name, ' ', g.last_name) AS guard_name,
        it.name AS type_name,
        l.name AS location_name
    FROM incident i
    LEFT JOIN status s ON i.status_id = s.status_id
    LEFT JOIN guard g ON i.guard_id = g.guard_id
    LEFT JOIN incident_type it ON i.incident_type_id = it.incident_type_id
    LEFT JOIN location l ON i.location_id = l.location_id
    ORDER BY i.incident_id DESC;
    """
    try:
        cursor.execute(query)
        rows = cursor.fetchall()

        print("\n Incidents:")
        if not rows:
            print("  (No incidents found)")
            return

        for r in rows:
            print(f" - ID: {r[0]} | Ref: {r[1]}")
            print(f"   Title: {r[2]}")
            print(f"   Occurred: {r[3]}")
            print(f"   Status: {r[4] if r[4] else '(no status)'}")
            print(f"   Guard: {r[5] if r[5] else '(no guard)'}")
            print(f"   Type: {r[6] if r[6] else '(no type)'}")
            print(f"   Location: {r[7] if r[7] else '(no location)'}")
            print()
    except Error as err:
        print(" MySQL Error:", err)
    finally:
        cursor.close()


def create_incident(conn):
    """
    Skapar ny incident (INSERT).
    """
    cursor = conn.cursor()
    try:
        print("\n--- Create new incident ---")
        location_id = int(input("Location ID: ").strip())
        incident_type_id = int(input("Incident Type ID: ").strip())
        guard_id = int(input("Guard ID (reporting guard): ").strip())
        status_id = int(input("Status ID (1=Open, 2=In Progress, 3=Closed): ").strip())

        title = input("Title: ").strip()
        description = input("Description (optional): ").strip()
        reference_no = input("Reference no (e.g. INC-002): ").strip()

        occurred_at_str = input("Occurred at (YYYY-MM-DD HH:MM) or empty for NOW: ").strip()
        if occurred_at_str:
            occurred_at = datetime.strptime(occurred_at_str, "%Y-%m-%d %H:%M")
        else:
            occurred_at = datetime.now()

        reported_at = datetime.now()

        cursor.execute("""
            INSERT INTO incident
            (occurred_at, reported_at, location_id, incident_type_id, guard_id, status_id, title, description, reference_no)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
        """, (occurred_at, reported_at, location_id, incident_type_id, guard_id, status_id, title, description, reference_no))

        conn.commit()
        print(" Incident created!")
    except ValueError:
        print(" Invalid input. IDs must be numbers, and date must match format.")
    except Error as err:
        print(" MySQL Error:", err)
    finally:
        cursor.close()


def update_incident_status(conn):
    cursor = conn.cursor()
    try:
        print("\n--- Update incident status (procedure) ---")
        incident_id = int(input("Incident ID: ").strip())
        new_status_id = int(input("New Status ID (1=Open, 2=In Progress, 3=Closed): ").strip())
        guard_id = int(input("Guard ID (who makes the change): ").strip())
        note = input("Note (optional): ").strip()

        cursor.execute("SET @p_incident_id = %s", (incident_id,))
        cursor.execute("SET @p_new_status_id = %s", (new_status_id,))
        cursor.execute("SET @p_guard_id = %s", (guard_id,))
        cursor.execute("CALL update_incident_status()")
        conn.commit()

        if note:
            cursor.execute("""
                UPDATE incident_status_history
                SET note = %s
                WHERE incident_id = %s
                ORDER BY history_id DESC
                LIMIT 1
            """, (note, incident_id))
            conn.commit()

        print(" Status updated via stored procedure!")

    except ValueError:
        print(" Invalid input. IDs must be numbers.")
    except Error as err:
        print(" MySQL Error:", err)
    finally:
        cursor.close()


def show_incident_history(conn):
    """
    Visar status-historik för en incident (bevisar trigger).
    """
    cursor = conn.cursor()
    try:
        incident_id = int(input("Incident ID: ").strip())

        query = """
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
        WHERE h.incident_id = %s
        ORDER BY h.history_id DESC;
        """
        cursor.execute(query, (incident_id,))
        rows = cursor.fetchall()

        print("\n Status history:")
        if not rows:
            print("  (No history found)")
            return

        for r in rows:
            print(f" - HistoryID: {r[0]} | Incident: {r[1]}")
            print(f"   {r[2]} -> {r[3]} | By: {r[4]} | At: {r[5]}")
            print(f"   Note: {r[6]}")
            print()
    except ValueError:
        print(" Please enter a valid incident id.")
    except Error as err:
        print(" MySQL Error:", err)
    finally:
        cursor.close()


def stats_incidents_per_location(conn):
    cursor = conn.cursor()
    try:
        cursor.execute("""
            SELECT l.name AS location, COUNT(*) AS total_incidents
            FROM incident i
            JOIN location l ON i.location_id = l.location_id
            GROUP BY l.location_id, l.name
            ORDER BY total_incidents DESC;
        """)
        rows = cursor.fetchall()

        print("\n Incidents per location:")
        if not rows:
            print("  (No data)")
            return

        for r in rows:
            print(f" - {r[0]}: {r[1]}")
    except Error as err:
        print(" MySQL Error:", err)
    finally:
        cursor.close()


def stats_incidents_per_type(conn):
    cursor = conn.cursor()
    try:
        cursor.execute("""
            SELECT it.name AS incident_type, COUNT(*) AS total_incidents
            FROM incident i
            JOIN incident_type it ON i.incident_type_id = it.incident_type_id
            GROUP BY it.incident_type_id, it.name
            ORDER BY total_incidents DESC;
        """)
        rows = cursor.fetchall()

        print("\n Incidents per incident type:")
        if not rows:
            print("  (No data)")
            return

        for r in rows:
            print(f" - {r[0]}: {r[1]}")
    except Error as err:
        print(" MySQL Error:", err)
    finally:
        cursor.close()