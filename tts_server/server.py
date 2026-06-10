from flask import Flask, request, send_file, jsonify
import edge_tts
import asyncio
import os
import uuid

app = Flask(__name__)

# Ensure a temp directory exists for audio files
TEMP_DIR = "temp_audio"
if not os.path.exists(TEMP_DIR):
    os.makedirs(TEMP_DIR)

async def generate_audio(text, voice, output_path):
    communicate = edge_tts.Communicate(text, voice)
    await communicate.save(output_path)

@app.route('/generate', methods=['POST'])
def generate_tts():
    try:
        data = request.json
        if not data or 'text' not in data:
            return jsonify({"error": "Missing 'text' parameter"}), 400

        text = data['text']
        # Default to a highly natural US English male voice often used in TikToks
        voice = data.get('voice', 'en-US-ChristopherNeural') 

        # Generate a unique filename
        filename = f"{uuid.uuid4()}.mp3"
        output_path = os.path.join(TEMP_DIR, filename)

        # Run the edge-tts async generation in the event loop
        asyncio.run(generate_audio(text, voice, output_path))

        # Return the generated file to the client
        return send_file(output_path, mimetype="audio/mpeg", as_attachment=True, download_name=filename)

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/cleanup', methods=['POST'])
def cleanup():
    # Optional endpoint to clean up old audio files
    try:
        for f in os.listdir(TEMP_DIR):
            os.remove(os.path.join(TEMP_DIR, f))
        return jsonify({"status": "cleaned"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Run the server on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, threaded=True)
