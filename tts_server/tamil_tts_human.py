"""
╔══════════════════════════════════════════════════════════════╗
║   TAMIL TTS - REAL HUMAN VOICE FEEL  (v2 - IMPROVED)       ║
║   FREE | No API Key | Microsoft Edge Neural Voices          ║
╚══════════════════════════════════════════════════════════════╝

INSTALL:
    pip install edge-tts pydub pygame

    # Also install ffmpeg (needed by pydub for MP3):
    # Windows:  winget install ffmpeg
    # Mac:      brew install ffmpeg
    # Linux:    sudo apt install ffmpeg

RUN:
    python tamil_tts_human.py
"""

import asyncio
import os
import sys
import tempfile
import random
import re
import shutil
import time

# ── Auto-install missing packages ─────────────────────────────────────────────
def ensure(pkg, import_as=None):
    try:
        __import__(import_as or pkg)
    except ImportError:
        print(f"📦 Installing {pkg}...")
        os.system(f"{sys.executable} -m pip install {pkg} -q")

ensure("edge-tts",  "edge_tts")
ensure("pydub")
ensure("pygame")

import edge_tts
from pydub import AudioSegment
from pydub import effects as pydub_effects
import pygame


# ══════════════════════════════════════════════════════════════════════════════
#  VOICE PROFILES  —  each has slightly different pitch / rate to sound varied
# ══════════════════════════════════════════════════════════════════════════════

VOICES = {
    "1": {
        "name":  "ta-IN-PallaviNeural",
        "label": "🌸 Pallavi  (Female · Chennai Tamil)",
        # Slightly warmer: tiny rate slowdown, mild pitch lift = natural female cadence
        "rate":  "-8%",
        "pitch": "+10Hz",
    },
    "2": {
        "name":  "ta-IN-ValluvarNeural",
        "label": "🎙️ Valluvar (Male   · Chennai Tamil)",
        # Slightly deeper, relaxed pace
        "rate":  "-5%",
        "pitch": "-15Hz",
    },
    "3": {
        "name":  "ta-SG-VenbaNeural",
        "label": "🌺 Venba    (Female · Singapore Tamil)",
        "rate":  "-6%",
        "pitch": "+8Hz",
    },
    "4": {
        "name":  "ta-SG-AnbuNeural",
        "label": "🎤 Anbu     (Male   · Singapore Tamil)",
        "rate":  "-4%",
        "pitch": "-10Hz",
    },
}

# ══════════════════════════════════════════════════════════════════════════════
#  HUMAN-FEEL TEXT PREPROCESSOR
#  ► Splits long text into short natural sentences
#  ► Adds context-aware pauses after punctuation
#  ► Inserts filler sounds / natural Tamil conversational markers
# ══════════════════════════════════════════════════════════════════════════════

# Pause durations in milliseconds (used when stitching audio clips)
PAUSE = {
    "comma":      180,   # short breath at comma
    "sentence":   380,   # breath between sentences
    "exclaim":    300,   # slight pause after ! (excitement fades)
    "question":   320,   # after ? (listener processing time)
    "paragraph":  600,   # between big blocks
}

def split_into_chunks(text: str) -> list[tuple[str, int]]:
    """
    Returns list of (chunk_text, pause_after_ms).
    Splits on: । . ? ! , — —
    Keeps each chunk ≤ ~80 chars so the TTS engine doesn't rush.
    """
    # Normalise: collapse multiple spaces/newlines
    text = re.sub(r"\s+", " ", text).strip()

    # Split on sentence-ending punctuation
    raw_parts = re.split(r"([.!?,।])", text)

    chunks = []
    buf = ""
    pause_after = PAUSE["sentence"]

    for part in raw_parts:
        part = part.strip()
        if not part:
            continue

        if part in (".", "।"):
            buf = buf.strip()
            if buf:
                chunks.append((buf + ".", PAUSE["sentence"]))
            buf = ""
        elif part == "!":
            buf = buf.strip()
            if buf:
                chunks.append((buf + "!", PAUSE["exclaim"]))
            buf = ""
        elif part == "?":
            buf = buf.strip()
            if buf:
                chunks.append((buf + "?", PAUSE["question"]))
            buf = ""
        elif part == ",":
            buf = (buf + ",").strip()
            if len(buf) > 50:          # long enough — flush
                chunks.append((buf, PAUSE["comma"]))
                buf = ""
            # else keep building (short clause, don't break)
        else:
            buf = (buf + " " + part).strip()
            # Hard-break very long runs even without punctuation
            if len(buf) > 90:
                chunks.append((buf, PAUSE["sentence"]))
                buf = ""

    if buf.strip():
        chunks.append((buf.strip(), PAUSE["sentence"]))

    return chunks if chunks else [(text, PAUSE["sentence"])]


