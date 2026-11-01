import glob
import json
import os
import re
import time
import urllib.parse
import urllib.request

import yt_dlp
from mutagen import File as MutagenFile
from mutagen.easyid3 import EasyID3
from mutagen.id3 import APIC, ID3, ID3NoHeaderError
from mutagen.mp4 import MP4, MP4Cover

HOME = os.environ.get("HOME") or os.path.expanduser("~")
PROGRESS_FILE = os.path.join(HOME, "ytdlp_progress.txt")
DEBUG_FILE = os.path.join(HOME, "ytdlp_debug.log")
CANCEL_FILE = os.path.join(HOME, "ytdlp_cancel.flag")


class DownloadCancelled(Exception):
    pass


def _log(msg):
    try:
        with open(DEBUG_FILE, "a") as f:
            f.write("%.3f %s\n" % (time.time(), msg))
    except Exception:
        pass


def _dumps(value):
    return json.dumps(value, ensure_ascii=False, default=str)


def _clear_cancel():
    try:
        os.remove(CANCEL_FILE)
    except OSError:
        pass


def cancel_download():
    try:
        with open(CANCEL_FILE, "w") as f:
            f.write("cancel")
    except Exception:
        pass
    try:
        with open(PROGRESS_FILE, "w") as f:
            f.write("cancelled|0|0")
    except Exception:
        pass
    return _dumps(True)


def _check_cancel():
    if os.path.exists(CANCEL_FILE):
        raise DownloadCancelled("cancelled")


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
        _check_cancel()
        total = d.get("total_bytes") or d.get("total_bytes_estimate") or 0
        done = d.get("downloaded_bytes") or 0
        pct = (done * 100.0 / total) if total else 0.0
        try:
            with open(PROGRESS_FILE, "w") as f:
                f.write("%.1f|%d|%d" % (pct, done, total))
        except Exception:
            pass
    elif d.get("status") == "finished":
        _check_cancel()
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


