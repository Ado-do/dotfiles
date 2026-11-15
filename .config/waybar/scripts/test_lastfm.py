#!/usr/bin/env python3
import urllib.request
import re
import json
import html as html_lib

def test_parse(username):
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    url = f"https://www.last.fm/user/{username}"
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            html_data = response.read().decode('utf-8')
    except Exception as e:
        print(f"Error fetching URL: {e}")
        return None

    # Try nowplaying row
    match = re.search(r'<tr[^>]*chartlist-row--nowplaying.*?>.*?</tr>', html_data, re.DOTALL)
    nowplaying = True
    if not match:
        nowplaying = False
        print("No nowplaying row. Trying first regular row.")
        match = re.search(r'<tr[^>]*chartlist-row.*?>.*?</tr>', html_data, re.DOTALL)
        
    if not match:
        print("No rows found.")
        return None
        
    row_html = match.group(0)
    print(f"Row HTML:\n{row_html}\n")
    
    name_match = re.search(r'class="chartlist-name".*?<a[^>]*title="([^"]+)"', row_html, re.DOTALL)
    if not name_match:
        name_match = re.search(r'class="chartlist-name".*?<a[^>]*>(.*?)</a>', row_html, re.DOTALL)
        
    artist_match = re.search(r'class="chartlist-artist".*?<a[^>]*title="([^"]+)"', row_html, re.DOTALL)
    if not artist_match:
        artist_match = re.search(r'class="chartlist-artist".*?<a[^>]*>(.*?)</a>', row_html, re.DOTALL)
        
    if name_match:
        print(f"Name Match: {name_match.groups()}")
    else:
        print("Name NOT matched")
        
    if artist_match:
        print(f"Artist Match: {artist_match.groups()}")
    else:
        print("Artist NOT matched")
        
    if name_match and artist_match:
        track = name_match.group(1).strip()
        artist = artist_match.group(1).strip()
        track = html_lib.unescape(track)
        artist = html_lib.unescape(artist)
        return {"nowplaying": nowplaying, "track": track, "artist": artist}
    return None

if __name__ == "__main__":
    import sys
    username = sys.argv[1] if len(sys.argv) > 1 else "aibe"
    res = test_parse(username)
    print(f"Final Result: {res}")
