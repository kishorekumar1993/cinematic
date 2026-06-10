"""
========================================================
  TAMIL TEXT TO SPEECH - NATURAL HUMAN VOICE
  Uses Microsoft Edge Neural TTS (FREE - No API Key!)
  Supports: Tamil, English, Mixed (Tanglish)
========================================================

INSTALL THESE FIRST:
    pip install edge-tts
    pip install pygame

HOW TO RUN:
    python tamil_tts.py

"""

import asyncio
import os
import sys
import tempfile

# ── Try importing required libraries ──────────────────────────────────────────
try:
    import edge_tts
except ImportError:
    print("❌ edge-tts not found. Installing...")
    os.system(f"{sys.executable} -m pip install edge-tts")
    import edge_tts

try:
    import pygame
except ImportError:
    print("❌ pygame not found. Installing...")
    os.system(f"{sys.executable} -m pip install pygame")
    import pygame


# ══════════════════════════════════════════════════════════════════════════════
#  VOICE OPTIONS - All FREE Microsoft Neural Voices
# ══════════════════════════════════════════════════════════════════════════════

VOICES = {
    "1": {
        "name": "ta-IN-PallaviNeural",
        "label": "Pallavi (Female - Natural Tamil)",
        "lang": "Tamil"
    },
    "2": {
        "name": "ta-IN-ValluvarNeural",
        "label": "Valluvar (Male - Natural Tamil)",
        "lang": "Tamil"
    },
    "3": {
        "name": "ta-LK-SaranyaNeural",
        "label": "Saranya (Female - Sri Lanka Tamil)",
        "lang": "Tamil"
    },
    "4": {
        "name": "ta-LK-KumarNeural",
        "label": "Kumar (Male - Sri Lanka Tamil)",
        "lang": "Tamil"
    },
    "5": {
        "name": "ta-MY-KaniNeural",
        "label": "Kani (Female - Malaysia Tamil)",
        "lang": "Tamil"
    },
    "6": {
        "name": "ta-MY-SuryaNeural",
        "label": "Surya (Male - Malaysia Tamil)",
        "lang": "Tamil"
    },
    "7": {
        "name": "ta-SG-VenbaNeural",
        "label": "Venba (Female - Singapore Tamil)",
        "lang": "Tamil"
    },
    "8": {
        "name": "ta-SG-AnbuNeural",
        "label": "Anbu (Male - Singapore Tamil)",
        "lang": "Tamil"
    },
}

# ── Sample slang/colloquial Tamil texts to test with ──────────────────────────
SAMPLE_TEXTS = {
    "1": "என்னடா, நீ எங்க போற? சாப்பிட்டியா? இல்லன்னா வா சாப்பிடலாம்.",
    "2": "ஏய் மச்சி, இன்னைக்கு ஆட்டம் பாக்கப் போறோம். வருவியா இல்லையா?",
    "3": "அடேய்! அந்த படம் மொத்தமா டப்பா, ஒரு காசுக்கும் உதவாது.",
    "4": "போடா! நீ சொல்றது எல்லாம் பொய். எனக்கு நம்பிக்கையே இல்ல.",
    "5": "சூப்பர் மச்சி! நீ சொன்னது ரொம்ப கரெக்ட். அவன் பாக்கைய தான்.",
    "6": "அம்மா, வயிறு ரொம்ப பசிக்குது. என்னாவது பண்ணி வையுங்க.",
    "7": "என்ன ஆச்சு? ஏன் இப்படி பண்ற? அப்படி பண்ணாதே.",
    "8": "Custom - நீயே type பண்ணு",
}


# ══════════════════════════════════════════════════════════════════════════════
#  CORE TTS FUNCTION
# ══════════════════════════════════════════════════════════════════════════════

async def text_to_speech(
    text: str,
    voice: str,
    output_file: str,
    rate: str = "+0%",
    pitch: str = "+0Hz",
    volume: str = "+0%"
):
    """Convert text to speech and save as MP3."""
    print(f"\n⏳ Generating speech...")
    communicate = edge_tts.Communicate(
        text=text,
        voice=voice,
        rate=rate,
        pitch=pitch,
        volume=volume
    )
    await communicate.save(output_file)
    print(f"✅ Audio saved → {output_file}")


