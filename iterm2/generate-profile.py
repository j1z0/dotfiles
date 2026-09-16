#!/usr/bin/env python3
"""Generate an iTerm2 dynamic profile from the canonical solarized palette.

iTerm2 3.5+ can hold two colour sets per profile and follow the system between
them ("Use Separate Colors for Light and Dark Mode"), which is the same thing
a terminal with a native light/dark theme pair does. So iTerm2 needs no
scripting to track appearance — it just needs both palettes filled in.

Reads themes/solarized-{dark,light} so there is one source of truth for
the colours; writes iterm2/Solarized.json, which install.sh drops into
~/Library/Application Support/iTerm2/DynamicProfiles/ (read live, no restart).
"""

import json
import pathlib
import re
import sys

DOT = pathlib.Path(__file__).resolve().parent.parent
FONT = "JetBrainsMonoNFM-Regular 14"
GUID = "6D0F3A2C-DOTFILES-SOLARIZED-0001"


def parse_theme(path):
    """Theme file -> {'palette': {n: (r,g,b)}, 'background': (r,g,b), ...}"""
    out = {"palette": {}}
    for raw in path.read_text().splitlines():
        line = raw.strip()
        # Only whole-line comments are stripped: every colour value starts with
        # "#", so splitting on it would eat the value.
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = (p.strip() for p in line.split("=", 1))
        if key == "palette":
            m = re.match(r"^(\d+)\s*=\s*#?([0-9a-fA-F]{6})$", val)
            if m:
                out["palette"][int(m.group(1))] = hex_rgb(m.group(2))
        elif val.startswith("#") and len(val) == 7:
            out[key] = hex_rgb(val[1:])
    return out


def hex_rgb(h):
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def colour(rgb):
    r, g, b = rgb
    return {
        "Red Component": round(r, 6),
        "Green Component": round(g, 6),
        "Blue Component": round(b, 6),
        "Color Space": "sRGB",
    }


def colour_keys(theme, suffix):
    keys = {}
    for n, rgb in sorted(theme["palette"].items()):
        keys[f"Ansi {n} Color{suffix}"] = colour(rgb)
    keys[f"Background Color{suffix}"] = colour(theme["background"])
    keys[f"Foreground Color{suffix}"] = colour(theme["foreground"])
    keys[f"Bold Color{suffix}"] = colour(theme["foreground"])
    keys[f"Cursor Color{suffix}"] = colour(theme["cursor-color"])
    keys[f"Cursor Text Color{suffix}"] = colour(theme["cursor-text"])
    keys[f"Selection Color{suffix}"] = colour(theme["selection-background"])
    keys[f"Selected Text Color{suffix}"] = colour(theme["selection-foreground"])
    keys[f"Link Color{suffix}"] = colour(theme["palette"][4])
    return keys


def main():
    dark = parse_theme(DOT / "themes/solarized-dark")
    light = parse_theme(DOT / "themes/solarized-light")
    for name, t in (("dark", dark), ("light", light)):
        missing = [k for k in ("background", "foreground", "cursor-color") if k not in t]
        if missing or len(t["palette"]) != 16:
            sys.exit(f"{name} theme incomplete: missing {missing}, {len(t['palette'])}/16 palette entries")

    profile = {
        "Name": "Solarized (dotfiles)",
        "Guid": GUID,
        "Normal Font": FONT,
        "Use Separate Colors for Light and Dark Mode": True,
        # Open a terminal, land straight in the 65/35 agent layout.
        "Custom Command": "Yes",
        "Command": str(DOT / "bin/dev-shell"),
        "Unlimited Scrollback": True,
        "Scrollback Lines": 100000,
        "Mouse Reporting": True,
        "Silence Bell": True,
        "Visual Bell": False,
        # Esc+ so Option reaches readline; AeroSpace still takes the chords it binds.
        "Option Key Sends": 2,
        "Right Option Key Sends": 2,
        "Horizontal Spacing": 1,
        "Vertical Spacing": 1.12,
        "Blinking Cursor": False,
        "Cursor Type": 2,
        "Close Sessions On End": True,
        "Draw Powerline Glyphs": True,
    }
    profile.update(colour_keys(light, " (Light)"))
    profile.update(colour_keys(dark, " (Dark)"))

    out = DOT / "iterm2/Solarized.json"
    out.write_text(json.dumps({"Profiles": [profile]}, indent=2) + "\n")
    print(f"wrote {out} ({len(profile)} keys, font {FONT})")


if __name__ == "__main__":
    main()
