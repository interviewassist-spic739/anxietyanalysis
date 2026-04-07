import requests

base_url = "http://127.0.0.1:5000/api/patients"
doctor_id = 1 # Assuming doctorid 1 exists

print(f"Testing pagination for doctor_id {doctor_id}")

# Test page 1, limit 2
params = {"doctorid": doctor_id, "page": 1, "limit": 2}
try:
    response = requests.get(base_url, params=params)
    print(f"Status: {response.status_code}")
    data = response.json()
    if data.get("success"):
        patients = data.get("data", [])
        pagination = data.get("pagination", {})
        print(f"Received {len(patients)} patients (Expected limit 2)")
        print(f"Pagination data: {pagination}")
    else:
         print(f"Error: {data.get('message')}")
except Exception as e:
    print(f"Request failed: {e}")
