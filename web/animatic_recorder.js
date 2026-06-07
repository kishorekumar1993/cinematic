// web/animatic_recorder.js

let animaticRecorder = null;
let animaticChunks = [];
let currentStream = null;

// ffmpeg.wasm globals (from ffmpeg.min.js)
const { createFFmpeg, fetchFile } = FFmpeg;
const ffmpeg = createFFmpeg({
  corePath: "https://unpkg.com/@ffmpeg/core@0.12.10/dist/ffmpeg-core.js",
});

let ffmpegLoaded = false;

function logMsg(msg) {
  console.log("[AnimaticRecorder]", msg);
}

async function ensureFFmpegLoaded() {
  if (!ffmpegLoaded) {
    logMsg("Loading ffmpeg.wasm...");
    await ffmpeg.load();
    ffmpegLoaded = true;
    logMsg("ffmpeg.wasm loaded");
  }
}

// 🔴 Start recording the tab / window (user chooses)
async function startAnimaticCapture() {
  logMsg("startAnimaticCapture called");
  animaticChunks = [];

  try {
    const stream = await navigator.mediaDevices.getDisplayMedia({
      video: { frameRate: 30 },
      audio: false, // set true if later you want audio
    });

    currentStream = stream;

    const options = { mimeType: "video/webm;codecs=vp9" };
    animaticRecorder = new MediaRecorder(stream, options);

    animaticRecorder.ondataavailable = (e) => {
      if (e.data && e.data.size > 0) {
        animaticChunks.push(e.data);
      }
    };

    animaticRecorder.onstop = () => {
      logMsg("Recorder stopped");

      if (currentStream) {
        currentStream.getTracks().forEach((t) => t.stop());
        currentStream = null;
      }

      if (animaticChunks.length === 0) {
        alert("⚠ Recording finished but no data captured.");
        return;
      }

      const fullBlob = new Blob(animaticChunks, { type: "video/webm" });
      // Process with ffmpeg.wasm (crop)
      cropCenterAndDownload(fullBlob).catch((err) => {
        console.error("ffmpeg crop error", err);
        alert("❌ Failed to crop video: " + err);
      });
    };

    animaticRecorder.start();
    logMsg("Recording started");
    alert(
      "🔴 Recording started.\n" +
        "Select this tab/window when prompted.\n" +
        "When you stop, it will crop the center and download."
    );
  } catch (e) {
    console.error("Screen capture error", e);
    alert("❌ Unable to start recording: " + e);
  }
}

// ⏹ Stop recording
function stopAnimaticCapture() {
  logMsg("stopAnimaticCapture called");
  if (animaticRecorder && animaticRecorder.state !== "inactive") {
    animaticRecorder.stop();
  } else {
    alert("⚠ No recording active.");
  }
}

// 🪚 Crop the center region (e.g. 1280x720) and download
async function cropCenterAndDownload(inputBlob) {
  await ensureFFmpegLoaded();

  // Write input file
  ffmpeg.FS("writeFile", "input.webm", await fetchFile(inputBlob));

  // 💡 CROP FILTER
  // Here we crop to 1280x720 at the center:
  //  crop=1280:720:(in_w-1280)/2:(in_h-720)/2
  //
  // Change 1280:720 if your cinematic frame size is different.
  const cropFilter = "crop=1280:720:(in_w-1280)/2:(in_h-720)/2";

  logMsg("Running ffmpeg crop filter: " + cropFilter);

  await ffmpeg.run(
    "-i",
    "input.webm",
    "-vf",
    cropFilter,
    "-c:a",
    "copy",
    "output.webm"
  );

  const data = ffmpeg.FS("readFile", "output.webm");
  const croppedBlob = new Blob([data.buffer], { type: "video/webm" });
  const url = URL.createObjectURL(croppedBlob);

  // Auto-download cropped video
  const a = document.createElement("a");
  a.href = url;
  a.download = "cinematic_frame_only.webm";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);

  URL.revokeObjectURL(url);

  // Optional: clean up ffmpeg FS
  try {
    ffmpeg.FS("unlink", "input.webm");
    ffmpeg.FS("unlink", "output.webm");
  } catch (e) {
    console.warn("FFmpeg unlink error", e);
  }

  alert("✅ Cropped video (frame only) downloaded!");
}

// Expose to Flutter
window.startAnimaticCapture = startAnimaticCapture;
window.stopAnimaticCapture = stopAnimaticCapture;

logMsg("animatic_recorder.js loaded (capture + crop mode)");

// // web/animatic_recorder.js

// let animaticRecorder = null;
// let animaticChunks = [];
// let currentStream = null;

// function logMsg(msg) {
//   console.log('[AnimaticRecorder]', msg);
// }

// // 🔴 Start screen recording
// async function startAnimaticCapture() {
//   logMsg('startAnimaticCapture called');

//   animaticChunks = [];

//   try {
//     const stream = await navigator.mediaDevices.getDisplayMedia({
//       video: { frameRate: 30 },
//       audio: false, // set true if later you want audio
//     });

//     currentStream = stream;

//     const options = { mimeType: 'video/webm;codecs=vp9' };
//     animaticRecorder = new MediaRecorder(stream, options);

//     animaticRecorder.ondataavailable = (e) => {
//       if (e.data && e.data.size > 0) {
//         animaticChunks.push(e.data);
//       }
//     };

//     animaticRecorder.onstop = () => {
//       logMsg('Recorder stopped');

//       // stop screen sharing
//       if (currentStream) {
//         currentStream.getTracks().forEach((t) => t.stop());
//         currentStream = null;
//       }

//       if (animaticChunks.length === 0) {
//         alert('⚠ Recording finished but no data captured.');
//         return;
//       }

//       const blob = new Blob(animaticChunks, { type: 'video/webm' });
//       const url = URL.createObjectURL(blob);

//       // 💾 auto-download
//       const a = document.createElement('a');
//       a.href = url;
//       a.download = 'cinematic_flutter_animatic.webm';
//       document.body.appendChild(a);
//       a.click();
//       document.body.removeChild(a);

//       URL.revokeObjectURL(url);

//       alert('✅ Recording finished and downloaded!');
//     };

//     animaticRecorder.start();
//     logMsg('Recording started');
//     alert(
//       '🔴 Recording started.\n' +
//       'When you stop, the video will be downloaded automatically.'
//     );
//   } catch (e) {
//     console.error('Screen capture error', e);
//     alert('❌ Unable to start recording: ' + e);
//   }
// }

// // ⏹ Stop recording
// function stopAnimaticCapture() {
//   logMsg('stopAnimaticCapture called');
//   if (animaticRecorder && animaticRecorder.state !== 'inactive') {
//     animaticRecorder.stop();
//   } else {
//     alert('⚠ No recording active.');
//   }
// }

// // Expose functions to Flutter
// window.startAnimaticCapture = startAnimaticCapture;
// window.stopAnimaticCapture = stopAnimaticCapture;

// logMsg('animatic_recorder.js loaded (auto-download mode)');
