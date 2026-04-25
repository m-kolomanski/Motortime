"""WRC calendar scraper — parses the toomuchracing.com Google Calendar iCal feed.

Feed URL: https://calendar.google.com/calendar/ical/fei68gpe16c85ed3jjdtvrn8ns%40group.calendar.google.com/public/basic.ics
Summary format: 'WRC | Rally Sweden'
                'WRC | Vodafone Rally de Portugal'
                'WRC | EKO Acropolis Rally Greece'
"""

from __future__ import annotations

import re

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

ICAL_URL = (
    "https://calendar.google.com/calendar/ical/"
    "fei68gpe16c85ed3jjdtvrn8ns%40group.calendar.google.com/public/basic.ics"
)

# Sponsor names that may prefix the rally name
_SPONSORS_RE = re.compile(
    r"^(?:Vodafone|EKO|Secto|Bapco|TotalEnergies|Rolex|ORLEN)\s+",
    re.IGNORECASE,
)

# Qualifier words that precede "Rally" and are not part of the location
_QUALIFIER_RE = re.compile(r"\b(?:Safari|Acropolis)\s+", re.IGNORECASE)


def _location_key(rally_name: str) -> str:
    """Extract the core location keyword from a WRC rally name.

    Examples:
        'Vodafone Rally de Portugal' → 'Portugal'
        'EKO Acropolis Rally Greece' → 'Greece'
        'Rallye Monte-Carlo'         → 'Monte-Carlo'
        'Rally Italia Sardegna'      → 'Italia Sardegna'  (prefix-matched to Italy)
        'Croatia Rally'              → 'Croatia'
    """
    name = _SPONSORS_RE.sub("", rally_name).strip()
    name = _QUALIFIER_RE.sub("", name).strip()

    # "Rally/Rallye [de/del/des] Location"
    m = re.match(r"Rall[ye]+\s+(?:de[ls]?\s+)?(.+)", name, re.IGNORECASE)
    if m:
        return m.group(1).strip()

    # "Location Rally" (e.g. "Croatia Rally")
    m = re.match(r"(.+?)\s+Rally", name, re.IGNORECASE)
    if m:
        return m.group(1).strip()

    return name


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the WRC iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    cal = fetch_calendar(ICAL_URL)
    events = []

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        if not summary.startswith("WRC | "):
            continue

        name = summary.split(" | ", 1)[1].strip()

        dt_start, dt_end = event_dates(component)

        if dt_start.year != year:
            continue

        key = _location_key(name)
        location, flag = resolve(key)

        events.append({
            "series":     "WRC",
            "location":   location,
            "event_type": "Rally",
            "flag":       flag,
            "start":      dt_start.isoformat(),
            "end":        dt_end.isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
