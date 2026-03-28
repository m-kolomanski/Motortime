"""
Location/country → (display name, flag emoji) resolution.

Handles direct country names, adjective forms (e.g. "Australian"),
circuit/city names, and feed-specific quirks (e.g. "Premio Italia").

Public API:
    resolve(name, skip_keywords) → (location, flag) | None
    flag(country)                → emoji str
"""

from __future__ import annotations

# ── Canonical country name → flag ────────────────────────────────────────────

_COUNTRY_FLAGS: dict[str, str] = {
    "Australia":            "🇦🇺",
    "Austria":              "🇦🇹",
    "Azerbaijan":           "🇦🇿",
    "Bahrain":              "🇧🇭",
    "Belgium":              "🇧🇪",
    "Brazil":               "🇧🇷",
    "Canada":               "🇨🇦",
    "China":                "🇨🇳",
    "Croatia":              "🇭🇷",
    "Estonia":              "🇪🇪",
    "Finland":              "🇫🇮",
    "France":               "🇫🇷",
    "Germany":              "🇩🇪",
    "Great Britain":        "🇬🇧",
    "Hungary":              "🇭🇺",
    "Italy":                "🇮🇹",
    "Japan":                "🇯🇵",
    "Kenya":                "🇰🇪",
    "Mexico":               "🇲🇽",
    "Monaco":               "🇲🇨",
    "Netherlands":          "🇳🇱",
    "New Zealand":          "🇳🇿",
    "Poland":               "🇵🇱",
    "Portugal":             "🇵🇹",
    "Qatar":                "🇶🇦",
    "Saudi Arabia":         "🇸🇦",
    "Singapore":            "🇸🇬",
    "Spain":                "🇪🇸",
    "Sweden":               "🇸🇪",
    "United Arab Emirates": "🇦🇪",
    "United States":        "🇺🇸",
    "Uruguay":              "🇺🇾",
}

# ── Alias/adjective/quirk → (display location, flag) ─────────────────────────
# Keys are matched exactly first, then as prefixes, against the input
# with any trailing " GP" / " Grand Prix" stripped.

_ALIASES: dict[str, tuple[str, str]] = {
    # Adjective forms
    "Australian":    ("Melbourne",   "🇦🇺"),
    "Austrian":      ("Spielberg",   "🇦🇹"),
    "Belgian":       ("Spa",         "🇧🇪"),
    "British":       ("Silverstone", "🇬🇧"),
    "Canadian":      ("Montreal",    "🇨🇦"),
    "Chinese":       ("Shanghai",    "🇨🇳"),
    "Dutch":         ("Zandvoort",   "🇳🇱"),
    "Hungarian":     ("Budapest",    "🇭🇺"),
    "Italian":       ("Monza",       "🇮🇹"),
    "Japanese":      ("Suzuka",      "🇯🇵"),
    "Mexican":       ("Mexico City", "🇲🇽"),
    "Portuguese":    ("Portimão",    "🇵🇹"),
    "Saudi Arabian": ("Jeddah",      "🇸🇦"),
    "Spanish":       ("Barcelona",   "🇪🇸"),
    # City/circuit names that need a flag but aren't country names
    "Abu Dhabi":     ("Abu Dhabi",   "🇦🇪"),
    "Baku":          ("Baku",        "🇦🇿"),
    "Barcelona":     ("Barcelona",   "🇪🇸"),
    "Las Vegas":     ("Las Vegas",   "🇺🇸"),
    "Mexico City":   ("Mexico City", "🇲🇽"),
    "Miami":         ("Miami",       "🇺🇸"),
    "Monaco":        ("Monaco",      "🇲🇨"),
    "Monte Carlo":   ("Monte Carlo", "🇲🇨"),
    "Nürburgring":   ("Nürburgring", "🇩🇪"),
    "Portimão":      ("Portimão",    "🇵🇹"),
    "Sao Paulo":     ("São Paulo",   "🇧🇷"),
    "São Paulo":     ("São Paulo",   "🇧🇷"),
    "Singapore":     ("Singapore",   "🇸🇬"),
    # Feed-specific quirks
    "Premio Italia": ("Monza",       "🇮🇹"),
    "United States": ("Austin",      "🇺🇸"),
}

# Trailing suffixes to strip before lookup
_STRIP_SUFFIXES = (" Grand Prix", " GP")


def _strip(name: str) -> str:
    for suffix in _STRIP_SUFFIXES:
        if name.endswith(suffix):
            return name[: -len(suffix)].strip()
    return name.strip()


def resolve(name: str, skip_keywords: set[str] | None = None) -> tuple[str, str] | None:
    """
    Resolve *name* to a (display_location, flag_emoji) pair.

    Returns None if *name* matches any word in *skip_keywords*.
    Falls back to 🏁 if no mapping is found.
    """
    lower = name.lower()
    if skip_keywords and any(kw in lower for kw in skip_keywords):
        return None

    key = _strip(name)

    # Exact alias match
    if key in _ALIASES:
        return _ALIASES[key]

    # Exact country name match
    if key in _COUNTRY_FLAGS:
        return key, _COUNTRY_FLAGS[key]

    # Prefix alias match (handles e.g. "Barcelona Catalunya")
    for alias_key, value in _ALIASES.items():
        if key.startswith(alias_key):
            return value

    # Fallback
    return key, "🏁"


def flag(country: str) -> str:
    """Return flag emoji for a plain country name, or 🏁 if unknown."""
    return _COUNTRY_FLAGS.get(country, "🏁")
