"""
╔══════════════════════════════════════════════════════════════════════════════╗
║   TAMIL TTS - REAL HUMAN VOICE FEEL  (v3 - FIXED SSML)                      ║
║       Now works with edge-tts properly                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

INSTALL:
    pip install edge-tts pydub pygame numpy
    # ffmpeg required (see previous instructions)
"""

import asyncio
import os
import sys
import tempfile
import random
import re
import shutil
import math

# Auto-install
def ensure(pkg, import_as=None):
    try:
        __import__(import_as or pkg)
    except ImportError:
        print(f"📦 Installing {pkg}...")
        os.system(f"{sys.executable} -m pip install {pkg} -q")

ensure("edge-tts", "edge_tts")
ensure("pydub")
ensure("pygame")
ensure("numpy")

import edge_tts
from pydub import AudioSegment
from pydub import effects as pydub_effects
import pygame
import numpy as np

# ======================================================================
#  VOICE PROFILES
# ======================================================================
VOICES = {
    "1": {
        "name":  "ta-IN-PallaviNeural",
        "label": "🌸 Pallavi  (Female · Chennai Tamil)",
        "rate":  "-8%",
        "pitch": "+10Hz",
    },
    "2": {
        "name":  "ta-IN-ValluvarNeural",
        "label": "🎙️ Valluvar (Male   · Chennai Tamil)",
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

# ======================================================================
#  HUMANISATION PARAMETERS
# ======================================================================
PAUSE_RANGE = {
    "comma":      (120, 250),
    "sentence":   (280, 550),
    "exclaim":    (250, 450),
    "question":   (300, 500),
    "paragraph":  (600, 900),
}
BREATH_PROBABILITY = 0.4
BREATH_DURATION_MS = 180
BREATH_VOLUME_DB = -28
FADE_IN_MS = 40
FADE_OUT_MS = 60
REVERB_STRENGTH = 0.08

def should_emphasize(word):
    return word.isupper() or len(word) >= 7

# ======================================================================
#  SSML GENERATION (corrected)
# ======================================================================
def create_ssml(text: str, voice_name: str, rate: str, pitch: str, question: bool = False) -> str:
    words = re.findall(r"\S+\s*", text)
    emphasized_words = []
    for w in words:
        clean_word = w.strip()
        if should_emphasize(clean_word):
            emphasized_words.append(f'<emphasis level="strong">{clean_word}</emphasis>')
        else:
            emphasized_words.append(clean_word)
    text_with_emphasis = "".join(emphasized_words)
    
    if question:
        prosody_attr = f'pitch="{pitch}" contour="(0%,0Hz)(80%,0Hz)(100%,+25Hz)"'
    else:
        prosody_attr = f'pitch="{pitch}"'
    
    ssml = f"""<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="ta-IN">
    <voice name="{voice_name}">
        <prosody rate="{rate}" {prosody_attr}>
            {text_with_emphasis}
        </prosody>
    </voice>
</speak>"""
    return ssml

def make_breath(duration_ms=BREATH_DURATION_MS, volume_db=BREATH_VOLUME_DB):
    samples = int(44100 * duration_ms / 1000)
    noise = np.random.normal(0, 1, samples)
    envelope = np.ones(samples)
    attack = int(0.05 * samples)
    decay = int(0.3 * samples)
    for i in range(attack):
        envelope[i] = (i / attack) ** 1.5
    for i in range(decay):
        envelope[samples - decay + i] = 1.0 - (i / decay) ** 1.2
    noise = noise * envelope
    max_amp = np.max(np.abs(noise))
    if max_amp > 0:
        noise = noise / max_amp
    linear_vol = 10 ** (volume_db / 20.0)
    noise = (noise * linear_vol * 32767).astype(np.int16)
    breath = AudioSegment(
        noise.tobytes(),
        frame_rate=44100,
        sample_width=2,
        channels=1
    )
    breath = breath.low_pass_filter(2000)
    return breath

def add_room_reverb(seg, strength=REVERB_STRENGTH):
    sr = seg.frame_rate
    impulse_len = int(0.12 * sr)
    impulse = np.zeros(impulse_len)
    decay_time = 0.05
    for i in range(impulse_len):
        impulse[i] = np.exp(-i / (decay_time * sr)) * random.uniform(-0.3, 0.3)
    impulse = impulse / np.sqrt(np.sum(impulse**2))
    impulse = (impulse * 32767).astype(np.int16)
    impulse_seg = AudioSegment(
        impulse.tobytes(),
        frame_rate=sr,
        sample_width=2,
        channels=1
    )
    wet = seg - 6
    wet = wet.low_pass_filter(3000)
    seg_with_reverb = seg.overlay(wet, position=25, loop=False)
    final = seg * (1 - strength) + seg_with_reverb * strength
    return final

def split_into_chunks(text: str):
    text = re.sub(r"\s+", " ", text).strip()
    parts = re.split(r"([.!?।])", text)
    chunks = []
    buf = ""
    for part in parts:
        part = part.strip()
        if not part:
            continue
        if part in (".", "।"):
            if buf:
                chunks.append((buf + ".", "sentence"))
                buf = ""
        elif part == "!":
            if buf:
                chunks.append((buf + "!", "exclaim"))
                buf = ""
        elif part == "?":
            if buf:
                chunks.append((buf + "?", "question"))
                buf = ""
        elif part == ",":
            buf += ","
            if len(buf) > 70:
                chunks.append((buf, "comma"))
                buf = ""
        else:
            buf += " " + part
            if len(buf) > 100:
                chunks.append((buf, "sentence"))
                buf = ""
    if buf:
        chunks.append((buf, "sentence"))
    merged = []
    i = 0
    while i < len(chunks):
        if i < len(chunks)-1 and len(chunks[i][0]) < 10:
            merged_chunk = chunks[i][0] + " " + chunks[i+1][0]
            pause_type = chunks[i+1][1]
            merged.append((merged_chunk, pause_type))
            i += 2
        else:
            merged.append(chunks[i])
            i += 1
    return merged if merged else [(text, "sentence")]

def humanise_segment(seg: AudioSegment, variation_seed: int) -> AudioSegment:
    rng = random.Random(variation_seed)
    speed_factor = 1.0 + rng.uniform(-0.02, 0.02)
    new_rate = int(seg.frame_rate * speed_factor)
    seg_varied = seg._spawn(seg.raw_data, overrides={"frame_rate": new_rate})
    seg_varied = seg_varied.set_frame_rate(seg.frame_rate)
    vol_nudge = rng.uniform(-0.8, 0.8)
    seg_varied = seg_varied + vol_nudge
    return seg_varied

# ======================================================================
#  FIXED: Use `text=` argument for SSML (not `ssml=`)
# ======================================================================
async def generate_chunk_ssml(text: str, voice_name: str, rate: str, pitch: str, out_path: str):
    is_question = "?" in text
    ssml_string = create_ssml(text, voice_name, rate, pitch, is_question)
    # CORRECT: edge_tts.Communicate takes text= (which can be plain text or SSML)
    comm = edge_tts.Communicate(text=ssml_string, voice=voice_name)
    await comm.save(out_path)

# ======================================================================
#  MAIN PIPELINE
# ======================================================================
async def build_human_audio(
    text: str,
    voice_cfg: dict,
    output_mp3: str,
    mood: str = "normal",
    speed_preset: str = "normal"
):
    speed_table = {"slow": -10, "normal": 0, "fast": +12, "excited": +8, "calm": -8}
    speed_delta = speed_table.get(speed_preset, 0)
    base_rate = int(voice_cfg["rate"].replace("%", ""))
    final_rate_val = base_rate + speed_delta
    final_rate = f"{'+' if final_rate_val >= 0 else ''}{final_rate_val}%"
    
    mood_pitch = {"normal": 0, "excited": +20, "calm": -15, "sad": -25}
    base_pitch = int(voice_cfg["pitch"].replace("Hz", ""))
    final_pitch_val = base_pitch + mood_pitch.get(mood, 0)
    final_pitch = f"{'+' if final_pitch_val >= 0 else ''}{final_pitch_val}Hz"
    
    print(f"\n🔧 Voice: {voice_cfg['label']}")
    print(f"   Rate={final_rate}  Pitch={final_pitch}  Mood={mood}")
    
    chunks = split_into_chunks(text)
    print(f"   Chunks: {len(chunks)} sentences detected\n")
    
    tmp_dir = tempfile.mkdtemp()
    segments = []
    
    try:
        for i, (chunk_text, pause_type) in enumerate(chunks):
            print(f"   [{i+1}/{len(chunks)}] {chunk_text[:55]}{'...' if len(chunk_text)>55 else ''}")
            chunk_path = os.path.join(tmp_dir, f"chunk_{i:03d}.mp3")
            
            await generate_chunk_ssml(
                text=chunk_text,
                voice_name=voice_cfg["name"],
                rate=final_rate,
                pitch=final_pitch,
                out_path=chunk_path,
            )
            
            seg = AudioSegment.from_mp3(chunk_path)
            seg = humanise_segment(seg, i * 31 + 7)
            seg = seg.fade_in(FADE_IN_MS).fade_out(FADE_OUT_MS)
            segments.append(seg)
            
            pause_range = PAUSE_RANGE.get(pause_type, PAUSE_RANGE["sentence"])
            pause_ms = random.randint(pause_range[0], pause_range[1])
            segments.append(AudioSegment.silent(duration=pause_ms))
            
            if i < len(chunks)-1 and random.random() < BREATH_PROBABILITY:
                breath = make_breath()
                segments.append(breath)
                segments.append(AudioSegment.silent(duration=random.randint(10, 30)))
        
        print("\n🔨 Stitching audio...")
        combined = sum(segments)
        combined = add_room_reverb(combined, strength=REVERB_STRENGTH)
        combined = pydub_effects.normalize(combined)
        combined.export(output_mp3, format="mp3", bitrate="128k")
        size_kb = os.path.getsize(output_mp3) // 1024
        print(f"✅ Audio ready → {output_mp3}  ({size_kb} KB)")
        
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

def play_mp3(filepath: str):
    print("\n🔊 Playing...")
    pygame.mixer.init(frequency=44100, size=-16, channels=2, buffer=512)
    pygame.mixer.music.load(filepath)
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy():
        pygame.time.Clock().tick(20)
    pygame.mixer.quit()

# ======================================================================
#  SAMPLE TEXTS
# ======================================================================
SAMPLES = {
    "1": {
        "label": "Friends chatting (Casual slang)",
        "text":  "ஏய் மச்சி! என்னடா இவ்ளோ நேரம் ஆச்சு? நேத்து phone பண்ணே, எடுக்கவே இல்ல. சாப்பிட்டியா? "
                 "இல்லன்னா வா வெளியே போகலாம், ஏதாவது தின்னலாம்.",
    },
    "2": {
        "label": "Movie reaction (Excited)",
        "text":  "அடேய்! அந்த படம் பாத்தியா? SUPER-ஆ இருந்துச்சு! "
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
        "text":  "அண்ணா, ஒரு HELP பண்ணுவியா? "
                 "ரொம்ப URGENT-ஆ இருக்கு. "
                 "நீ மட்டும் தான் HELP பண்ண முடியும். "
                 "PLEASE-ஆ சொல்ற, வேற யார கிட்டயும் போகல.",
    },
    "5": {
        "label": "Food / hungry vibes",
        "text":  "அம்மா, வயிறு ரொம்ப பசிக்குது! "
                 "காலையில இருந்தே ஒன்னும் சாப்பிடல. "
                 "என்னாவது பண்ணி வையுங்க, PLEASE. "
                 "BIRYANI இருந்தா SUPER!",
    },
    "6": {
        "label": "Phone call opening",
        "text":  "Hello? ஆமா சொல்லு. "
                 "என்ன விஷயம்? "
                 "இப்போ busy-ஆ இருக்கேன், ஆனா சொல்லு. "
                 "நேத்து CALL பண்ணினியா? எடுக்க முடியல, SORRY.",
    },
    "7": {
        "label": "Custom — type your own",
        "text":  None,
    },
}

MOODS = {"1": "normal", "2": "excited", "3": "calm", "4": "sad"}
SPEEDS = {"1": "slow", "2": "normal", "3": "fast"}

# ======================================================================
#  UI
# ======================================================================
BANNER = """
╔══════════════════════════════════════════════════════════════════════════════╗
║   🎙️  TAMIL TTS — HUMAN VOICE FEEL v3 (SSML FIXED)                         ║
╚══════════════════════════════════════════════════════════════════════════════╝"""

def ask(prompt, choices, default=None):
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
    return VOICES[ask("Voice (1-4)", VOICES)]

def pick_text():
    print("\n─── TEXT ────────────────────────────────────────────")
    for k, v in SAMPLES.items():
        print(f"  [{k}] {v['label']}")
    while True:
        k = input("\nText choice (1-7): ").strip()
        if k == "7":
            t = input("Type your Tamil text:\n> ").strip()
            if t:
                return t
            print("❌ Empty, try again.")
        elif k in SAMPLES and SAMPLES[k]["text"]:
            return SAMPLES[k]["text"]
        else:
            print("❌ Enter 1-7")

def pick_mood():
    print("\n─── MOOD ────────────────────────────────────────────")
    mood_labels = {"1": "Normal", "2": "Excited", "3": "Calm", "4": "Sad"}
    return MOODS[ask("Mood (default=1)", mood_labels, default="1")]

def pick_speed():
    print("\n─── SPEED ───────────────────────────────────────────")
    speed_labels = {"1": "Slow", "2": "Normal", "3": "Fast"}
    return SPEEDS[ask("Speed (default=2)", speed_labels, default="2")]

def ask_save(src_path: str):
    """Only save if the file exists."""
    if not os.path.exists(src_path):
        print("⚠️ No audio file to save (generation failed).")
        return
    ans = input("\n💾 Save audio file? (y/n, default=n): ").strip().lower()
    if ans == "y":
        name = input("Filename (e.g. output.mp3): ").strip()
        if not name.endswith(".mp3"):
            name += ".mp3"
        shutil.copy(src_path, name)
        print(f"✅ Saved: {name}")

# ======================================================================
#  MAIN LOOP with error handling
# ======================================================================
def main():
    print(BANNER)
    print("\n💡 Humanisation: word emphasis, breath sounds, variable pauses, reverb\n")
    
    while True:
        voice_cfg = pick_voice()
        text = pick_text()
        mood = pick_mood()
        speed = pick_speed()
        
        print(f"\n📄 Text preview: {text[:80]}{'...' if len(text)>80 else ''}")
        
        out_mp3 = tempfile.mktemp(suffix=".mp3")
        success = False
        try:
            asyncio.run(build_human_audio(
                text=text,
                voice_cfg=voice_cfg,
                output_mp3=out_mp3,
                mood=mood,
                speed_preset=speed,
            ))
            play_mp3(out_mp3)
            success = True
        except Exception as e:
            print(f"\n❌ Error: {e}")
            print("💡 Check internet connection and ffmpeg installation.")
        finally:
            if success:
                ask_save(out_mp3)
            try:
                if os.path.exists(out_mp3):
                    os.unlink(out_mp3)
            except:
                pass
        
        again = input("\n🔄 Try again? (y/n): ").strip().lower()
        if again != "y":
            print("\n👋 Bye! வாழ்க தமிழ்!")
            break

if __name__ == "__main__":
    main()