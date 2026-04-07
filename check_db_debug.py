import MySQLdb
import os
from dotenv import load_dotenv

load_dotenv()

def check_db():
    try:
        db = MySQLdb.connect(
            host=os.getenv("DB_HOST", "localhost"),
            user=os.getenv("DB_USER", "root"),
            passwd=os.getenv("DB_PASSWORD", ""),
            db=os.getenv("DB_NAME", "anxi")
        )
        cursor = db.cursor()
        
        print("--- Table Structure: assessments ---")
        cursor.execute("DESCRIBE assessments")
        for row in cursor.fetchall():
            print(row)
            
        print("\n--- Recent Records (Last 5) ---")
        cursor.execute("SELECT id, patient_id, created_at, anxiety_score, procedure_type FROM assessments ORDER BY created_at DESC LIMIT 5")
        for row in cursor.fetchall():
            print(row)
            
        db.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_db()