def play_audio(filepath: str):
    """Play audio using pygame."""
    print("🔊 Playing audio...\n")
    pygame.mixer.init()
    pygame.mixer.music.load(filepath)
    pygame.mixer.music.play()

    # Wait until done
    while pygame.mixer.music.get_busy():
        pygame.time.Clock().tick(10)

    pygame.mixer.quit()


def print_banner():
    print("\n" + "═" * 55)
    print("   🎙️  TAMIL TEXT TO SPEECH - REAL HUMAN VOICE  🎙️")
    print("       Microsoft Edge Neural TTS (FREE)")
    print("═" * 55)


def choose_voice():
    print("\n📢 AVAILABLE VOICES:")
    print("-" * 40)
    for key, v in VOICES.items():
        print(f"  [{key}] {v['label']}")
    print("-" * 40)

    while True:
        choice = input("\nVoice எந்தது வேணும்? (1-8): ").strip()
        if choice in VOICES:
            selected = VOICES[choice]
            print(f"✅ Selected: {selected['label']}")
            return selected["name"]
        else:
            print("❌ Wrong choice. 1 to 8 வரை type பண்ணு.")


def choose_text():
    print("\n📝 SAMPLE TEXTS (Tamil Slang / Colloquial):")
    print("-" * 50)
    for key, text in SAMPLE_TEXTS.items():
        display = text[:45] + "..." if len(text) > 45 else text
        print(f"  [{key}] {display}")
    print("-" * 50)

    while True:
        choice = input("\nSample text choice (1-8): ").strip()
        if choice == "8":
            custom = input("உன் text type பண்ணு: ").strip()
            if custom:
                return custom
            else:
                print("❌ Empty. மீண்டும் try பண்ணு.")
        elif choice in SAMPLE_TEXTS:
            return SAMPLE_TEXTS[choice]
        else:
            print("❌ Wrong choice. 1 to 8 type பண்ணு.")


def choose_speed():
    print("\n⚡ SPEECH SPEED:")
    print("  [1] Slow    (-20%)")
    print("  [2] Normal  (+0%)   ← Default")
    print("  [3] Fast    (+20%)")
    print("  [4] Very Fast (+40%)")

    speeds = {
        "1": "-20%",
        "2": "+0%",
        "3": "+20%",
        "4": "+40%",
    }
    choice = input("\nSpeed choice (1-4, default 2): ").strip()
    return speeds.get(choice, "+0%")


def save_permanently(temp_path: str):
    """Ask user if they want to save the file permanently."""
    save = input("\n💾 இந்த audio save பண்ணணுமா? (y/n): ").strip().lower()
    if save == "y":
        save_path = input("File name (e.g. my_audio.mp3): ").strip()
        if not save_path.endswith(".mp3"):
            save_path += ".mp3"
        import shutil
        shutil.copy(temp_path, save_path)
        print(f"✅ Saved as: {save_path}")
    else:
        print("👍 OK, not saved.")


# ══════════════════════════════════════════════════════════════════════════════
#  MAIN PROGRAM
# ══════════════════════════════════════════════════════════════════════════════

def main():
    print_banner()

    while True:
        # Step 1: Choose voice
        voice = choose_voice()

        # Step 2: Choose or type text
        text = choose_text()
        print(f"\n📄 Text: {text}")

        # Step 3: Choose speed
        rate = choose_speed()

        # Step 4: Generate and play
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as tmp:
            tmp_path = tmp.name

        try:
            asyncio.run(text_to_speech(
                text=text,
                voice=voice,
                output_file=tmp_path,
                rate=rate,
            ))
            play_audio(tmp_path)
        except Exception as e:
            print(f"❌ Error: {e}")
            print("💡 Tip: Check internet connection. edge-tts needs internet.")
        finally:
            # Step 5: Save option
            save_permanently(tmp_path)
            try:
                os.unlink(tmp_path)
            except Exception:
                pass

        # Step 6: Continue or exit
        again = input("\n🔄 மீண்டும் try பண்ணணுமா? (y/n): ").strip().lower()
        if again != "y":
            print("\n👋 Bye! நன்றி!")
            break


if __name__ == "__main__":
    main()