def _thumbnail(entry):
    thumb = entry.get("thumbnail")
    thumbs = entry.get("thumbnails") or []
    if not thumb and thumbs:
        thumb = thumbs[-1].get("url") if isinstance(thumbs[-1], dict) else None
    if not thumb and entry.get("id"):
        thumb = "https://i.ytimg.com/vi/%s/mqdefault.jpg" % entry["id"]
    return thumb


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
        results.append(
            {
                "id": e.get("id"),
                "title": e.get("title"),
                "duration": e.get("duration"),
                "thumbnail": _thumbnail(e),
                "channel": e.get("channel") or e.get("uploader"),
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
    "vevo", "records", "music", "official", "entertainment", "topic",
]


def _phrase_in(phrase, text):
    """Whole-phrase match so 'live' does not match 'alive'/'delivery'."""
    if not phrase or not text:
        return False
    pattern = r"(?<![a-z0-9])" + re.escape(phrase.lower()) + r"(?![a-z0-9])"
    return re.search(pattern, text.lower()) is not None


def _score_candidate(entry, artist, title, expected_duration_s=None):
    """Score a YouTube search result for how likely it is the correct
    studio recording. Higher = better."""
    score = 50.0
    yt_title = (entry.get("title") or "").lower()
    channel = (entry.get("channel") or entry.get("uploader") or "").lower()
    duration = entry.get("duration")

    # Penalize unwanted versions. Whole-phrase matching avoids false hits
    # such as "Alive" matching the "live" penalty.
    for term in _PENALIZED_TERMS:
        if _phrase_in(term, yt_title):
            score -= 20

    # Bonus for preferred terms, without double-counting "audio" inside
    # "official audio" (the old scorer added +30 for that combination).
    if _phrase_in("official audio", yt_title):
        score += 30
    elif _phrase_in("official video", yt_title) or _phrase_in(
        "official music", yt_title
    ):
        score += 22
    elif _phrase_in("audio", yt_title):
        score += 10

    # Bonus for official-looking channels.
    for hint in _OFFICIAL_CHANNEL_HINTS:
        if _phrase_in(hint, channel):
            score += 10
            break

    # Artist name appears in channel name.
    if artist and _phrase_in(artist, channel):
        score += 15

    # Artist name appears in video title.
    if artist and _phrase_in(artist, yt_title):
        score += 5

    # Title appears in video title.
    if title and _phrase_in(title, yt_title):
        score += 10

    # Duration matching.
    if expected_duration_s and duration:
        diff = abs(int(duration) - int(expected_duration_s))
        if diff <= 5:
            score += 12
        elif diff <= 15:
            score += 6
        elif diff <= 30:
            pass  # neutral
        elif diff <= 60:
            score -= 12
        else:
            score -= 30

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
    or {} if nothing is found or the best candidate scores too low."""
    _log("canonical_search: %r - %r (dur=%s)" % (artist, title, expected_duration_s))
    queries = [
        "%s %s official audio" % (artist, title),
        "%s - %s" % (artist, title),
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
                s = _score_candidate(
                    e, artist, title,
                    expected_duration_s=int(expected_duration_s) if expected_duration_s else None,
                )
                all_candidates.append({
                    "id": e["id"],
                    "title": e.get("title"),
                    "duration": e.get("duration"),
                    "channel": e.get("channel") or e.get("uploader"),
                    "thumbnail": _thumbnail(e),
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
    # A low score means we only found karaoke/live/cover/short clips. It is
    # better to fail and let the user see the error than to download the
    # wrong recording.
    if best["score"] < 35:
        _log("canonical_search: best score too low (%.1f)" % best["score"])
        return _dumps({})
    _log("canonical_search: best=%s score=%.1f title=%r" % (best["id"], best["score"], best["title"]))
    return _dumps(best)


def download(url, outdir, base_name):
    _log("download start: %r -> %s" % (url, outdir))
    _clear_cancel()
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
    except DownloadCancelled:
        _cleanup_partial(outdir, base_name)
        _log("download cancelled")
        return _dumps({"path": None, "cancelled": True})
    except Exception as e:
        _log("download error: %r" % (e,))
        _cleanup_partial(outdir, base_name)
        raise
    prefix = base_name + "."
    matches = sorted(
        name for name in os.listdir(outdir)
        if name.startswith(prefix) and not name.endswith(".part")
    )
    if matches:
        name = matches[0]
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


def _cleanup_partial(outdir, base_name):
    for pattern in (
        os.path.join(outdir, base_name + ".*.part"),
        os.path.join(outdir, base_name + ".part"),
        os.path.join(outdir, base_name + ".*.ytdl"),
    ):
        try:
            for path in glob.glob(pattern):
                os.remove(path)
        except Exception:
            pass


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


def set_tags(path, title, artist, album=None):
    if str(path).lower().endswith(".mp3"):
        try:
            audio = EasyID3(str(path))
        except ID3NoHeaderError:
            audio = EasyID3()
        if title:
            audio["title"] = str(title)
        if artist:
            audio["artist"] = str(artist)
        if album:
            audio["album"] = str(album)
        audio.save(str(path))
    else:
        mp4 = MP4(str(path))
        if title:
            mp4.tags["\xa9nam"] = [str(title)]
        if artist:
            mp4.tags["\xa9ART"] = [str(artist)]
        if album:
            mp4.tags["\xa9alb"] = [str(album)]
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


def _norm_text(value):
    value = (value or "").lower()
    value = re.sub(r"\([^)]*\)|\[[^\]]*\]", " ", value)
    value = re.sub(r"[^a-z0-9\u00c0-\uffff]+", " ", value)
    return re.sub(r"\s+", " ", value).strip()


def _pick_lyrics(entries, artist, title, duration_s):
    """Pick the best LRCLIB entry, never an arbitrary first result."""
    if not entries:
        return None
    expected = float(duration_s) if duration_s else None
    artist_n = _norm_text(artist)
    title_n = _norm_text(title)
    best = None
    best_score = -1.0
    for e in entries:
        if not isinstance(e, dict):
            continue
        plain = (e.get("plainLyrics") or "").strip()
        synced = (e.get("syncedLyrics") or "").strip()
        if not plain and not synced:
            continue
        entry_duration = e.get("duration")
        if expected and entry_duration:
            diff = abs(float(entry_duration) - expected)
            # A live/cover/remix is usually 20-120s longer/shorter. Reject
            # blatant mismatches rather than applying an arbitrary offset.
            if diff > 10:
                continue
        else:
            diff = 0.0
        e_title = _norm_text(e.get("trackName"))
        e_artist = _norm_text(e.get("artistName"))
        score = 0.0
        if title_n and e_title == title_n:
            score += 50
        elif title_n and (title_n in e_title or e_title in title_n):
            score += 25
        if artist_n and e_artist == artist_n:
            score += 40
        elif artist_n and (artist_n in e_artist or e_artist in artist_n):
            score += 20
        score += max(0.0, 15.0 - diff * 1.5)
        if synced:
            score += 10
        # Prefer community entries with a closer duration.
        if score > best_score:
            best_score = score
            best = e
    return best


def fetch_lyrics(title, artist, album=None, duration_s=None):
    _log("fetch_lyrics start: %r - %r (album=%r, dur=%s)" % (artist, title, album, duration_s))
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
        data = None

    chosen = None
    candidates = []
    if isinstance(data, dict):
        candidates.append(data)
    if isinstance(candidates, dict):
        chosen = _pick_lyrics([candidates], artist, title, duration_s)
    if chosen is None:
        try:
            candidates = _lrclib_get(
                "https://lrclib.net/api/search?q=%s"
                % urllib.parse.quote("%s %s" % (artist, title))
            )
        except Exception as e:
            _log("fetch_lyrics error: %r" % (e,))
            candidates = []
    if isinstance(candidates, list):
        chosen = _pick_lyrics(candidates, artist, title, duration_s)
    elif isinstance(candidates, dict) and chosen is None:
        chosen = _pick_lyrics([candidates], artist, title, duration_s)

    if not chosen:
        _log("fetch_lyrics done: no reliable match")
        return _dumps({"lyrics": None, "is_synced": False})

    plain = chosen.get("plainLyrics") or ""
    synced = chosen.get("syncedLyrics") or ""
    # IMPORTANT: prefer synced lyrics over plain when available.
    lyrics_text = synced or plain
    is_synced = bool(synced)
    _log("fetch_lyrics done: %d chars, synced=%s, matched=%r"
         % (len(lyrics_text), is_synced, chosen.get("trackName")))
    return _dumps({
        "lyrics": lyrics_text,
        "is_synced": is_synced,
        "matched_duration": chosen.get("duration"),
        "matched_title": chosen.get("trackName"),
        "matched_artist": chosen.get("artistName"),
        "instrumental": bool(chosen.get("instrumental")),
    })
