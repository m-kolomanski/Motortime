"""F3 calendar scraper — parses the toomuchracing.com Google Calendar iCal feed.

Feed URL: https://calendar.google.com/calendar/ical/sorhedtr7q5qmea6f0hvf20864%40group.calendar.google.com/public/basic.ics
Summary format: 'F3 | Silverstone | Race 1'
                'F3 | Silverstone | Race 2'
                '*Cancelled* F3 | Sakhir | Race 1'
"""

from __future__ import annotations

from collections import defaultdict
from datetime import timedelta

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

ICAL_URL = (
    "https://calendar.google.com/calendar/ical/"
    "sorhedtr7q5qmea6f0hvf20864%40group.calendar.google.com/public/basic.ics"
)


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the F3 iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    cal = fetch_calendar(ICAL_URL)

    weekends: dict[str, dict] = defaultdict(lambda: {"starts": [], "ends": []})

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        if summary.startswith("*Cancelled*"):
            continue
        if not summary.startswith("F3 | "):
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
            "series":     "F3",
            "location":   location,
            "event_type": "Sprint & Feature",
            "flag":       flag,
            "start":      start.isoformat(),
            "end":        max(data["ends"]).isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
