#!/usr/bin/env python3
"""
Upload Game Center achievement + leaderboard images to App Store Connect.

Usage:
  python3 scripts/gamecenter_upload_icons.py list
  python3 scripts/gamecenter_upload_icons.py upload <vendorId> [<vendorId> ...]
  python3 scripts/gamecenter_upload_icons.py upload-all

Images come from ICON_DIR, matched to App Store Connect vendor IDs by ID_MAP.csv
(columns: file,app_store_connect_id). Every localization of an achievement or
leaderboard gets the same image; an existing image is deleted first.
Auth reuses fetch_testflight_feedback.py (API key read from .keys/, never printed).
"""

import csv
import json
import os
import sys
import time
from urllib.request import Request, urlopen
from urllib.error import HTTPError

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fetch_testflight_feedback import generate_token, BASE_URL, KEY_PATH  # noqa: E402

BUNDLE_ID = "com.marinapollak.RenaissanceArchitectAcademy"
ICON_DIR = os.path.expanduser("~/Desktop/AssetTrim/GameCenterIcons/final_1024")

TOKEN = None


# ── HTTP ───────────────────────────────────────────────────────
def call(method, path, body=None, attempts=4):
    """JSON request to the App Store Connect API. Returns parsed JSON, {} for 204.
    Apple's API throws sporadic 500s — retry those with backoff."""
    url = path if path.startswith("http") else f"{BASE_URL}{path}"
    data = json.dumps(body).encode() if body is not None else None
    for attempt in range(attempts):
        req = Request(url, data=data, method=method)
        req.add_header("Authorization", f"Bearer {TOKEN}")
        req.add_header("Content-Type", "application/json")
        try:
            with urlopen(req) as resp:
                raw = resp.read()
                return json.loads(raw) if raw else {}
        except HTTPError as e:
            if e.code >= 500 and attempt < attempts - 1:
                time.sleep(2 ** attempt)
                continue
            raise RuntimeError(f"{method} {path} -> {e.code}: {e.read().decode()[:600]}")


def get_all(path):
    out, result = [], call("GET", path)
    out += result.get("data", [])
    while result.get("links", {}).get("next"):
        result = call("GET", result["links"]["next"])
        out += result.get("data", [])
    return out


# ── Game Center lookup ─────────────────────────────────────────
def find_items():
    """Returns {vendorId: (kind, itemId, referenceName)} for achievements + leaderboards."""
    apps = call("GET", f"/apps?filter[bundleId]={BUNDLE_ID}")["data"]
    if not apps:
        raise RuntimeError(f"No app with bundle id {BUNDLE_ID}")
    detail = call("GET", f"/apps/{apps[0]['id']}/gameCenterDetail")["data"]
    if not detail:
        raise RuntimeError("App has no Game Center detail")

    items = {}
    for kind, rel in (("achievement", "gameCenterAchievements"), ("leaderboard", "gameCenterLeaderboards")):
        for it in get_all(f"/gameCenterDetails/{detail['id']}/{rel}?limit=200"):
            a = it["attributes"]
            items[a["vendorIdentifier"]] = (kind, it["id"], a.get("referenceName", ""))
    return items


def localizations(kind, item_id):
    rel = "gameCenterAchievements" if kind == "achievement" else "gameCenterLeaderboards"
    return get_all(f"/{rel}/{item_id}/localizations?limit=50")


def existing_image(kind, loc_id):
    rel = "gameCenterAchievementLocalizations" if kind == "achievement" else "gameCenterLeaderboardLocalizations"
    img = "gameCenterAchievementImage" if kind == "achievement" else "gameCenterLeaderboardImage"
    return call("GET", f"/{rel}/{loc_id}/{img}").get("data")


# ── Upload ─────────────────────────────────────────────────────
def upload_image(kind, loc_id, path):
    img_type = "gameCenterAchievementImages" if kind == "achievement" else "gameCenterLeaderboardImages"
    loc_type = "gameCenterAchievementLocalizations" if kind == "achievement" else "gameCenterLeaderboardLocalizations"
    loc_rel = "gameCenterAchievementLocalization" if kind == "achievement" else "gameCenterLeaderboardLocalization"

    old = existing_image(kind, loc_id)
    if old:
        call("DELETE", f"/{img_type}/{old['id']}")

    blob = open(path, "rb").read()
    reservation = call("POST", f"/{img_type}", {"data": {
        "type": img_type,
        "attributes": {"fileName": os.path.basename(path), "fileSize": len(blob)},
        "relationships": {loc_rel: {"data": {"type": loc_type, "id": loc_id}}},
    }})["data"]

    for op in reservation["attributes"]["uploadOperations"]:
        chunk = blob[op["offset"]:op["offset"] + op["length"]]
        req = Request(op["url"], data=chunk, method=op["method"])
        for h in op.get("requestHeaders", []):
            req.add_header(h["name"], h["value"])
        with urlopen(req):
            pass

    done = call("PATCH", f"/{img_type}/{reservation['id']}", {"data": {
        "type": img_type, "id": reservation["id"], "attributes": {"uploaded": True},
    }})["data"]
    return done["attributes"].get("assetDeliveryState", {}).get("state", "?")


def load_id_map():
    with open(os.path.join(ICON_DIR, "ID_MAP.csv")) as f:
        return {row["app_store_connect_id"]: os.path.join(ICON_DIR, row["file"]) for row in csv.DictReader(f)}


# ── Commands ───────────────────────────────────────────────────
def cmd_list(items, id_map):
    print(f"\n{'vendor id':42} {'kind':12} locales  image?  local file")
    for vid, (kind, item_id, ref) in sorted(items.items()):
        locs = localizations(kind, item_id)
        has = sum(1 for l in locs if existing_image(kind, l["id"]))
        print(f"{vid:42} {kind:12} {len(locs):7}  {has}/{len(locs):<5} {'yes' if vid in id_map else 'MISSING'}")
    missing = sorted(set(id_map) - set(items))
    if missing:
        print("\nIn ID_MAP.csv but NOT in App Store Connect:")
        for vid in missing:
            print("  ", vid)


def cmd_upload(items, id_map, vendor_ids):
    for vid in vendor_ids:
        if vid not in items:
            print(f"SKIP {vid}: not in App Store Connect")
            continue
        if vid not in id_map:
            print(f"SKIP {vid}: no local image")
            continue
        kind, item_id, _ = items[vid]
        for loc in localizations(kind, item_id):
            state = upload_image(kind, loc["id"], id_map[vid])
            print(f"OK   {vid} [{loc['attributes'].get('locale')}] -> {state}")


def main():
    global TOKEN
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "upload", "upload-all"):
        print(__doc__)
        sys.exit(1)
    if not os.path.exists(KEY_PATH):
        sys.exit(f"API key not found at {KEY_PATH}")
    TOKEN = generate_token()

    items, id_map = find_items(), load_id_map()
    if sys.argv[1] == "list":
        cmd_list(items, id_map)
    elif sys.argv[1] == "upload":
        cmd_upload(items, id_map, sys.argv[2:])
    else:
        cmd_upload(items, id_map, sorted(id_map))


if __name__ == "__main__":
    main()
