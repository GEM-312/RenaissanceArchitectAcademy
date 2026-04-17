#!/usr/bin/env python3
"""
Fetch TestFlight feedback from App Store Connect API.
Usage: python3 scripts/fetch_testflight_feedback.py
"""

import jwt
import time
import json
import sys
import os
from datetime import datetime, timezone
from urllib.request import Request, urlopen
from urllib.error import HTTPError

# ── Configuration ──────────────────────────────────────────────
ISSUER_ID = "3f1156c0-ced8-4dd3-9a13-8a9bb13ef9f1"
KEY_ID = "XR8FTQGT47"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
KEY_PATH = os.path.join(PROJECT_ROOT, ".keys", f"AuthKey_{KEY_ID}.p8")

BASE_URL = "https://api.appstoreconnect.apple.com/v1"


# ── JWT Token Generation ──────────────────────────────────────
def generate_token():
    """Generate a signed JWT for App Store Connect API."""
    with open(KEY_PATH, "r") as f:
        private_key = f.read()

    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,  # 20 minutes
        "aud": "appstoreconnect-v1",
    }
    headers = {
        "alg": "ES256",
        "kid": KEY_ID,
        "typ": "JWT",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)


# ── API Helpers ────────────────────────────────────────────────
def api_get(path, token, params=None):
    """Make a GET request to the App Store Connect API."""
    url = f"{BASE_URL}{path}"
    if params:
        query = "&".join(f"{k}={v}" for k, v in params.items())
        url += f"?{query}"

    req = Request(url)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")

    try:
        with urlopen(req) as resp:
            return json.loads(resp.read().decode())
    except HTTPError as e:
        body = e.read().decode()
        print(f"\n  API Error {e.code}: {body}")
        return None


def paginate_all(path, token, params=None):
    """Fetch all pages of a paginated API response."""
    all_data = []
    result = api_get(path, token, params)
    if not result:
        return all_data

    all_data.extend(result.get("data", []))

    while result.get("links", {}).get("next"):
        next_url = result["links"]["next"]
        # Extract path from full URL
        next_path = next_url.replace(BASE_URL, "")
        req = Request(next_url)
        req.add_header("Authorization", f"Bearer {token}")
        req.add_header("Content-Type", "application/json")
        try:
            with urlopen(req) as resp:
                result = json.loads(resp.read().decode())
                all_data.extend(result.get("data", []))
        except HTTPError:
            break

    return all_data


# ── Fetch App & Builds ────────────────────────────────────────
def find_app(token):
    """Find the Renaissance Architect Academy app."""
    data = api_get("/apps", token, {"limit": "50"})
    if not data:
        return None

    for app in data.get("data", []):
        name = app["attributes"].get("name", "")
        bundle = app["attributes"].get("bundleId", "")
        print(f"  Found app: {name} ({bundle})")
        # Return first app (or match by name)
        if "renaissance" in name.lower() or "architect" in name.lower() or "raa" in bundle.lower():
            return app

    # If no match, return first app
    if data.get("data"):
        app = data["data"][0]
        print(f"  Using: {app['attributes'].get('name', 'Unknown')}")
        return app
    return None


def get_builds(token, app_id):
    """Get recent TestFlight builds."""
    return paginate_all(
        f"/builds",
        token,
        {
            "filter[app]": app_id,
            "sort": "-uploadedDate",
            "limit": "10",
            "fields[builds]": "version,uploadedDate,processingState,buildAudienceType",
        },
    )


# ── Fetch Feedback ─────────────────────────────────────────────
def get_beta_testers(token, app_id):
    """List all beta testers for the app."""
    return paginate_all(
        "/betaTesters",
        token,
        {
            "filter[apps]": app_id,
            "fields[betaTesters]": "firstName,lastName,email,inviteType,state",
        },
    )


def get_beta_feedback(token, build_id):
    """Get screenshot feedback for a specific build."""
    # Try the beta feedback screenshot submissions endpoint
    return paginate_all(
        f"/builds/{build_id}/betaAppReviewSubmission",
        token,
    )


def get_beta_build_localizations(token, build_id):
    """Get build-level feedback/notes."""
    return paginate_all(
        f"/builds/{build_id}/betaBuildLocalizations",
        token,
    )


