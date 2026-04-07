import requests
import json

BASE_URL = "http://127.0.0.1:5000/api"

def test_filtering(doctor_id):
    print(f"\n--- Testing for Doctor ID: {doctor_id} ---")
    resp = requests.get(f"{BASE_URL}/patients?doctorid={doctor_id}")
    if resp.status_code == 200:
        data = resp.json()
        patients = data.get("data", [])
        print(f"Total patients returned: {len(patients)}")
        for p in patients[:5]: # Show first 5
            print(f"Patient ID: {p['id']}, DID in record: {p['doctorid']}, Name: {p['fullname']}")
            if str(p['doctorid']) != str(doctor_id):
                print(f"!!! DATA LEAK detected: Patient DOES NOT belong to doctor {doctor_id}")
    else:
        print(f"Error: {resp.status_code} - {resp.text}")

if __name__ == "__main__":
    test_filtering(1)
    test_filtering(20)
