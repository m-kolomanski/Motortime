"""Formula E calendar scraper — parses the toomuchracing.com Google Calendar iCal feed.

Feed URL: https://calendar.google.com/calendar/ical/vno0ntshopq0nmob26db2pcen8%40group.calendar.google.com/public/basic.ics
Summary format: 'Formula E | Mexico City ePrix'            (single race)
                'Formula E | Berlin ePrix | Race 1'        (double-header)
                'Formula E | Berlin ePrix | Race 2'
"""

from __future__ import annotations

from collections import defaultdict

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

ICAL_URL = (
    "https://calendar.google.com/calendar/ical/"
    "vno0ntshopq0nmob26db2pcen8%40group.calendar.google.com/public/basic.ics"
)


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the Formula E iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    cal = fetch_calendar(ICAL_URL)

    weekends: dict[str, dict] = defaultdict(lambda: {"starts": [], "ends": [], "count": 0})

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        if not summary.startswith("Formula E | "):
            continue

        parts = summary.split(" | ")
        if len(parts) < 2:
            continue
        location_raw = parts[1].removesuffix(" ePrix").strip()

        dt_start, dt_end = event_dates(component)
        if dt_start.year != year:
            continue

        weekends[location_raw]["starts"].append(dt_start)
        weekends[location_raw]["ends"].append(dt_end)
        weekends[location_raw]["count"] += 1

    events = []
    for location_raw, data in weekends.items():
        location, flag = resolve(location_raw)
        is_double = data["count"] > 1
        events.append({
            "series":     "FE",
            "location":   location,
            "event_type": "Double ePrix" if is_double else "ePrix",
            "flag":       flag,
            "start":      min(data["starts"]).isoformat(),
            "end":        max(data["ends"]).isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
