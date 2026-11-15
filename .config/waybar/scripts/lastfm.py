#!/usr/bin/env python3
import os
import sys
import json
import urllib.request
import urllib.error
import urllib.parse

# Configuration file location
CONFIG_PATH = os.path.expanduser('~/.config/waybar/lastfm.json')

def load_config():
    default_config = {
        "username": "",
        "api_key": "",
        "show_last_scrobbled": False
    }

    if not os.path.exists(CONFIG_PATH):
        try:
            with open(CONFIG_PATH, 'w') as f:
                json.dump(default_config, f, indent=4)
        except Exception:
            pass
        return default_config

    try:
        with open(CONFIG_PATH, 'r') as f:
            config = json.load(f)
            # Ensure all keys exist
            for k, v in default_config.items():
                if k not in config:
                    config[k] = v
            return config
    except Exception:
        return default_config

def get_recent_track(username, api_key):
    encoded_user = urllib.parse.quote(username)
    url = f"https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user={encoded_user}&api_key={api_key}&format=json&limit=1"
    headers = {
        'User-Agent': 'WaybarLastFm/1.0'
    }
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode('utf-8'))

        tracks = data.get('recenttracks', {}).get('track', [])
        if not tracks:
            return None

        # Last.fm can return a dict if only 1 track exists in rare API shapes
        if isinstance(tracks, dict):
            tracks = [tracks]

        track = tracks[0]
        artist = track.get('artist', {}).get('#text', '')
        track_name = track.get('name', '')

        is_playing = False
        if '@attr' in track and track['@attr'].get('nowplaying') == 'true':
            is_playing = True

        return {
            "artist": artist,
            "track": track_name,
            "now_playing": is_playing
        }
    except Exception:
        return None

def main():
    config = load_config()
    username = config.get("username", "").strip()
    api_key = config.get("api_key", "").strip()
    show_last_scrobbled = config.get("show_last_scrobbled", False)

    if not username or not api_key:
        sys.stdout.write("\n")
        sys.stdout.flush()
        return

    result = get_recent_track(username, api_key)
    if not result:
        # Silent hide on network error or empty profile
        sys.stdout.write("\n")
        sys.stdout.flush()
        return

    artist = result["artist"]
    track = result["track"]
    now_playing = result["now_playing"]

    output = {}

    # Waybar config has "escape": true, so Waybar handles markup escaping.
    # Passing raw strings avoids double-escaping (e.g. &amp;amp;).
    if now_playing:
        output["text"] = f"{artist} - {track}"
        output["class"] = "playing"
        output["alt"] = "playing"
        output["tooltip"] = f"Now Playing on Last.fm:\n{artist} - {track}"
    elif show_last_scrobbled:
        output["text"] = f"{artist} - {track}"
        output["class"] = "last-played"
        output["alt"] = "last-played"
        output["tooltip"] = f"Last Scrobbled on Last.fm:\n{artist} - {track}"
    else:
        # Not playing, and don't want to show last scrobbled
        sys.stdout.write("\n")
        sys.stdout.flush()
        return

    sys.stdout.write(json.dumps(output, ensure_ascii=False) + "\n")
    sys.stdout.flush()

if __name__ == "__main__":
    main()