# ══════════════════════════════════════════════════════════════════════════════
#  AUDIO POST-PROCESSOR
#  ► Applies subtle pitch / speed micro-variation to each chunk
#    so successive sentences don't sound like copy-paste
#  ► Adds natural silence gaps between chunks
# ══════════════════════════════════════════════════════════════════════════════

def make_silence(ms: int) -> AudioSegment:
    return AudioSegment.silent(duration=ms)


def humanise_segment(seg: AudioSegment, variation_seed: int) -> AudioSegment:
    """
    Apply tiny random speed micro-variation (±2%) and volume nudge (±0.5 dB)
    so each sentence sounds slightly different — like a human re-breathing.
    """
    rng = random.Random(variation_seed)

    # Speed micro-tweak: ±2%  (done via frame-rate trick — no pitch shift)
    speed_factor = 1.0 + rng.uniform(-0.02, 0.02)
    new_frame_rate = int(seg.frame_rate * speed_factor)
    seg_varied = seg._spawn(seg.raw_data, overrides={"frame_rate": new_frame_rate})
    seg_varied = seg_varied.set_frame_rate(seg.frame_rate)   # resample back

    # Volume micro-nudge: ±0.5 dB
    vol_nudge = rng.uniform(-0.5, 0.5)
    seg_varied = seg_varied + vol_nudge

    return seg_varied


async def generate_chunk(text: str, voice_name: str,
                          rate: str, pitch: str,
                          out_path: str):
    """Generate one audio chunk via edge-tts."""
    comm = edge_tts.Communicate(
        text=text,
        voice=voice_name,
        rate=rate,
        pitch=pitch,
    )
    await comm.save(out_path)


async def build_human_audio(
    text: str,
    voice_cfg: dict,
    output_mp3: str,
    mood: str = "normal",       # normal | excited | calm
    speed_preset: str = "normal"
) -> None:
    """
    Full pipeline:
      1. Split text into natural chunks
      2. Generate each chunk with edge-tts
      3. Humanise each segment
      4. Stitch with natural pauses
      5. Final EQ / normalise pass
    """

    # Speed modifier on top of voice default
    speed_table = {
        "slow":   -10,   # percentage points
        "normal":   0,
        "fast":   +12,
        "excited": +8,
        "calm":   -8,
    }
    speed_delta = speed_table.get(speed_preset, 0)
    base_rate_val = int(voice_cfg["rate"].replace("%", ""))
    final_rate_val = base_rate_val + speed_delta
    final_rate = f"{'+' if final_rate_val >= 0 else ''}{final_rate_val}%"

    # Mood pitch tweak
    mood_pitch = {
        "normal":  0,
        "excited": +20,
        "calm":   -15,
        "sad":    -25,
    }
    base_pitch_val = int(voice_cfg["pitch"].replace("Hz", ""))
    final_pitch_val = base_pitch_val + mood_pitch.get(mood, 0)
    final_pitch = f"{'+' if final_pitch_val >= 0 else ''}{final_pitch_val}Hz"

    print(f"\n🔧 Voice: {voice_cfg['label']}")
    print(f"   Rate={final_rate}  Pitch={final_pitch}  Mood={mood}")

    chunks = split_into_chunks(text)
    print(f"   Chunks: {len(chunks)} sentences detected\n")

    tmp_dir = tempfile.mkdtemp()
    segments = []

    try:
        for i, (chunk_text, pause_ms) in enumerate(chunks):
            print(f"   [{i+1}/{len(chunks)}] {chunk_text[:55]}{'...' if len(chunk_text)>55 else ''}")

            chunk_path = os.path.join(tmp_dir, f"chunk_{i:03d}.mp3")

            await generate_chunk(
                text=chunk_text,
                voice_name=voice_cfg["name"],
                rate=final_rate,
                pitch=final_pitch,
                out_path=chunk_path,
            )

            seg = AudioSegment.from_mp3(chunk_path)
            seg = humanise_segment(seg, variation_seed=i * 31 + 7)
            segments.append(seg)

            # Add natural silence gap after each sentence
            segments.append(make_silence(pause_ms))

    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    if not segments:
        raise RuntimeError("No audio generated — check internet connection.")

    # Stitch all segments
    print("\n🔨 Stitching audio...")
    combined = sum(segments)

    # Final loudness normalisation (make it sound like a real recording level)
    combined = pydub_effects.normalize(combined)

    # Export
    combined.export(output_mp3, format="mp3", bitrate="128k")
    size_kb = os.path.getsize(output_mp3) // 1024
    print(f"✅ Audio ready → {output_mp3}  ({size_kb} KB)")


