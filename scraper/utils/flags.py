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

_F = _COUNTRY_FLAGS  # brevity alias for the dict literal below

_ALIASES: dict[str, tuple[str, str]] = {
    # Adjective forms (used by F1 feed)
    "Australian":    ("Melbourne",   _F["Australia"]),
    "Austrian":      ("Spielberg",   _F["Austria"]),
    "Belgian":       ("Spa",         _F["Belgium"]),
    "British":       ("Silverstone", _F["Great Britain"]),
    "Canadian":      ("Montreal",    _F["Canada"]),
    "Chinese":       ("Shanghai",    _F["China"]),
    "Dutch":         ("Zandvoort",   _F["Netherlands"]),
    "Hungarian":     ("Budapest",    _F["Hungary"]),
    "Italian":       ("Monza",       _F["Italy"]),
    "Japanese":      ("Suzuka",      _F["Japan"]),
    "Mexican":       ("Mexico City", _F["Mexico"]),
    "Portuguese":    ("Portimão",    _F["Portugal"]),
    "Saudi Arabian": ("Jeddah",      _F["Saudi Arabia"]),
    "Spanish":       ("Barcelona",   _F["Spain"]),
    # Short city/venue names
    "Abu Dhabi":     ("Abu Dhabi",   _F["United Arab Emirates"]),
    "Baku":          ("Baku",        _F["Azerbaijan"]),
    "Barcelona":     ("Barcelona",   _F["Spain"]),
    "Las Vegas":     ("Las Vegas",   _F["United States"]),
    "Mexico City":   ("Mexico City", _F["Mexico"]),
    "Miami":         ("Miami",       _F["United States"]),
    "Monaco":        ("Monaco",      _F["Monaco"]),
    "Monte Carlo":   ("Monte Carlo", _F["Monaco"]),
    "Nürburgring":   ("Nürburgring", _F["Germany"]),
    "Portimão":      ("Portimão",    _F["Portugal"]),
    "Sao Paulo":     ("São Paulo",   _F["Brazil"]),
    "São Paulo":     ("São Paulo",   _F["Brazil"]),
    "Singapore":     ("Singapore",   _F["Singapore"]),
    # Full official circuit names (used by WEC and other feeds with LOCATION fields)
    "Autodromo do Algarve":           ("Portimão",    _F["Portugal"]),
    "Autodromo Enzo e Dino Ferrari":  ("Imola",       _F["Italy"]),
    "Autodromo Hermanos Rodriguez":   ("Mexico City", _F["Mexico"]),
    "Autodromo Nazionale Monza":      ("Monza",       _F["Italy"]),
    "Autódromo José Carlos Pace":     ("São Paulo",   _F["Brazil"]),
    "Bahrain International Circuit":  ("Bahrain",     _F["Bahrain"]),
    "Circuit de la Sarthe":           ("Le Mans",     _F["France"]),
    "Circuit de Spa-Francorchamps":   ("Spa",         _F["Belgium"]),
    "Circuit of the Americas":        ("Austin",      _F["United States"]),
    "Fuji International Speedway":    ("Fuji",        _F["Japan"]),
    "Lusail International Circuit":   ("Lusail",      _F["Qatar"]),
    "Sebring International Raceway":  ("Sebring",     _F["United States"]),
    "Shanghai International Circuit": ("Shanghai",    _F["China"]),
    "Silverstone Circuit":            ("Silverstone", _F["Great Britain"]),
    # Feed-specific quirks
    "Premio Italia": ("Monza",  _F["Italy"]),
    "United States": ("Austin", _F["United States"]),
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
