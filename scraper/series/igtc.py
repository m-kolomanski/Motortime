"""IGTC (Intercontinental GT Challenge) scraper — parses the toomuchracing.com iCal feed.

Feed URL: https://calendar.google.com/calendar/ical/kcelko7ictk6okcf4peougahlo%40group.calendar.google.com/public/basic.ics
Summary format: 'IGTC | Crowdstrike 24 Hours of Spa'
                'IGTC | ADAC Ravenol 24H Nürburgring'
                'IGTC | Meguiar's Bathurst 12 Hour'
                'IGTC | Indianapolis 8 Hour'
                'IGTC | Suzuka 1000km'
"""

from __future__ import annotations

import re
from datetime import timedelta

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

ICAL_URL = (
    "https://calendar.google.com/calendar/ical/"
    "kcelko7ictk6okcf4peougahlo%40group.calendar.google.com/public/basic.ics"
)

_KNOWN_VENUES = ["Bathurst", "Spa", "Nürburgring", "Suzuka", "Indianapolis"]
_DURATION_RE = re.compile(r"(\d+)\s*[Hh](?:ours?)?")
_KM_RE = re.compile(r"(\d+)\s*km", re.IGNORECASE)


def _parse_name(name: str) -> tuple[str, str]:
    venue = next((v for v in _KNOWN_VENUES if v in name), name)
    m = _KM_RE.search(name)
    if m:
        return venue, f"{m.group(1)}km"
    m = _DURATION_RE.search(name)
    if m:
        return venue, f"{int(m.group(1))} Hours"
    return venue, "Race"


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the IGTC iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    cal = fetch_calendar(ICAL_URL)
    events = []

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        if not summary.startswith("IGTC | "):
            continue

        parts = summary.split(" | ", 1)
        if len(parts) < 2:
            continue

        dt_start, dt_end = event_dates(component)
        if dt_start.year != year:
            continue
        dt_start -= timedelta(days=(dt_start.weekday() - 3) % 7)  # back to Thursday

        venue_key, event_type = _parse_name(parts[1].strip())
        location, flag = resolve(venue_key)

        events.append({
            "series":     "IGTC",
            "location":   location,
            "event_type": event_type,
            "flag":       flag,
            "start":      dt_start.isoformat(),
            "end":        dt_end.isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
