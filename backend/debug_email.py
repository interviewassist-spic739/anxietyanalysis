import smtplib
import ssl
import os
import traceback
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

sender_email = os.getenv("EMAIL_USER")
password = os.getenv("EMAIL_PASS")
receiver_email = sender_email  # Send to self for testing

print(f"DEBUG: EMAIL_USER is {sender_email}")
print(f"DEBUG: EMAIL_PASS is {'Set (length=' + str(len(password)) + ')' if password else 'NOT SET'}")

if not sender_email or not password:
    print("ERROR: Make sure EMAIL_USER and EMAIL_PASS are set in your .env file.")
else:
    subject = "AnxiSense SMTP Connection Test"
    body = "This is a test email to confirm that the SMTP connection from your Python backend is working correctly."
    
    message = f"Subject: {subject}\n\n{body}"
    
    context = ssl.create_default_context()
    
    print(f"Attempting to connect to smtp.gmail.com:587 as {sender_email}...")
    
    try:
        # Connect to Gmail's SMTP server
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            print("Successfully connected to the SMTP server.")
            
            # Start TLS for security
            print("Starting TLS...")
            server.starttls(context=context)
            print("TLS connection established.")
            
            # Log in to the email account
            print("Logging in...")
            server.login(sender_email, password)
            print("Login successful.")
            
            # Send the test email
            print(f"Sending test email to {receiver_email}...")
            server.sendmail(sender_email, receiver_email, message)
            
            print("SUCCESS: Test email sent successfully!")
            print("Check your inbox to confirm reception.")
    
    except smtplib.SMTPAuthenticationError as e:
        print(f"ERROR: SMTP Authentication Error: {e}")
        print("REASON: This usually means your EMAIL_USER and EMAIL_PASS are incorrect.")
        print("FIX: If you use 2-Factor Authentication, you MUST use a Google 'App Password'.")
        
    except ConnectionRefusedError:
        print("ERROR: Connection Refused: The server at smtp.gmail.com:587 refused the connection.")
        print("REASON: This might be a temporary issue with Google's servers or local network blocking.")
        
    except smtplib.SMTPServerDisconnected:
        print("ERROR: Server Disconnected: The connection to the SMTP server was lost unexpectedly.")

    except Exception as e:
        print(f"ERROR: An unexpected error occurred: {e}")
        traceback.print_exc()
