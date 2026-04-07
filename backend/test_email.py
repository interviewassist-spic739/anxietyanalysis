
import smtplib
import ssl
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

sender_email = os.getenv("EMAIL_USER")
password = os.getenv("EMAIL_PASS")
receiver_email = sender_email  # Send to self for testing

if not sender_email or not password:
    print("❌ Error: Make sure EMAIL_USER and EMAIL_PASS are set in your .env file.")
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
            
            print("✅ Test email sent successfully!")
            print("Check your inbox to confirm reception.")
    
    except smtplib.SMTPAuthenticationError as e:
        print(f"❌ SMTP Authentication Error: {e}")
        print("   Please check your EMAIL_USER and EMAIL_PASS in the .env file.")
        print("   If you use 2-Factor Authentication, you must use a Google 'App Password'.")
        
    except ConnectionRefusedError:
        print("❌ Connection Refused: The server at smtp.gmail.com:587 refused the connection.")
        print("   This might be a temporary issue with Google's servers.")
        
    except smtplib.SMTPServerDisconnected:
        print("❌ Server Disconnected: The connection to the SMTP server was lost unexpectedly.")

    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")
        print("   This is likely a network issue. Check the following:")
        print("   1. Your internet connection.")
        print("   2. Your firewall or antivirus software is not blocking Python or port 587.")
        print("   3. Your ISP is not blocking port 587.")

