#!/usr/bin/env python3
"""
Sync TestFlight feedback to the repo for the remote agent to process.
Run manually or via cron: python3 scripts/sync_feedback.py

Pulls all screenshot feedback from App Store Connect API,
saves to feedback/latest_feedback.json, commits and pushes.
"""

import jwt
import time
import json
import os
import subprocess
from datetime import datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
FEEDBACK_DIR = os.path.join(PROJECT_ROOT, "feedback")

ISSUER_ID = "3f1156c0-ced8-4dd3-9a13-8a9bb13ef9f1"
KEY_ID = "XR8FTQGT47"
KEY_PATH = os.path.join(PROJECT_ROOT, ".keys", f"AuthKey_{KEY_ID}.p8")
BASE_URL = "https://api.appstoreconnect.apple.com/v1"
APP_ID = "6760910118"

from urllib.request import Request, urlopen
from urllib.error import HTTPError


def generate_token():
    with open(KEY_PATH, "r") as f:
        private_key = f.read()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"})


def api_get(path, token):
    url = f"{BASE_URL}{path}"
    req = Request(url)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    try:
        with urlopen(req) as resp:
            return json.loads(resp.read().decode())
    except HTTPError as e:
        return {"error": e.code, "body": e.read().decode()[:300]}


def main():
    print("=" * 50)
    print("  TestFlight Feedback Sync")
    print("=" * 50)

    os.makedirs(FEEDBACK_DIR, exist_ok=True)

    # Generate token
    token = generate_token()

    # Get builds
    builds = api_get(f"/builds?filter[app]={APP_ID}&sort=-uploadedDate&limit=10"
                     f"&fields[builds]=version,uploadedDate,processingState", token)

    build_list = []
    for b in builds.get("data", []):
        build_list.append({
            "id": b["id"],
            "version": b["attributes"].get("version", "?"),
            "uploaded": b["attributes"].get("uploadedDate", "?"),
            "state": b["attributes"].get("processingState", "?"),
        })

    # Get testers
    testers = api_get(f"/betaTesters?filter[apps]={APP_ID}"
                      f"&fields[betaTesters]=firstName,lastName,email,state", token)

    tester_list = []
    for t in testers.get("data", []):
        attrs = t.get("attributes", {})
        tester_list.append({
            "name": f"{attrs.get('firstName', '')} {attrs.get('lastName', '')}".strip(),
            "email": attrs.get("email", ""),
            "state": attrs.get("state", ""),
        })

    # Try to read feedback from Xcode local cache
    xcode_feedback_dir = os.path.expanduser(
        "~/Library/Developer/Xcode/Products/"
        "com.marinapollak.RenaissanceArchitectAcademy/Feedback/Points"
    )

    feedback_items = []
    if os.path.exists(xcode_feedback_dir):
        import glob
        for point_file in glob.glob(os.path.join(xcode_feedback_dir, "**", "PointInfo.json"), recursive=True):
            with open(point_file) as f:
                info = json.load(f)

            tester = info.get("testerInfo", {})
            device = info.get("deviceMetadata", {})
            app_info = info.get("appInfo", {})

            # Find screenshot
            parent = os.path.dirname(point_file)
            images_dir = os.path.join(parent, "Images")
            has_screenshot = os.path.exists(images_dir) and any(
                f.startswith("Original") for f in os.listdir(images_dir)
            ) if os.path.exists(images_dir) else False

            feedback_items.append({
                "id": info.get("identifier", {}).get("id", ""),
                "comment": info.get("comment", ""),
                "timestamp": info.get("timestamp", ""),
                "tester": f"{tester.get('firstName', '')} {tester.get('lastName', '')}".strip(),
                "email": tester.get("emailAddress", ""),
                "device": device.get("deviceModel", ""),
                "os": device.get("osVersion", ""),
                "build": app_info.get("buildNumber", ""),
                "version": app_info.get("versionString", ""),
                "has_screenshot": has_screenshot,
            })

    # Sort by timestamp
    feedback_items.sort(key=lambda x: x.get("timestamp", ""), reverse=True)

    # Build the output
    output = {
        "synced_at": datetime.utcnow().isoformat() + "Z",
        "app_id": APP_ID,
        "builds": build_list,
        "testers": tester_list,
        "feedback": feedback_items,
        "total_feedback": len(feedback_items),
    }

    # Save
    output_path = os.path.join(FEEDBACK_DIR, "latest_feedback.json")
    with open(output_path, "w") as f:
        json.dump(output, f, indent=2)

    print(f"\n  Synced {len(feedback_items)} feedback items")
    print(f"  Saved to: feedback/latest_feedback.json")

    # Git commit and push
    os.chdir(PROJECT_ROOT)
    subprocess.run(["git", "add", "feedback/latest_feedback.json"], check=True)

    result = subprocess.run(["git", "diff", "--cached", "--quiet"], capture_output=True)
    if result.returncode != 0:
        subprocess.run([
            "git", "commit", "-m",
            f"Sync TestFlight feedback ({len(feedback_items)} items, {datetime.now().strftime('%Y-%m-%d')})"
        ], check=True)
        subprocess.run(["git", "push", "origin", "main"], check=True)
        print("  Committed and pushed to GitHub")
    else:
        print("  No new changes to commit")

    print("=" * 50)


if __name__ == "__main__":
    main()
