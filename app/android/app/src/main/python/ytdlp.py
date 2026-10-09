import json
import os
import time
import urllib.request
import urllib.parse

import yt_dlp
from mutagen import File as MutagenFile
from mutagen.easyid3 import EasyID3
from mutagen.id3 import APIC, ID3, ID3NoHeaderError
from mutagen.mp4 import MP4, MP4Cover

PROGRESS_FILE = os.path.join(os.environ["HOME"], "ytdlp_progress.txt")
DEBUG_FILE = os.path.join(os.environ["HOME"], "ytdlp_debug.log")


def _log(msg):
    try:
        with open(DEBUG_FILE, "a") as f:
            f.write("%.3f %s\n" % (time.time(), msg))
    except Exception:
        pass


def _dumps(value):
    return json.dumps(value, ensure_ascii=False, default=str)

BASE_OPTS = {
    "quiet": True,
    "no_warnings": True,
    "noplaylist": True,
    "noprogress": True,
    "socket_timeout": 15,
    # Client order matters: in 2026 YouTube's "android" client stopped
    # returning real audio formats (only storyboards/mhtml, which broke
    # streaming). android_vr / tv_embedded / android_creator reliably
    # return audio-only formats (140 m4a, 251 webm/opus); "ios" stays as
    # a final fallback.
    "extractor_args": {
        "youtube": {
            "player_client": ["android_vr", "tv_embedded", "android_creator", "ios"],
            "gl": "US",
            "hl": "en",
        }
    },
}


def _progress_hook(d):
    if d.get("status") == "downloading":
        total = d.get("total_bytes") or d.get("total_bytes_estimate") or 0
        done = d.get("downloaded_bytes") or 0
        pct = (done * 100.0 / total) if total else 0.0
        try:
            with open(PROGRESS_FILE, "w") as f:
                f.write("%.1f|%d|%d" % (pct, done, total))
        except Exception:
            pass
    elif d.get("status") == "finished":
        try:
            with open(PROGRESS_FILE, "w") as f:
                f.write("100.0|0|0")
        except Exception:
            pass


def get_progress():
    try:
        with open(PROGRESS_FILE) as f:
            return f.read().strip()
    except Exception:
        return ""


def _pick_audio(info):
    fmts = [
        f
        for f in (info.get("formats") or [])
        if f.get("vcodec") in (None, "none")
        # Storyboard thumbnails (ext mhtml, acodec none) look like
        # audio-only to a naive filter but are unplayable images — exclude
        # them so streaming never picks a storyboard URL.
        and f.get("acodec") not in (None, "none")
        and f.get("url")
        and f.get("ext") not in (None, "unknown", "mhtml")
    ]
    fmts.sort(
        key=lambda f: (f.get("abr") or 0, f.get("tbr") or 0),
        reverse=True,
    )
    if not fmts:
        return None
    best = fmts[0]
    # ExoPlayer rejects most googlevideo URLs without a browser User-Agent,
    # so always hand the stream headers through to the app.
    headers = best.get("http_headers") or {
        "User-Agent": (
            "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36"
        )
    }
    return {
        "url": best["url"],
        "ext": best.get("ext"),
        "abr": best.get("abr"),
        "codec": best.get("acodec"),
        "headers": headers,
    }


def extract(query):
    _log("extract start: %r" % (query,))
    opts = dict(BASE_OPTS)
    # No "format" key: _pick_audio picks the best audio-only format from the
    # raw list itself, so yt-dlp's own format selection can't throw
    # "Requested format is not available" for clients with no audio formats.
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(query, download=False)
        _log("extract done: %s" % ((info or {}).get("id"),))
    except Exception as e:
        _log("extract error: %r" % (e,))
        raise
    if info is None:
        return _dumps({})
    audio = _pick_audio(info)
    return _dumps({
        "id": info.get("id"),
        "title": info.get("title"),
        "duration": info.get("duration"),
        "thumbnail": info.get("thumbnail"),
        "url": audio["url"] if audio else None,
        "ext": audio["ext"] if audio else None,
        "abr": audio["abr"] if audio else None,
        "headers": audio["headers"] if audio else None,
    })


def search(query, max_results=10):
    _log("search start: %r x%d" % (query, int(max_results)))
    opts = dict(BASE_OPTS)
    count = max(int(max_results), 1)
    # extract_flat: the search page alone has all the metadata we show
    # (id/title/duration/channel/thumbnails) without resolving each video
    # through the player API — ~9x faster (2s vs 18s for 10 results).
    opts["extract_flat"] = "in_playlist"
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info("ytsearch%d:%s" % (count, query), download=False)
        _log("search done: %d entries" % len(info.get("entries") or []))
    except Exception as e:
        _log("search error: %r" % (e,))
        raise
    results = []
    for e in (info.get("entries") or [])[: max(int(max_results), 1)]:
        if not e:
            continue
        # Flat entries don't have a top-level thumbnail, but do carry a
        # `thumbnails` list; fall back to a deterministic i.ytimg.com URL.
        thumb = e.get("thumbnail")
        thumbs = e.get("thumbnails") or []
        if not thumb and thumbs:
            thumb = thumbs[-1].get("url") if isinstance(thumbs[-1], dict) else None
        if not thumb and e.get("id"):
            thumb = "https://i.ytimg.com/vi/%s/mqdefault.jpg" % e["id"]
        results.append(
            {
                "id": e.get("id"),
                "title": e.get("title"),
                "duration": e.get("duration"),
                "thumbnail": thumb,
                "channel": e.get("channel"),
            }
        )
    return _dumps(results)