# ── Main ───────────────────────────────────────────────────────
def main():
    print("=" * 60)
    print("  TestFlight Feedback — Renaissance Architect Academy")
    print("=" * 60)

    # Check key exists
    if not os.path.exists(KEY_PATH):
        print(f"\n  Private key not found: {KEY_PATH}")
        print("  Place your AuthKey_XR8FTQGT47.p8 in .keys/")
        sys.exit(1)

    # Generate token
    print("\n  Generating JWT token...")
    token = generate_token()
    print("  Token generated.")

    # Find app
    print("\n── Finding App ──────────────────────────────────")
    app = find_app(token)
    if not app:
        print("  No apps found. Check your API key permissions.")
        sys.exit(1)

    app_id = app["id"]
    app_name = app["attributes"].get("name", "Unknown")
    print(f"  App ID: {app_id}")

    # List testers
    print("\n── Beta Testers ─────────────────────────────────")
    testers = get_beta_testers(token, app_id)
    if testers:
        for t in testers:
            attrs = t.get("attributes", {})
            name = f"{attrs.get('firstName', '')} {attrs.get('lastName', '')}".strip()
            email = attrs.get("email", "")
            state = attrs.get("state", "")
            print(f"  {name} ({email}) — {state}")
    else:
        print("  No testers found or no access.")

    # List recent builds
    print("\n── Recent Builds ────────────────────────────────")
    builds = get_builds(token, app_id)
    if not builds:
        print("  No builds found.")
        sys.exit(0)

    for b in builds[:5]:
        attrs = b.get("attributes", {})
        ver = attrs.get("version", "?")
        date = attrs.get("uploadedDate", "?")[:10]
        state = attrs.get("processingState", "?")
        print(f"  Build {ver} — {date} ({state})")

    # Fetch feedback for each build
    print("\n── Feedback ─────────────────────────────────────")
    found_feedback = False

    for build in builds[:5]:
        build_id = build["id"]
        build_ver = build["attributes"].get("version", "?")

        # Build localizations (What's New text + notes)
        localizations = get_beta_build_localizations(token, build_id)
        if localizations:
            for loc in localizations:
                attrs = loc.get("attributes", {})
                whats_new = attrs.get("whatsNew", "")
                if whats_new:
                    print(f"\n  Build {build_ver} — What's New:")
                    print(f"    {whats_new}")

        # Try screenshot/crash feedback endpoints
        # The newer Feedback API endpoints
        feedback_endpoints = [
            f"/builds/{build_id}/relationships/betaAppReviewSubmission",
        ]

        for endpoint in feedback_endpoints:
            result = api_get(endpoint, token)
            if result and result.get("data"):
                found_feedback = True
                print(f"\n  Build {build_ver} — Feedback:")
                print(f"    {json.dumps(result['data'], indent=4)}")

    # Try app-level feedback
    print("\n── App-Level Feedback ───────────────────────────")
    app_feedback_endpoints = [
        f"/apps/{app_id}/betaAppReviewDetail",
        f"/apps/{app_id}/betaFeedbackScreenshots",
        f"/apps/{app_id}/betaFeedbackCrashes",
    ]

    for endpoint in app_feedback_endpoints:
        result = api_get(endpoint, token)
        if result and result.get("data"):
            found_feedback = True
            data = result["data"]
            if isinstance(data, list):
                print(f"\n  {endpoint.split('/')[-1]}:")
                for item in data:
                    attrs = item.get("attributes", {})
                    print(f"    {json.dumps(attrs, indent=4)}")
            else:
                attrs = data.get("attributes", {})
                if attrs:
                    print(f"\n  {endpoint.split('/')[-1]}:")
                    print(f"    {json.dumps(attrs, indent=4)}")

    if not found_feedback:
        print("\n  No screenshot/crash feedback found via API.")
        print("  Tester comments may only be visible in App Store Connect web UI:")
        print("  https://appstoreconnect.apple.com → TestFlight → Feedback")

    print("\n" + "=" * 60)
    print("  Done!")
    print("=" * 60)


if __name__ == "__main__":
    main()
