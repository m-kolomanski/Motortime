"""Shared iCal utilities for Motortime scrapers."""

from __future__ import annotations

from datetime import date, timedelta, timezone

import httpx
from icalendar import Calendar


def fetch_calendar(url: str) -> Calendar:
    """Fetch and parse an iCal feed, raising on HTTP errors."""
    response = httpx.get(url, follow_redirects=True, timeout=30)
    response.raise_for_status()
    return Calendar.from_ical(response.content)


def event_dates(component) -> tuple[date, date]:
    """Return (start, end) dates for a VEVENT component.

    Converts datetimes to UTC dates and corrects the iCal all-day DTEND
    exclusive convention by subtracting one day for date-only events.
    """
    dt_start_raw = component.get("DTSTART").dt
    dt_end_raw = component.get("DTEND").dt

    start = _to_date(dt_start_raw)
    end = _to_date(dt_end_raw)

    if not hasattr(dt_end_raw, "hour"):
        end = end - timedelta(days=1)

    return start, end


def _to_date(dt_value) -> date:
    if hasattr(dt_value, "date"):
        return dt_value.astimezone(timezone.utc).date()
    return dt_value
