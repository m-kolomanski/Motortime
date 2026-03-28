# Motortime

A KDE Plasma desktop widget that displays a colorful, always-visible motorsport calendar — showing all major racing series in a single glanceable view.

## What it does

Motortime sits on your desktop as a floating widget and shows a rolling 4-week calendar (previous week, current week, two weeks ahead). Each motorsport series gets its own color. Events are rendered as multi-day bars spanning the days of the weekend, with country flag emojis and structured labels so you can tell at a glance what's on and where.

Supported series (planned):

- Formula 1
- Formula 2
- Formula 3
- FIA World Endurance Championship (WEC)
- IMSA WeatherTech SportsCar Championship
- Nürburgring Langstrecken-Serie (NLS)
- GT World Challenge (GTWC)
- FIA World Rally Championship (WRC)

More series can be added via the series config file.

## Architecture

```
GitHub Actions (weekly cron)
  └── scraper/ — fetches iCal feeds and scrapes series sites
       └── outputs data/events.json → committed to repo

Widget (Plasma QML Plasmoid)
  └── fetches data/events.json from GitHub raw URL
  └── reads series-config.json (bundled) for colors and labels
  └── renders 4-week calendar grid with colored event bars
```

End users only install the widget — no local scraping or setup required.

## Calendar layout

```
       Mon   Tue   Wed   Thu   Fri   Sat   Sun
-1     23    24    25    26    27    28    29
        [════════════ WEC Imola ════════════]

 0     30    31     1     2     3     4     5   ← current week
                          [🇯🇵 Japan | GP ═══]
                          [🇯🇵 Japan | F2 ══]

+1      6     7     8     9    10    11    12
        [══════════════ NLS ════════════════]

+2     13    14    15    16    17    18    19
                               [🇨🇳 China | GP]
```

- Bars span exactly the event days (Friday–Sunday for a typical F1 weekend)
- Events on overlapping days stack vertically in lanes
- Labels adapt to bar width: full (`🇯🇵 Japan | Grand Prix`), medium (`🇯🇵 Japan`), or flag-only (`🇯🇵`)
- Cross-week events are split across rows with visual continuation indicators

## Event data format

Events are stored in `data/events.json`:

```json
{
  "generated": "2026-03-28T12:00:00Z",
  "events": [
    {
      "id": "f1-2026-r4-japan",
      "series": "F1",
      "location": "Japan",
      "event_type": "Grand Prix",
      "flag": "🇯🇵",
      "start": "2026-04-04",
      "end": "2026-04-06"
    }
  ]
}
```

## Series config format

Series colors and display names are defined in `series-config.json`, bundled with the widget:

```json
{
  "F1":   { "color": "#E8002D", "label": "Formula 1" },
  "F2":   { "color": "#FF6B35", "label": "Formula 2" },
  "F3":   { "color": "#FFD166", "label": "Formula 3" },
  "WEC":  { "color": "#00B4D8", "label": "WEC" },
  "IMSA": { "color": "#06D6A0", "label": "IMSA" },
  "NLS":  { "color": "#A663CC", "label": "NLS" },
  "GTWC": { "color": "#F4A261", "label": "GTWC" },
  "WRC":  { "color": "#EF476F", "label": "WRC" }
}
```

## Planned features

### v0.1 — Proof of concept
- [ ] 4-week rolling calendar grid (Mon–Sun rows)
- [ ] Multi-day event bars with lane stacking
- [ ] Adaptive labels (flag + location + event type)
- [ ] KDE theme-aware background and text colors
- [ ] Load events from local JSON file (mock data)
- [ ] Bundled series color config

### v0.2 — Live data
- [ ] Fetch `events.json` from GitHub raw URL on startup
- [ ] Periodic refresh (configurable interval)
- [ ] Graceful offline fallback to cached data
- [ ] Loading and error states in the widget UI

### v0.3 — Scraper (cloud-side)
- [ ] GitHub Actions workflow running on weekly cron
- [ ] iCal feed parsers for: F1, F2, F3, WEC, IMSA, WRC, GTWC
- [ ] HTML scrapers for series without iCal feeds (NLS, etc.)
- [ ] Deduplication and normalization pipeline
- [ ] Auto-commit `data/events.json` to repo

### v0.4 — Widget polish
- [ ] Right-click config panel: toggle series on/off
- [ ] Click event bar → show detail tooltip (circuit, session times)
- [ ] "Today" highlight and week boundary styling
- [ ] Smooth transitions when data refreshes

### Future ideas
- Optional sync with KDE calendar app (`.ics` export)
- Countdown timer to next event
- Notification support ("Race starts in 1 hour")
- Support for user-defined custom series/events
- Light theme variant

## Installation

> Installation instructions will be added once v0.1 is ready.

## Contributing

> Contribution guide will be added before the first public release.

## License

TBD
