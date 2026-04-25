"""
Motortime scraper — fetches motorsport calendars and writes events.js.

Usage:
    uv run main.py [--year YEAR] [--out PATH] [--series F1 ...]
"""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path

from series import f1, f2, f3, fe, gtwc, imsa, wec, wrc

SERIES_SCRAPERS = {
    "F1":   f1.fetch,
    "F2":   f2.fetch,
    "F3":   f3.fetch,
    "FE":   fe.fetch,
    "GTWC": gtwc.fetch,
    "IMSA": imsa.fetch,
    "WEC":  wec.fetch,
    "WRC":  wrc.fetch,
    # NLS — to be added
}

DEFAULT_OUT = Path(__file__).parent.parent / "widget" / "contents" / "data" / "events.js"


def build_js(events: list[dict], generated: str) -> str:
    lines = [".pragma library", "", f"// Generated: {generated}", "", "var events = ["]
    for ev in events:
        lines.append(
            f'    {{ series: {json.dumps(ev["series"])}, '
            f'location: {json.dumps(ev["location"])}, '
            f'event_type: {json.dumps(ev["event_type"])}, '
            f'flag: {json.dumps(ev["flag"])}, '
            f'start: {json.dumps(ev["start"])}, '
            f'end: {json.dumps(ev["end"])} }},'
        )
    lines.append("]")
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Motortime calendar scraper")
    parser.add_argument("--year", type=int, default=datetime.now().year,
                        help="Season year (default: current year)")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT,
                        help="Output path for events.js")
    parser.add_argument("--series", nargs="+", choices=list(SERIES_SCRAPERS),
                        default=list(SERIES_SCRAPERS),
                        help="Which series to scrape (default: all)")
    args = parser.parse_args()

    all_events: list[dict] = []

    for key in args.series:
        print(f"Scraping {key}...")
        try:
            events = SERIES_SCRAPERS[key](args.year)
            print(f"  → {len(events)} events")
            all_events.extend(events)
        except Exception as e:
            print(f"  ✗ failed: {e}")

    all_events.sort(key=lambda e: e["start"])

    generated = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    js = build_js(all_events, generated)

    args.out.write_text(js, encoding="utf-8")
    print(f"\nWrote {len(all_events)} events → {args.out}")


if __name__ == "__main__":
    main()
