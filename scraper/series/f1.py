"""F1 calendar scraper — parses the better-f1-calendar iCal feed.

Feed URL: https://better-f1-calendar.vercel.app/api/calendar.ics
Summary format: 'F1 Australian GP - Race'
                'F1 Chinese GP - Sprint Race'
"""

from __future__ import annotations

from collections import defaultdict
from datetime import date, timedelta, timezone

import httpx
from icalendar import Calendar

from utils.flags import resolve

ICAL_URL = "https://better-f1-calendar.vercel.app/api/calendar.ics"

_WEEKEND_SESSIONS = {
    "practice 1", "practice 2", "practice 3",
    "qualifying",
    "sprint qualification", "sprint race",
    "race",
}

_SPRINT_SESSIONS = {"sprint race", "sprint qualification"}

_SKIP_KEYWORDS = {"testing", "pre-season"}


def _parse_summary(summary: str) -> tuple[str, str] | None:
    """Parse 'F1 Australian GP - Race' → ('Australian GP', 'race')."""
    if not summary.startswith("F1 ") or " - " not in summary:
        return None
    _, rest = summary.split(" ", 1)
    gp_name, session = rest.rsplit(" - ", 1)
    return gp_name.strip(), session.strip().lower()


def _to_date(dt_value) -> date:
    if hasattr(dt_value, "date"):
        return dt_value.astimezone(timezone.utc).date()
    return dt_value


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse the F1 iCal feed for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    response = httpx.get(ICAL_URL, follow_redirects=True, timeout=30)
    response.raise_for_status()

    cal = Calendar.from_ical(response.content)

    weekends: dict[str, dict] = defaultdict(lambda: {
        "starts": [], "ends": [], "sessions": [],
    })

    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        summary = str(component.get("SUMMARY", ""))
        parsed = _parse_summary(summary)
        if parsed is None:
            continue

        gp_name, session = parsed
        if session not in _WEEKEND_SESSIONS:
            continue

        dt_start = _to_date(component.get("DTSTART").dt)
        dt_end   = _to_date(component.get("DTEND").dt)
        if not hasattr(component.get("DTEND").dt, "hour"):
            dt_end = dt_end - timedelta(days=1)

        if dt_start.year != year:
            continue

        weekends[gp_name]["starts"].append(dt_start)
        weekends[gp_name]["ends"].append(dt_end)
        weekends[gp_name]["sessions"].append(session)

    events = []
    for gp_name, data in weekends.items():
        if not data["starts"]:
            continue

        resolved = resolve(gp_name, skip_keywords=_SKIP_KEYWORDS)
        if resolved is None:
            continue

        location, location_flag = resolved
        is_sprint = bool(_SPRINT_SESSIONS & set(data["sessions"]))

        events.append({
            "series":     "F1",
            "location":   location,
            "event_type": "Sprint Weekend" if is_sprint else "Grand Prix",
            "flag":       location_flag,
            "start":      min(data["starts"]).isoformat(),
            "end":        max(data["ends"]).isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