# ══════════════════════════════════════════════════════════════════════════════
#  PLAYER
# ══════════════════════════════════════════════════════════════════════════════

def play_mp3(filepath: str):
    print("🔊 Playing...\n")
    pygame.mixer.init(frequency=44100, size=-16, channels=2, buffer=512)
    pygame.mixer.music.load(filepath)
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy():
        pygame.time.Clock().tick(20)
    pygame.mixer.quit()


# ══════════════════════════════════════════════════════════════════════════════
#  SAMPLE TEXTS  — colloquial Tamil slang people actually say
# ══════════════════════════════════════════════════════════════════════════════

SAMPLES = {
    "1": {
        "label": "Friends chatting (Casual slang)",
        "text":  "ஏய் மச்சி! என்னடா இவ்ளோ நேரம் ஆச்சு? நேத்து phone பண்ணே, எடுக்கவே இல்ல. சாப்பிட்டியா? "
                 "இல்லன்னா வா வெளியே போகலாம், ஏதாவது தின்னலாம்.",
    },
    "2": {
        "label": "Movie reaction (Excited)",
        "text":  "அடேய்! அந்த படம் பாத்தியா? Super-ஆ இருந்துச்சு! "
                 "Second half-ல ஒரு scene இருக்கு, அது பாத்தே மயிர் சிலிர்க்குது! "
                 "நீ பாக்கல ஆன்னா கண்டிப்பா போ.",
    },
    "3": {
        "label": "Argument / complaining",
        "text":  "போடா! நீ சொல்றது எல்லாம் பொய். ஒருத்தர கிட்டயும் நேர்மையா இல்ல. "
                 "எனக்கு உன்னை நம்பிக்கையே வரல. "
                 "ஒரு வேலையாவது சரியா பண்ண மாட்ட.",
    },
    "4": {
        "label": "Asking for a favour (Emotional)",
        "text":  "அண்ணா, ஒரு help பண்ணுவியா? "
                 "ரொம்ப urgent-ஆ இருக்கு. "
                 "நீ மட்டும் தான் help பண்ண முடியும். "
                 "Please-ஆ சொல்ற, வேற யார கிட்டயும் போகல.",
    },
    "5": {
        "label": "Food / hungry vibes",
        "text":  "அம்மா, வயிறு ரொம்ப பசிக்குது! "
                 "காலையில இருந்தே ஒன்னும் சாப்பிடல. "
                 "என்னாவது பண்ணி வையுங்க, please. "
                 "Biryani இருந்தா super!",
    },
    "6": {
        "label": "Phone call opening",
        "text":  "Hello? ஆமா சொல்லு. "
                 "என்ன விஷயம்? "
                 "இப்போ busy-ஆ இருக்கேன், ஆனா சொல்லு. "
                 "நேத்து call பண்ணினியா? எடுக்க முடியல, sorry.",
    },
    "7": {
        "label": "Custom — type your own",
        "text":  None,
    },
}

MOODS = {
    "1": "normal",
    "2": "excited",
    "3": "calm",
    "4": "sad",
}

SPEEDS = {
    "1": "slow",
    "2": "normal",
    "3": "fast",
}


# ══════════════════════════════════════════════════════════════════════════════
#  UI HELPERS
# ══════════════════════════════════════════════════════════════════════════════

