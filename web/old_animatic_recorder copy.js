// web/animatic_recorder.js

let animaticRecorder = null;
let animaticChunks = [];
let lastAnimaticBlob = null;
let lastAnimaticUrl = null;
let currentStream = null;

function logMsg(msg) {
  console.log('[AnimaticRecorder]', msg);
}

// 🔴 Start capturing the screen/tab where your Flutter app is shown
async function startAnimaticCapture() {
  logMsg('startAnimaticCapture() called');

  // Clear previous
  animaticChunks = [];
  lastAnimaticBlob = null;
  if (lastAnimaticUrl) {
    URL.revokeObjectURL(lastAnimaticUrl);
    lastAnimaticUrl = null;
  }

  try {
    // Ask user which screen / window / tab to share
    const stream = await navigator.mediaDevices.getDisplayMedia({
      video: { frameRate: 30 },
      audio: false, // set to true if you also want system audio (browser support varies)
    });

    currentStream = stream;

    // Setup MediaRecorder on that stream
    const options = { mimeType: 'video/webm;codecs=vp9' };
    animaticRecorder = new MediaRecorder(stream, options);

    animaticRecorder.ondataavailable = (e) => {
      if (e.data && e.data.size > 0) {
        animaticChunks.push(e.data);
      }
    };

    animaticRecorder.onstop = () => {
      logMsg('Recorder onstop fired');

      // Stop all the tracks to stop screen sharing
      if (currentStream) {
        currentStream.getTracks().forEach((t) => t.stop());
        currentStream = null;
      }

      if (animaticChunks.length === 0) {
        console.warn('No chunks recorded');
        alert('⚠ Recording stopped, but no data captured.');
        return;
      }

      lastAnimaticBlob = new Blob(animaticChunks, { type: 'video/webm' });
      lastAnimaticUrl = URL.createObjectURL(lastAnimaticBlob);

      alert('✅ Recording finished!\nUse "Open Last Video" or "Download Last Video".');
    };

    animaticRecorder.start();
    logMsg('Recording started');
    alert(
      '🔴 Screen recording started.\n' +
      'Make sure you selected this tab/window.\n' +
      'Use "Stop Recording" or stop sharing to finish.'
    );
  } catch (e) {
    console.error('Error starting screen capture', e);
    alert('❌ Could not start screen recording:\n' + e);
  }
}

// ⏹ Stop recording (we keep the last video in memory)
function stopAnimaticCapture() {
  logMsg('stopAnimaticCapture() called');
  if (animaticRecorder && animaticRecorder.state !== 'inactive') {
    animaticRecorder.stop();
    logMsg('Recorder.stop() called');
  } else {
    console.warn('No active animatic recorder to stop');
    alert('⚠ No active recording to stop.');
  }
}

// ▶ Open the last recorded video in new tab (preview / load)
function openLastAnimatic() {
  logMsg('openLastAnimatic() called');
  if (!lastAnimaticUrl) {
    alert('❌ No recorded video found yet.\nPlease record first.');
    return;
  }
  window.open(lastAnimaticUrl, '_blank');
}

// 💾 Download the last recorded video
function downloadLastAnimatic() {
  logMsg('downloadLastAnimatic() called');
  if (!lastAnimaticBlob) {
    alert('❌ No recorded video found yet.\nPlease record first.');
    return;
  }

  const url = lastAnimaticUrl || URL.createObjectURL(lastAnimaticBlob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'cinematic_flutter_animatic.webm';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

function hasLastAnimatic() {
  return !!lastAnimaticBlob;
}

// Expose functions to Dart
window.startAnimaticCapture = startAnimaticCapture;
window.stopAnimaticCapture = stopAnimaticCapture;
window.openLastAnimatic = openLastAnimatic;
window.downloadLastAnimatic = downloadLastAnimatic;
window.hasLastAnimatic = hasLastAnimatic;

logMsg('animatic_recorder.js loaded (screen capture mode)');
