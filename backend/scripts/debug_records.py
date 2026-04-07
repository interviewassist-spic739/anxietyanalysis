import MySQLdb
import os
from dotenv import load_dotenv

load_dotenv()

def check_patients():
    try:
        db = MySQLdb.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=3306,
            user=os.getenv("DB_USER"),
            passwd=os.getenv("DB_PASSWORD"),
            db=os.getenv("DB_NAME")
        )
        cursor = db.cursor(MySQLdb.cursors.DictCursor)
        
        print("--- Doctors ---")
        cursor.execute("SELECT id, username, email FROM doctors")
        doctors = cursor.fetchall()
        for d in doctors:
            print(f"ID: {d['id']}, Name: {d['username']}, Email: {d['email']}")
            
        print("\n--- Patients (using app.py logic) ---")
        doctorid_int = 1 # Test for Dr. Test
        query = """
            SELECT p.*, 
                   a.anxiety_score as latest_anxiety_score, 
                   a.anxiety_level as latest_anxiety_level,
                   a.created_at as last_assessment_date
            FROM patients p
            LEFT JOIN (
                SELECT patient_id, anxiety_score, anxiety_level, created_at
                FROM assessments a1
                WHERE id = (
                    SELECT MAX(id) FROM assessments a2 WHERE a2.patient_id = a1.patient_id
                )
            ) a ON p.id = a.patient_id
            WHERE p.doctorid = %s
            ORDER BY p.id DESC
            LIMIT 10 OFFSET 0
        """
        cursor.execute(query, (doctorid_int,))
        patients = cursor.fetchall()
        print(f"Dr. Test (DID 1) patients: {len(patients)}")
        for p in patients:
            print(f"ID: {p['id']}, DID: {p['doctorid']}, Name: {p['fullname']}")

        doctorid_int = 20 # Test for Suman
        cursor.execute(query, (doctorid_int,))
        patients = cursor.fetchall()
        print(f"\nSuman (DID 20) patients: {len(patients)}")
        for p in patients:
            print(f"ID: {p['id']}, DID: {p['doctorid']}, Name: {p['fullname']}")
            
        cursor.close()
        db.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_patients()
