import MySQLdb
import os
from dotenv import load_dotenv

load_dotenv()

def migrate():
    try:
        db = MySQLdb.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=3306,
            user=os.getenv("DB_USER"),
            passwd=os.getenv("DB_PASSWORD"),
            db=os.getenv("DB_NAME")
        )
        cursor = db.cursor()
        
        # Add columns if they don't exist
        print("Checking for procedure_type and health_issues columns...")
        
        cursor.execute("SHOW COLUMNS FROM assessments LIKE 'procedure_type'")
        if not cursor.fetchone():
            print("Adding procedure_type column...")
            cursor.execute("ALTER TABLE assessments ADD COLUMN procedure_type VARCHAR(255) AFTER dominant_emotion")
            
        cursor.execute("SHOW COLUMNS FROM assessments LIKE 'health_issues'")
        if not cursor.fetchone():
            print("Adding health_issues column...")
            cursor.execute("ALTER TABLE assessments ADD COLUMN health_issues TEXT AFTER procedure_type")
            
        db.commit()
        print("Migration successful.")
        cursor.close()
        db.close()
    except Exception as e:
        print(f"Migration failed: {e}")

if __name__ == "__main__":
    migrate()
