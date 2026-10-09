import os
import time
import random
import shutil
import pandas as pd
from yt_dlp import YoutubeDL
from mutagen.easyid3 import EasyID3
from mutagen.id3 import ID3NoHeaderError

CSV_FILES = [
    "sleep.csv",
    "no_sleep.csv",
]

OUTPUT_FOLDER = "music"
MAPPING_FILE = "songs.csv"

# Set to your ffmpeg bin folder if ffmpeg isn't in PATH.
FFMPEG_PATH = r"C:\Users\aravi\Downloads\ffmpeg-8.1.2-essentials_build\bin"
# Example:
# FFMPEG_PATH = r"D:\ffmpeg\bin"

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

dfs = [pd.read_csv(f) for f in CSV_FILES]
df = pd.concat(dfs, ignore_index=True)
df = df.drop_duplicates(
    subset=["Track Name", "Artist Name(s)"]
).reset_index(drop=True)

print(f"Found {len(df)} unique songs.")

mapping = []
if os.path.exists(MAPPING_FILE):
    try:
        mapping = pd.read_csv(MAPPING_FILE).to_dict("records")
    except Exception:
        mapping = []

ydl_opts = {
    "format": "bestaudio/best",
    "outtmpl": os.path.join(OUTPUT_FOLDER, "%(id)s.%(ext)s"),
    "noplaylist": True,
    "quiet": False,
    "postprocessors": [{
        "key": "FFmpegExtractAudio",
        "preferredcodec": "mp3",
        "preferredquality": "0",
    }]
}

if FFMPEG_PATH:
    ydl_opts["ffmpeg_location"] = FFMPEG_PATH

with YoutubeDL(ydl_opts) as ydl:

    total = len(df)

    for index, row in df.iterrows():

        number = index + 1
        filename = f"{number:07d}.mp3"
        final_path = os.path.join(OUTPUT_FOLDER, filename)

        song = str(row["Track Name"]).strip()
        artist = str(row["Artist Name(s)"]).strip()

        if os.path.exists(final_path):
            print(f"[{number}/{total}] Already downloaded.")
            continue

        print("=" * 60)
        print(f"[{number}/{total}] {song} - {artist}")

        query = f"ytsearch1:{song} {artist} official audio"

        success = False

        for attempt in range(3):

            try:

                info = ydl.extract_info(query, download=True)

                if "entries" in info:
                    info = info["entries"][0]

                downloaded = None

                for ext in ("mp3", "m4a", "webm", "opus"):
                    candidate = os.path.join(
                        OUTPUT_FOLDER,
                        f"{info['id']}.{ext}"
                    )

                    if os.path.exists(candidate):
                        downloaded = candidate
                        break

                if downloaded is None:
                    raise FileNotFoundError("Downloaded audio not found.")

                shutil.move(downloaded, final_path)

                try:
                    try:
                        audio = EasyID3(final_path)
                    except ID3NoHeaderError:
                        audio = EasyID3()

                    audio["title"] = song
                    audio["artist"] = artist
                    audio.save(final_path)

                except Exception as e:
                    print("Metadata warning:", e)

                mapping.append({
                    "id": number,
                    "filename": filename,
                    "title": song,
                    "artist": artist,
                    "youtube_id": info["id"],
                    "youtube_title": info.get("title", "")
                })

                pd.DataFrame(mapping).to_csv(
                    MAPPING_FILE,
                    index=False
                )

                print("Saved:", filename)

                success = True
                break

            except Exception as e:

                msg = str(e)
                print(f"Attempt {attempt + 1}/3 failed:")
                print(msg)

                if (
                    "429" in msg or
                    "Too Many Requests" in msg or
                    "Sign in to confirm" in msg or
                    "rate limit" in msg.lower()
                ):
                    print("\\nRate limited by YouTube. Exiting safely.")
                    raise SystemExit

                if attempt < 2:
                    wait = random.randint(1, 5)
                    print(f"Retrying in {wait} seconds...")
                    time.sleep(wait)

        if not success:
            print("Skipping song.")

        delay = random.uniform(3, 7)
        print(f"Waiting {delay:.1f} seconds...\\n")
        time.sleep(delay)

print("Finished.")