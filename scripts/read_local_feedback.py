#!/usr/bin/env python3
"""
Read TestFlight feedback from Xcode's local cache.
Run AFTER opening each feedback item in Xcode Organizer → Feedback.

Usage: python3 scripts/read_local_feedback.py
"""

import json
import os
import glob
from datetime import datetime

FEEDBACK_DIR = os.path.expanduser(
    "~/Library/Developer/Xcode/Products/"
    "com.marinapollak.RenaissanceArchitectAcademy/Feedback"
)

def main():
    print("=" * 60)
    print("  TestFlight Feedback (Local Xcode Cache)")
    print("=" * 60)

    # Read all cached feedback points
    points_dir = os.path.join(FEEDBACK_DIR, "Points")
    if not os.path.exists(points_dir):
        print("\n  No feedback cache found.")
        print("  Open Xcode → Window → Organizer → Feedback")
        print("  Click each feedback item to download it.")
        return

    # Find all PointInfo.json files
    pattern = os.path.join(points_dir, "**", "PointInfo.json")
    point_files = glob.glob(pattern, recursive=True)

    if not point_files:
        print("\n  No feedback items cached yet.")
        print("  Open each feedback in Xcode Organizer to cache it.")
        return

    # Also check URLModeListableFeedback.json for items not yet opened
    listable_path = os.path.join(FEEDBACK_DIR, "URLModeListableFeedback.json")
    url_feedbacks = []
    if os.path.exists(listable_path):
        with open(listable_path) as f:
            data = json.load(f)
        for item in data.get("recentItems", []):
            value = item.get("value", {})
            feedbacks = value.get("feedbacks", [])
            url_feedbacks.extend(feedbacks)

    # Parse and display cached feedback
    feedback_items = []

    for pf in point_files:
        with open(pf) as f:
            info = json.load(f)

        tester = info.get("testerInfo", {})
        name = f"{tester.get('firstName', '')} {tester.get('lastName', '')}".strip()
        comment = info.get("comment", "")
        ts = info.get("timestamp", "")
        device = info.get("deviceMetadata", {})
        app = info.get("appInfo", {})

        # Find associated screenshot
        parent = os.path.dirname(pf)
        images_dir = os.path.join(parent, "Images")
        screenshots = []
        if os.path.exists(images_dir):
            screenshots = [
                os.path.join(images_dir, f)
                for f in os.listdir(images_dir)
                if f.startswith("Original")
            ]

        feedback_items.append({
            "name": name,
            "comment": comment,
            "timestamp": ts,
            "device": device.get("deviceModel", ""),
            "os": device.get("osVersion", ""),
            "build": app.get("buildNumber", ""),
            "version": app.get("versionString", ""),
            "screenshots": screenshots,
        })

    # Add URL-mode feedbacks not yet in points
    cached_comments = {fi["comment"] for fi in feedback_items}
    for uf in url_feedbacks:
        comment = uf.get("comment", "")
        if comment and comment not in cached_comments:
            feedback_items.append({
                "name": f"{uf.get('firstName', '')} {uf.get('lastName', '')}".strip(),
                "comment": comment,
                "timestamp": uf.get("timestamp", ""),
                "device": uf.get("deviceModel", ""),
                "os": uf.get("osVersion", ""),
                "build": uf.get("buildNumber", ""),
                "version": uf.get("versionString", ""),
                "screenshots": [],
            })

    # Sort by timestamp (newest first)
    feedback_items.sort(key=lambda x: x["timestamp"], reverse=True)

    print(f"\n  Found {len(feedback_items)} feedback item(s)\n")

    for i, fb in enumerate(feedback_items, 1):
        ts = fb["timestamp"][:10] if fb["timestamp"] else "?"
        print(f"── [{i}] {fb['name']} ──────────────────────────")
        print(f"   Date:    {ts}")
        print(f"   Device:  {fb['device']} (iOS {fb['os']})")
        print(f"   Build:   {fb['version']} ({fb['build']})")
        print(f"   Comment: {fb['comment']}")
        if fb["screenshots"]:
            for sc in fb["screenshots"]:
                print(f"   Screenshot: {sc}")
        print()

    print("=" * 60)
    total_points = len(glob.glob(os.path.join(points_dir, "*.xcfeedbackpoint")))
    print(f"  {total_points} item(s) cached in Xcode | {len(url_feedbacks)} from URL mode")
    if total_points < 6:
        print(f"  Tip: Open remaining items in Xcode Organizer to cache them")
    print("=" * 60)


if __name__ == "__main__":
    main()