# ---- Canonical search (Phase 2): score multiple YouTube results ----

_PENALIZED_TERMS = [
    "live", "concert", "performance", "cover", "remix", "karaoke",
    "instrumental", "sped up", "slowed", "nightcore", "fan-made",
    "reaction", "compilation", "shorts", "acoustic version",
    "piano version", "unplugged",
]

_PREFERRED_TERMS = [
    "official audio", "official music", "official video", "audio",
]

_OFFICIAL_CHANNEL_HINTS = [
    "vevo", "records", "music", "official", "entertainment",
]


def _score_candidate(entry, artist, title, expected_duration_s=None):
    """Score a YouTube search result for how likely it is the correct
    studio recording. Higher = better."""
    score = 50.0
    yt_title = (entry.get("title") or "").lower()
    channel = (entry.get("channel") or "").lower()
    duration = entry.get("duration")

    # Penalize unwanted versions.
    for term in _PENALIZED_TERMS:
        if term in yt_title:
            score -= 20

    # Bonus for preferred terms.
    for term in _PREFERRED_TERMS:
        if term in yt_title:
            score += 15

    # Bonus for official-looking channels.
    for hint in _OFFICIAL_CHANNEL_HINTS:
        if hint in channel:
            score += 10
            break

    # Artist name appears in channel name.
    if artist and artist.lower() in channel:
        score += 15

    # Artist name appears in video title.
    if artist and artist.lower() in yt_title:
        score += 5

    # Title appears in video title.
    if title and title.lower() in yt_title:
        score += 5

    # Duration matching.
    if expected_duration_s and duration:
        diff = abs(int(duration) - int(expected_duration_s))
        if diff <= 5:
            score += 10
        elif diff <= 15:
            score += 5
        elif diff <= 30:
            pass  # neutral
        elif diff <= 60:
            score -= 10
        else:
            score -= 25

    # Heavily penalize very short (< 30s) or very long (> 15min) results.
    if duration:
        if int(duration) < 30:
            score -= 40
        elif int(duration) > 900:
            score -= 30

    return score


def canonical_search(artist, title, expected_duration_s=None, max_candidates=8):
    """Search YouTube for the best canonical (studio) recording.
    Returns the top result as a dict with id/title/duration/channel/thumbnail/score,
    or {} if nothing is found."""
    _log("canonical_search: %r - %r (dur=%s)" % (artist, title, expected_duration_s))
    # Try multiple query strategies.
    queries = [
        "%s %s official audio" % (artist, title),
        "%s %s audio" % (artist, title),
        "%s %s" % (artist, title),
    ]
    all_candidates = []
    seen_ids = set()
    opts = dict(BASE_OPTS)
    opts["extract_flat"] = "in_playlist"
    for query in queries:
        try:
            with yt_dlp.YoutubeDL(opts) as ydl:
                info = ydl.extract_info(
                    "ytsearch%d:%s" % (max_candidates, query), download=False
                )
            for e in (info.get("entries") or [])[:max_candidates]:
                if not e or not e.get("id"):
                    continue
                if e["id"] in seen_ids:
                    continue
                seen_ids.add(e["id"])
                thumb = e.get("thumbnail")
                thumbs = e.get("thumbnails") or []
                if not thumb and thumbs:
                    thumb = thumbs[-1].get("url") if isinstance(thumbs[-1], dict) else None
                if not thumb and e.get("id"):
                    thumb = "https://i.ytimg.com/vi/%s/mqdefault.jpg" % e["id"]
                s = _score_candidate(
                    e, artist, title,
                    expected_duration_s=int(expected_duration_s) if expected_duration_s else None,
                )
                all_candidates.append({
                    "id": e["id"],
                    "title": e.get("title"),
                    "duration": e.get("duration"),
                    "channel": e.get("channel"),
                    "thumbnail": thumb,
                    "score": s,
                })
        except Exception as ex:
            _log("canonical_search query %r failed: %r" % (query, ex))
            continue
    if not all_candidates:
        _log("canonical_search: no candidates found")
        return _dumps({})
    all_candidates.sort(key=lambda c: c["score"], reverse=True)
    best = all_candidates[0]
    _log("canonical_search: best=%s score=%.1f title=%r" % (best["id"], best["score"], best["title"]))
    return _dumps(best)


