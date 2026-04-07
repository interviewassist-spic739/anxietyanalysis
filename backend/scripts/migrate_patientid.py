import MySQLdb
import os
from dotenv import load_dotenv

load_dotenv('anxisense_backend/.env')

try:
    db = MySQLdb.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        passwd=os.getenv("DB_PASSWORD"),
        db=os.getenv("DB_NAME")
    )
    cursor = db.cursor()
    
    print("Migrating patients table...")
    # Change patientid to VARCHAR(50)
    cursor.execute("ALTER TABLE patients MODIFY COLUMN patientid VARCHAR(50)")
    db.commit()
    print("Successfully changed patientid to VARCHAR(50)")

    cursor.close()
    db.close()

except Exception as e:
    print(f"Migration failed: {e}")
