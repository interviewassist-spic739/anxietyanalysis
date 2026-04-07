import MySQLdb
import os
import json
from dotenv import load_dotenv

load_dotenv()

def migrate():
    try:
        db = MySQLdb.connect(
            host=os.getenv("DB_HOST", "localhost"),
            user=os.getenv("DB_USER"),
            passwd=os.getenv("DB_PASSWORD"),
            db=os.getenv("DB_NAME")
        )
        cursor = db.cursor()
        
        # Add emotions column if it doesn't exist
        print("Checking for emotions column...")
        cursor.execute("SHOW COLUMNS FROM assessments LIKE 'emotions'")
        if not cursor.fetchone():
            print("Adding emotions column to assessments table...")
            # Use JSON if supported, otherwise TEXT
            cursor.execute("ALTER TABLE assessments ADD COLUMN emotions TEXT AFTER dominant_emotion")
            print("Emotions column added.")
        else:
            print("Emotions column already exists.")
            
        db.commit()
        cursor.close()
        db.close()
        print("Migration successful.")
    except Exception as e:
        print(f"Migration failed: {e}")

if __name__ == "__main__":
    migrate()
