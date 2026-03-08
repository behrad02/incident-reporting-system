from db import connect_db
import Functions as q


def print_menu():
    print("""
========================
1. Show tables
2. Show guards
3. Show incidents
4. Create incident
5. Update incident status
6. Show incident status history
7. Stats per location
8. Stats per incident type
9. Exit
========================
""")


def main():
    conn = connect_db()
    if not conn:
        return

    try:
        while True:
            print_menu()
            choice = input("Choose option: ").strip()

            if choice == "1":
                q.show_tables(conn)
            elif choice == "2":
                q.show_guards(conn)
            elif choice == "3":
                q.show_incidents(conn)
            elif choice == "4":
                q.create_incident(conn)
            elif choice == "5":
                q.update_incident_status(conn)
            elif choice == "6":
                q.show_incident_history(conn)
            elif choice == "7":
                q.stats_incidents_per_location(conn)
            elif choice == "8":
                q.stats_incidents_per_type(conn)
            elif choice == "9":
                break
            else:
                print("Invalid choice. Try again.")
    finally:
        conn.close()
        print(" Connection closed.")


if __name__ == "__main__":
    main()