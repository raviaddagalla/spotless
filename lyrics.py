import os
import time
import random
import requests
import pandas as pd

SONGS_CSV = "songs.csv"
OUTPUT_FOLDER = "lyrics"

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

df = pd.read_csv(SONGS_CSV)

HEADERS = {
    "User-Agent": "ENAO-LyricsDownloader/1.0"
}

for index, row in df.iterrows():

    filename = row["filename"]
    title = str(row["title"]).strip()
    artist = str(row["artist"]).strip()

    base_name = os.path.splitext(filename)[0]

    txt_file = os.path.join(OUTPUT_FOLDER, base_name + ".txt")
    lrc_file = os.path.join(OUTPUT_FOLDER, base_name + ".lrc")

    if os.path.exists(txt_file) or os.path.exists(lrc_file):
        print(f"[{index+1}/{len(df)}] Already downloaded")
        continue

    print(f"[{index+1}/{len(df)}] {title} - {artist}")

    params = {
        "track_name": title,
        "artist_name": artist
    }

    success = False

    for attempt in range(3):

        try:

            response = requests.get(
                "https://lrclib.net/api/get",
                params=params,
                headers=HEADERS,
                timeout=20
            )

            if response.status_code == 404:
                print("No lyrics found.")
                success = True
                break

            response.raise_for_status()

            data = response.json()

            synced = data.get("syncedLyrics")
            plain = data.get("plainLyrics")

            if synced:

                with open(lrc_file, "w", encoding="utf-8") as f:
                    f.write(synced)

                print("Saved synced lyrics.")

            elif plain:

                with open(txt_file, "w", encoding="utf-8") as f:
                    f.write(plain)

                print("Saved plain lyrics.")

            else:

                print("Lyrics missing.")

            success = True
            break

        except Exception as e:

            print("Attempt", attempt + 1, "failed:", e)

            if attempt < 2:
                wait = random.randint(5, 15)
                print(f"Retrying in {wait} seconds...")
                time.sleep(wait)

    delay = random.uniform(1.5, 4)

    time.sleep(delay)

print("\nFinished.")