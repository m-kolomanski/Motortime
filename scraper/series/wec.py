"""WEC calendar scraper — parses the toomuchracing.com Google Calendar iCal feed.

Feed URL: https://calendar.google.com/calendar/ical/61jccgg4rshh1temqk0dj4lens%40group.calendar.google.com/public/basic.ics
Summary format (2026+): 'FIA WEC | 6 Hours of Spa-Francorchamps'
                        'FIA WEC | TotalEnergies 6 Hours of Spa-Francorchamps'
                        'FIA WEC | 24 Hours of Le Mans'
"""

from __future__ import annotations

import re
from datetime import date, timedelta

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

ICAL_URL = (
    "https://calendar.google.com/calendar/ical/"
    "61jccgg4rshh1temqk0dj4lens%40group.calendar.google.com/public/basic.ics"
)

_SKIP_KEYWORDS = {"test", "prologue", "shakedown"}

_HOURS_RE = re.compile(r"\b(\d+)\s+Hours?\b", re.IGNORECASE)
_KM_RE = re.compile(r"\b(\d[\d,]+)\s*KM\b", re.IGNORECASE)


def _parse_event_type(name: str) -> str:
    m = _HOURS_RE.search(name)
    if m:
        return f"{m.group(1)} Hours"
    m = _KM_RE.search(name)
    if m:
        return f"{m.group(1).replace(',', '')} KM"
    return "Race"


def _thursday_of_week(d: date) -> date:
    """Return the Thursday on or before *d* (WEC weekends start Thursday)."""
    return d - timedelta(days=(d.weekday() - 3) % 7)


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the WEC iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    cal = fetch_calendar(ICAL_URL)
    events = []

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        if not (summary.startswith("FIA WEC") or summary.startswith("WEC ")):
            continue

        # Extract the race name after the separator ("| " or "- " prefix)
        if " | " in summary:
            name = summary.split(" | ", 1)[1].strip()
        elif " - " in summary:
            name = summary.split(" - ", 1)[1].strip()
            # Strip round notation e.g. "-R5- 6 Hours of..."
            name = re.sub(r"^-R\d+-\s*", "", name)
        else:
            continue

        if any(kw in name.lower() for kw in _SKIP_KEYWORDS):
            continue

        dt_start, dt_end = event_dates(component)

        if dt_start.year != year:
            continue

        # Feed only records the race day; expand start to Thursday of that week
        # to cover free practice and qualifying sessions
        dt_start = _thursday_of_week(dt_start)

        location_raw = str(component.get("LOCATION", ""))
        circuit = location_raw.split(",")[0].strip()
        location, flag = resolve(circuit)

        event_type = _parse_event_type(name)

        events.append({
            "series":     "WEC",
            "location":   location,
            "event_type": event_type,
            "flag":       flag,
            "start":      dt_start.isoformat(),
            "end":        dt_end.isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
