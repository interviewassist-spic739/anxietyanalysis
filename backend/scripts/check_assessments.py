import MySQLdb
import os
from dotenv import load_dotenv

load_dotenv()

def check_assessments(doctor_id):
    try:
        db = MySQLdb.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=3306,
            user=os.getenv("DB_USER"),
            passwd=os.getenv("DB_PASSWORD"),
            db=os.getenv("DB_NAME")
        )
        cursor = db.cursor(MySQLdb.cursors.DictCursor)
        
        print(f"--- Assessments for Doctor ID: {doctor_id} ---")
        # Join with patients to see if the patient actually belongs to this doctor
        query = """
            SELECT a.id, a.patient_id, a.doctor_id, p.fullname, p.doctorid as patient_owner_id
            FROM assessments a
            JOIN patients p ON a.patient_id = p.id
            WHERE a.doctor_id = %s
        """
        cursor.execute(query, (doctor_id,))
        assessments = cursor.fetchall()
        print(f"Total assessments found: {len(assessments)}")
        
        leaks = 0
        for a in assessments:
            if a['doctor_id'] != a['patient_owner_id']:
                print(f"!!! DISCREPANCY: Assessment {a['id']} (Doc {a['doctor_id']}) is for Patient {a['fullname']} (Owner {a['patient_owner_id']})")
                leaks += 1
        
        if leaks == 0:
            print("No cross-doctor assessments found.")
            
        cursor.close()
        db.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_assessments(20)
    check_assessments(1)
