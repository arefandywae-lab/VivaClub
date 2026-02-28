import requests
BASE_URL = "https://vivaclubs.site"
USERNAME = "audi"
PASSWORD = "Alfata0232"

login_url = f"{BASE_URL}/api/auth/login/"
res = requests.post(login_url, json={"username": USERNAME, "password": PASSWORD})
token = res.json().get("access")

headers = {
    "Authorization": f"Bearer {token}",
}

res = requests.get(f"{BASE_URL}/api/auth/profile/", headers=headers)
print("PROFILE STATUS:", res.status_code)
print("PROFILE RESPONSE:", res.json())