def download(url, outdir, base_name):
    _log("download start: %r -> %s" % (url, outdir))
    opts = dict(BASE_OPTS)
    opts["format"] = "bestaudio/best"
    opts["outtmpl"] = os.path.join(outdir, base_name + ".%(ext)s")
    opts["progress_hooks"] = [_progress_hook]
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(url, download=True)
        # "ytsearch1:..." returns a playlist wrapper; unwrap to the video so
        # id/title/thumbnail below come from the actual downloaded track.
        if info and "entries" in info:
            entries = [e for e in (info.get("entries") or []) if e]
            info = entries[0] if entries else None
    except Exception as e:
        _log("download error: %r" % (e,))
        raise
    prefix = base_name + "."
    for name in sorted(os.listdir(outdir)):
        if name.startswith(prefix) and name != base_name:
            _log("download done: %s" % name)
            return _dumps({
                "path": os.path.join(outdir, name),
                "ext": name.rsplit(".", 1)[-1],
                "title": (info or {}).get("title"),
                "duration": (info or {}).get("duration"),
                "id": (info or {}).get("id"),
                "thumbnail": (info or {}).get("thumbnail"),
            })
    _log("download done: NO FILE FOUND")
    return _dumps({"path": None})


def embed_cover(path, image_bytes, mime="image/jpeg"):
    if str(path).lower().endswith(".mp3"):
        try:
            tags = ID3(str(path))
        except ID3NoHeaderError:
            tags = ID3()
        tags.delall("APIC")
        tags.add(
            APIC(
                encoding=3,
                mime=str(mime),
                type=3,
                desc="Cover",
                data=bytes(image_bytes),
            )
        )
        tags.save(str(path))
    else:
        mp4 = MP4(str(path))
        fmt = (
            MP4Cover.FORMAT_PNG
            if str(mime).lower().endswith("png")
            else MP4Cover.FORMAT_JPEG
        )
        mp4.tags["covr"] = [MP4Cover(bytes(image_bytes), imageformat=fmt)]
        mp4.save()
    return _dumps(True)


def set_tags(path, title, artist):
    if str(path).lower().endswith(".mp3"):
        try:
            audio = EasyID3(str(path))
        except ID3NoHeaderError:
            audio = EasyID3()
        if title:
            audio["title"] = str(title)
        if artist:
            audio["artist"] = str(artist)
        audio.save(str(path))
    else:
        mp4 = MP4(str(path))
        if title:
            mp4.tags["\xa9nam"] = [str(title)]
        if artist:
            mp4.tags["\xa9ART"] = [str(artist)]
        mp4.save()
    return _dumps(True)


def probe(path):
    f = MutagenFile(str(path))
    if f is None or f.info is None:
        return _dumps({"duration": None})
    return _dumps({"duration": int(f.info.length)})


def _lrclib_get(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Spotless/1.0"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read().decode("utf-8"))


def fetch_lyrics(title, artist, album=None, duration_s=None):
    _log("fetch_lyrics start: %r - %r (album=%r, dur=%s)" % (artist, title, album, duration_s))
    # Prefer the exact track/artist match (404 when not found), then fall
    # back to a fuzzy search and take its best result.
    data = None
    # Try exact match first, with optional duration for better precision.
    try:
        params = "track_name=%s&artist_name=%s" % (
            urllib.parse.quote(title), urllib.parse.quote(artist)
        )
        if album:
            params += "&album_name=%s" % urllib.parse.quote(album)
        if duration_s:
            params += "&duration=%s" % int(duration_s)
        data = _lrclib_get("https://lrclib.net/api/get?%s" % params)
    except Exception:
        try:
            data = _lrclib_get(
                "https://lrclib.net/api/search?q=%s"
                % urllib.parse.quote("%s %s" % (artist, title))
            )
            if isinstance(data, list):
                # If we have duration, prefer the entry whose duration is closest.
                if data and duration_s:
                    dur = int(duration_s)
                    data.sort(key=lambda e: abs((e.get("duration") or 0) - dur))
                data = data[0] if data else None
        except Exception as e:
            _log("fetch_lyrics error: %r" % (e,))
            return _dumps({"lyrics": None, "is_synced": False})
    if not data:
        _log("fetch_lyrics done: no lyrics")
        return _dumps({"lyrics": None, "is_synced": False})
    plain = data.get("plainLyrics") or ""
    synced = data.get("syncedLyrics") or ""
    # IMPORTANT: prefer synced lyrics over plain when available.
    lyrics_text = synced or plain
    is_synced = bool(synced)
    _log("fetch_lyrics done: %d chars, synced=%s" % (len(lyrics_text), is_synced))
    return _dumps({"lyrics": lyrics_text, "is_synced": is_synced})
