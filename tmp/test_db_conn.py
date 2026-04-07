import os
import MySQLdb
from dotenv import load_dotenv

# Load environment variables
load_dotenv(r'c:\Users\bhanu\StudioProjects\anxietyanalysis\backend\.env')

def test_connection():
    host_full = os.getenv("DB_HOST", "localhost")
    if ":" in host_full:
        host = host_full.split(":")[0]
        port = int(host_full.split(":")[1])
    else:
        host = host_full
        port = 3306
        
    user = os.getenv("DB_USER", "root")
    passwd = os.getenv("DB_PASSWORD", "")
    db_name = os.getenv("DB_NAME", "anxi")

    print(f"Attempting to connect to {host}:{port} as {user} to database '{db_name}'...")
    
    try:
        db = MySQLdb.connect(
            host=host,
            port=port,
            user=user,
            passwd=passwd,
            db=db_name,
            charset="utf8"
        )
        print("SUCCESS: Connection established!")
        
        cursor = db.cursor()
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        
        if tables:
            print(f"Found {len(tables)} tables:")
            for table in tables:
                print(f" - {table[0]}")
        else:
            print("INFO: No tables found in the database.")
            
        cursor.close()
        db.close()
    except Exception as e:
        print(f"ERROR: Connection failed with empty password: {e}")
        
        # Try fallback to '3012' password
        print("\nRetrying with password '3012' from documentation...")
        try:
            db = MySQLdb.connect(
                host=host,
                port=port,
                user=user,
                passwd="3012",
                db=db_name,
                charset="utf8"
            )
            print("SUCCESS: Connection established with password '3012'!")
            cursor = db.cursor()
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            if tables:
                print(f"Found {len(tables)} tables:")
                for table in tables:
                    print(f" - {table[0]}")
            else:
                print("INFO: No tables found in the database.")
            cursor.close()
            db.close()
        except Exception as e2:
            print(f"ERROR: Retry also failed: {e2}")

if __name__ == "__main__":
    test_connection()
