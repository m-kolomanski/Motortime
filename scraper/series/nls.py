"""NLS (ADAC Nürburgring Langstrecken-Serie) scraper — parses the toomuchracing.com iCal feed.

Feed URL: https://calendar.google.com/calendar/ical/f7ubn1ltpc4p7amil7kefgj754%40group.calendar.google.com/public/basic.ics
Summary format: 'NLS | NLS1'
                'NLS | NLS4 | ADAC 24h Nürburgring Qualifiers'

Some weekends have two consecutive races (e.g. NLS4+NLS5 Sat+Sun), so events are
grouped by the Thursday of their ISO week to produce a single weekend entry.
"""

from __future__ import annotations

from collections import defaultdict
from datetime import timedelta

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

ICAL_URL = (
    "https://calendar.google.com/calendar/ical/"
    "f7ubn1ltpc4p7amil7kefgj754%40group.calendar.google.com/public/basic.ics"
)

_LOCATION, _FLAG = resolve("Nürburgring")


def _thursday(d) -> object:
    return d - timedelta(days=(d.weekday() - 3) % 7)


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the NLS iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    cal = fetch_calendar(ICAL_URL)
    weekends: dict = defaultdict(lambda: {"ends": [], "rounds": []})

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        if not summary.startswith("NLS | "):
            continue

        parts = summary.split(" | ")

        dt_start, dt_end = event_dates(component)
        if dt_start.year != year:
            continue

        round_label = parts[1].strip() if len(parts) >= 2 else ""

        thu = _thursday(dt_start)
        weekends[thu]["ends"].append(dt_end)
        weekends[thu]["rounds"].append(round_label)

    events = [
        {
            "series":     "NLS",
            "location":   _LOCATION,
            "event_type": " & ".join(sorted(set(data["rounds"]))),
            "flag":       _FLAG,
            "start":      thu.isoformat(),
            "end":        max(data["ends"]).isoformat(),
        }
        for thu, data in weekends.items()
    ]

    events.sort(key=lambda e: e["start"])
    return events
