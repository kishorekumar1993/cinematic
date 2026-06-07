/// Sample animatic archive JSON
/// 
const String sampleDUALArchiveJson = '''
{
  "id": "scene_dual_tamil_01",
  "title": "இரண்டு வாழ்க்கை ஸ்டைல்கள்",
  "subtitle": "ஒன்று உன்னை களைப்பாக ஆக்கும், மற்றொன்று உன்னை உயரம் எடுக்கும்",
  "body": "",
  "hook": "",
  "keyPoints": [],
  "imageUrl": "",
  "durationSeconds": 12,
  "effect": "dual_category",
  "transitionOut": "fade",
  "textEffect": "fade",
  "voiceTone": "Calm, serious Tamil narration",
  "musicStyle": "Soft ambient background",

  "leftTitle": "அழுத்தம் நிறைந்த நாள்",
  "leftSubtitle": "அநாவசிய வேலை, தூக்கமின்மை",
  "leftBody": "காலை 늦ாக எழுந்து, அவசரமாக ஓடி ஓடி வேலைக்கு போகும்.\nதலையில் லோட், மனசுல குழப்பம்.",
  "leftKeyPoints": [
    "போன் ஸ்க்ரோல் செய்து இரவு நேரம் வீணாக்குதல்",
    "காலை நேரத்தை ஒரு போதும் பயன்படுத்தாத பழக்கம்",
    "சரியான உணவு, உடற்பயிற்சி இல்லாத வாழ்க்கை"
  ],
  "leftImageUrl": "https://images.pexels.com/photos/374693/pexels-photo-374693.jpeg",

  "rightTitle": "சிஸ்டமாட்டிக் ப்ராடக்டிவ் நாள்",
  "rightSubtitle": "திட்டமிட்ட வேலை, அமைதியான மனம்",
  "rightBody": "காலை 5–6 மணிக்குள் எழுந்து, சில நிமிடம் அமைதியாக நீயே உன்னோட பேசும் நேரம்.\nதொடர்ந்து சிறு சிறு முன்னேற்றம்.",
  "rightKeyPoints": [
    "காலை ஒரு மணி நேரம் self-improvementக்கு",
    "ஒரு தினசரி to-do, 2–3 main tasks",
    "சிறு break, consistent routine, நல்ல தூக்கம்"
  ],
  "rightImageUrl": "https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg",

  "animationInstructions": "Show left side slightly darker, right side slightly brighter.",
  "closureLine": "இரண்டு பாதைகளும் உன் கையில் தான். இன்று நீ எந்த வாழ்க்கை ஸ்டைலைத் தேர்வு செய்கிறாய்?"
}
''';



/// 
const String sampleArchiveJson = '''
{
  "version": "1.0.0",
  "title": "Flutter kishore Basics Cinematic",
  "createdAt": "2025-12-05T10:00:00.000Z",
  "scenes": [
  
    {
      "id": "scene1",
      "title": "What is Flutter?",
      "subtitle": "Modern UI toolkit by Google",

           "body": "Flutter lets you build beautiful native apps for mobile, web, and desktop from a single codebase.",
      "imageUrl": "https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg",
       "keyPoints": [
    "Add AnimationController to StatefulWidget",
    "Define tweens inside initState()",
    "Wrap widget with AnimatedBuilder",
    "Dispose controller to avoid leaks"
  ],
      "durationSeconds": 8,
      "effect": "zoom_in",
      "transitionOut": "fade",
      "textEffect": "fade"
    },
    {
      "id": "scene2",
      "title": "Why use Flutter?",
      "subtitle": "Speed and beauty",
      "body": "Hot reload, expressive UI, and rich widget library make development faster and more fun.",
      "imageUrl": "https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg",
      "durationSeconds": 8,
      "effect": "pan_right",
      "transitionOut": "fade",
      "textEffect": "slide_up"
    },
    {
      "id": "scene3",
      "title": "One Codebase",
      "subtitle": "Ship everywhere",
      "body": "Write once and deploy to Android, iOS, Web, Windows, macOS, and Linux.",
      "imageUrl": "https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg",
      "durationSeconds": 10,
      "effect": "zoom_out",
      "transitionOut": "fade",
      "textEffect": "slide_left"
    }
  ]
}
''';



