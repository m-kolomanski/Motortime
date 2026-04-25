"""F2 calendar scraper — parses the toomuchracing.com Google Calendar iCal feed.

Feed URL: https://calendar.google.com/calendar/ical/rttoqh7u6m247f2ub6c05m4pe4%40group.calendar.google.com/public/basic.ics
Summary format: 'F2 | Montreal | Sprint'
                'F2 | Montreal | Feature'
"""

from __future__ import annotations

from collections import defaultdict
from datetime import timedelta

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

ICAL_URL = (
    "https://calendar.google.com/calendar/ical/"
    "rttoqh7u6m247f2ub6c05m4pe4%40group.calendar.google.com/public/basic.ics"
)


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the F2 iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    cal = fetch_calendar(ICAL_URL)

    weekends: dict[str, dict] = defaultdict(lambda: {"starts": [], "ends": []})

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        summary = summary.removeprefix("*Cancelled* ")
        if not summary.startswith("F2 | "):
            continue

        parts = summary.split(" | ")
        if len(parts) < 2:
            continue
        location_raw = parts[1].strip()

        dt_start, dt_end = event_dates(component)
        if dt_start.year != year:
            continue

        weekends[location_raw]["starts"].append(dt_start)
        weekends[location_raw]["ends"].append(dt_end)

    events = []
    for location_raw, data in weekends.items():
        location, flag = resolve(location_raw)
        start = min(data["starts"])
        start -= timedelta(days=(start.weekday() - 4) % 7)  # back to Friday
        events.append({
            "series":     "F2",
            "location":   location,
            "event_type": "Sprint & Feature",
            "flag":       flag,
            "start":      start.isoformat(),
            "end":        max(data["ends"]).isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
