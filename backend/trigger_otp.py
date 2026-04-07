import requests
import json

url = "http://localhost:5000/api/doctor/send-otp"
data = {"email": "sumanraj71718@gmail.com"}

try:
    print(f"Sending OTP request to {url}...")
    response = requests.post(url, json=data)
    print(f"Status Code: {response.status_code}")
    print(f"Response Body: {response.text}")
except Exception as e:
    print(f"Error: {e}")