BANNER = """
╔══════════════════════════════════════════════════════════════╗
║   🎙️  TAMIL TTS — REAL HUMAN VOICE FEEL  (v2)              ║
║       FREE · No API Key · Microsoft Neural + Audio FX       ║
╚══════════════════════════════════════════════════════════════╝"""


def ask(prompt, choices: dict, default=None):
    print()
    for k, v in choices.items():
        label = v if isinstance(v, str) else v.get("label", v)
        print(f"  [{k}] {label}")
    while True:
        val = input(f"\n{prompt}: ").strip()
        if not val and default:
            return default
        if val in choices:
            return val
        print(f"❌ Enter one of: {', '.join(choices.keys())}")


def pick_voice():
    print("\n─── VOICE ───────────────────────────────────────────")
    k = ask("Voice தேர்வு செய்யுங்க (1-4)", VOICES)
    return VOICES[k]


def pick_text():
    print("\n─── TEXT ────────────────────────────────────────────")
    for k, v in SAMPLES.items():
        print(f"  [{k}] {v['label']}")
    while True:
        k = input("\nText choice (1-7): ").strip()
        if k == "7":
            t = input("உங்க text type பண்ணுங்க:\n> ").strip()
            if t:
                return t
            print("❌ Empty, try again.")
        elif k in SAMPLES and SAMPLES[k]["text"]:
            return SAMPLES[k]["text"]
        else:
            print("❌ 1-7 enter பண்ணுங்க.")


def pick_mood():
    print("\n─── MOOD ────────────────────────────────────────────")
    mood_labels = {
        "1": "Normal (சாதாரண பேச்சு)",
        "2": "Excited (கொண்டாட்டம் / surprise)",
        "3": "Calm (அமைதி / formal)",
        "4": "Sad (வருத்தம் / emotional)",
    }
    k = ask("Mood (default=1 Normal)", mood_labels, default="1")
    return MOODS[k]


def pick_speed():
    print("\n─── SPEED ───────────────────────────────────────────")
    speed_labels = {
        "1": "Slow  (மெதுவா — தெளிவா புரியும்)",
        "2": "Normal (சாதாரண speed) ← default",
        "3": "Fast  (விரைவா — casual chat feel)",
    }
    k = ask("Speed (default=2 Normal)", speed_labels, default="2")
    return SPEEDS[k]


def ask_save(src_path: str):
    ans = input("\n💾 Audio save பண்ணணுமா? (y/n, default=n): ").strip().lower()
    if ans == "y":
        name = input("Filename (e.g. output.mp3): ").strip()
        if not name.endswith(".mp3"):
            name += ".mp3"
        shutil.copy(src_path, name)
        print(f"✅ Saved: {name}")


# ══════════════════════════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════════════════════════

def main():
    print(BANNER)
    print("\n💡 What makes this sound human:")
    print("   • Sentences split into natural breath-chunks")
    print("   • Micro speed/volume variation between sentences")
    print("   • Mood-based pitch control (excited / calm / sad)")
    print("   • Natural silence gaps after each sentence")
    print("   • Loudness normalised like a real recording\n")

    while True:
        voice_cfg  = pick_voice()
        text       = pick_text()
        mood       = pick_mood()
        speed      = pick_speed()

        print(f"\n📄 Text preview: {text[:80]}{'...' if len(text)>80 else ''}")

        out_mp3 = tempfile.mktemp(suffix=".mp3")

        try:
            asyncio.run(build_human_audio(
                text=text,
                voice_cfg=voice_cfg,
                output_mp3=out_mp3,
                mood=mood,
                speed_preset=speed,
            ))
            play_mp3(out_mp3)
        except Exception as e:
            print(f"\n❌ Error: {e}")
            print("💡 Check: (1) Internet connected? (2) ffmpeg installed?")
        finally:
            ask_save(out_mp3)
            try:
                os.unlink(out_mp3)
            except Exception:
                pass

        again = input("\n🔄 மீண்டும் try பண்ணணுமா? (y/n): ").strip().lower()
        if again != "y":
            print("\n👋 Bye! வாழ்க தமிழ்!")
            break


if __name__ == "__main__":
    main()
