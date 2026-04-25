"""GT World Challenge scraper — parses four toomuchracing.com iCal feeds.

2026 summary formats:
  Europe:    'GTWC Europe | Sprint | Misano | Race 1 | 1H'
             'GTWC Europe | Endurance | Paul Ricard | 6H'
             'GTWC Europe & IGTC | Endurance | Crowdstrike 24 Hours of Spa'
  America:   'GTWC America | Sebring | 3H'
             'GTWC America & IGTC | Indianapolis 8 Hour'
  Asia:      'GTWC Asia | Sepang | Race 1'
  Australia: 'GTWC Australia | Phillip Island | Race 1'
"""

from __future__ import annotations

import re
from collections import defaultdict
from datetime import timedelta

from utils.flags import resolve
from utils.ical import event_dates, fetch_calendar

_FEEDS: dict[str, str] = {
    "GTWC Europe": (
        "https://calendar.google.com/calendar/ical/"
        "drne83rrmn7m9baje25qh2248s%40group.calendar.google.com/public/basic.ics"
    ),
    "GTWC America": (
        "https://calendar.google.com/calendar/ical/"
        "1g47v5qu33g114060qa1ula9d0%40group.calendar.google.com/public/basic.ics"
    ),
    "GTWC Asia": (
        "https://calendar.google.com/calendar/ical/"
        "plm3evhsd30l34r2tj68fh9mss%40group.calendar.google.com/public/basic.ics"
    ),
    "GTWC Australia": (
        "https://calendar.google.com/calendar/ical/"
        "31e7b509e16383e2c02a557c478ba3fe7cac843154c97ca5fbc77d69a578c253"
        "%40group.calendar.google.com/public/basic.ics"
    ),
}

_DURATION_RE = re.compile(r"(\d+)\s*[Hh]")
_HOURS_OF_RE = re.compile(r"\d+\s*[Hh]ours?\s+of\s+(.+)$", re.IGNORECASE)
_VENUE_BEFORE_HOURS_RE = re.compile(r"^(.+?)\s+\d+\s+[Hh]our", re.IGNORECASE)


def _parse_duration(code: str) -> str:
    m = _DURATION_RE.search(code)
    return f"{int(m.group(1))} Hours" if m else code


def _europe_venue_event(parts: list[str]) -> tuple[str, str] | None:
    if len(parts) < 3:
        return None
    cup  = parts[1].strip()
    name = parts[2].strip()
    # "Crowdstrike 24 Hours of Spa" → venue="Spa", type="24 Hours"
    m = _HOURS_OF_RE.search(name)
    if m:
        return m.group(1).strip(), _parse_duration(name)
    duration_code = parts[-1].strip()
    event_type = _parse_duration(duration_code) if cup == "Endurance" else "Sprint"
    return name, event_type


def _america_venue_event(parts: list[str]) -> tuple[str, str] | None:
    if len(parts) < 2:
        return None
    name = parts[1].strip()
    # "Indianapolis 8 Hour" (no pipe-separated duration)
    m = _VENUE_BEFORE_HOURS_RE.match(name)
    if m:
        return m.group(1).strip(), _parse_duration(name)
    duration_code = parts[2].strip() if len(parts) >= 3 else ""
    return name, _parse_duration(duration_code) if duration_code else "Race"


def fetch(year: int) -> list[dict]:
    """
    Fetch and parse all four GTWC iCal feeds for *year*.
    Returns a list of event dicts compatible with events.js.
    """
    weekends: dict[tuple, list[dict]] = defaultdict(list)

    for series, url in _FEEDS.items():
        region = series.split()[-1]  # "Europe" / "America" / "Asia" / "Australia"
        cal = fetch_calendar(url)

        for component in cal.walk():
            if component.name != "VEVENT":
                continue

            summary = str(component.get("SUMMARY", ""))
            if not (summary.startswith(series + " |") or summary.startswith(series + " &")):
                continue

            parts = summary.split(" | ")

            if region == "Europe":
                parsed = _europe_venue_event(parts)
            elif region == "America":
                parsed = _america_venue_event(parts)
            else:
                if len(parts) < 2:
                    continue
                parsed = (parts[1].strip(), "Race Weekend")

            if parsed is None:
                continue
            venue_key, event_type = parsed

            dt_start, dt_end = event_dates(component)
            if dt_start.year != year:
                continue
            dt_start -= timedelta(days=(dt_start.weekday() - 3) % 7)  # back to Thursday

            weekends[(series, venue_key)].append({
                "start":      dt_start,
                "end":        dt_end,
                "event_type": event_type,
            })

    events = []
    for (series, venue_key), sessions in weekends.items():
        location, flag = resolve(venue_key)
        events.append({
            "series":     series,
            "location":   location,
            "event_type": sessions[0]["event_type"],
            "flag":       flag,
            "start":      min(s["start"] for s in sessions).isoformat(),
            "end":        max(s["end"] for s in sessions).isoformat(),
        })

    events.sort(key=lambda e: e["start"])
    return events
