"""IMSA WeatherTech Championship scraper — parses the toomuchracing.com Google Calendar iCal feed.

Feed URL: https://calendar.google.com/calendar/ical/njulhksvo83qeoruc3nhend9js%40group.calendar.google.com/public/basic.ics
Summary format: 'IMSA WeatherTech Championship | Rolex 24 At Daytona | 24H | All Classes'
                'IMSA WeatherTech Championship | Chevrolet Grand Prix | 2H40M | LMP2, GTD Pro, GTD | Mosport'

Parts: [series | event_name | duration | classes] or [...| location] when location
       is not embedded in the event name.
"""

from __future__ import annotations

import re
from datetime import timedelta

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

ICAL_URL = (
    "https://calendar.google.com/calendar/ical/"
    "njulhksvo83qeoruc3nhend9js%40group.calendar.google.com/public/basic.ics"
)

# Searched in order; first match wins. Maps a keyword in parts[1] to a
# resolved location name passed to flags.resolve().
_NAME_TO_LOCATION: list[tuple[str, str]] = [
    ("Petit Le Mans", "Road Atlanta"),
    ("Long Beach",    "Long Beach"),
    ("Laguna Seca",   "Laguna Seca"),
    ("The Glen",      "Watkins Glen"),
    ("Daytona",       "Daytona"),
    ("Sebring",       "Sebring"),
    ("Detroit",       "Detroit"),
    ("VIR",           "VIR"),
]

_DURATION_RE = re.compile(r"(\d+)H(?:(\d+)M)?")


def _parse_event_type(code: str) -> str:
    m = _DURATION_RE.match(code)
    if not m:
        return code
    hours, minutes = int(m.group(1)), int(m.group(2) or 0)
    if minutes == 0:
        return f"{hours} Hours"
    return f"{hours}h {minutes}min"


def _location_key(parts: list[str]) -> str | None:
    """Return the location key to pass to resolve(), or None to skip."""
    if len(parts) < 2:
        return None
    name = parts[1].strip()
    if name.startswith("[TEST]") or name.startswith("[test]"):
        return None
    # Explicit location in 5th field
    if len(parts) >= 5:
        return parts[4].strip()
    # Location keyword embedded in event name
    for keyword, resolved in _NAME_TO_LOCATION:
        if keyword in name:
            return resolved
    # Event name is the circuit name directly (e.g. "Laguna Seca")
    return name


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the IMSA iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    cal = fetch_calendar(ICAL_URL)
    events = []

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        if not summary.startswith("IMSA WeatherTech Championship"):
            continue

        parts = summary.split(" | ")
        loc_key = _location_key(parts)
        if loc_key is None:
            continue

        dt_start, dt_end = event_dates(component)
        if dt_start.year != year:
            continue
        dt_start -= timedelta(days=(dt_start.weekday() - 3) % 7)  # back to Thursday

        duration_code = parts[2].strip() if len(parts) >= 3 else ""
        location, flag = resolve(loc_key)

        events.append({
            "series":     "IMSA",
            "location":   location,
            "event_type": _parse_event_type(duration_code),
            "flag":       flag,
            "start":      dt_start.isoformat(),
            "end":        dt_end.isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
