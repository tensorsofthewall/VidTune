/*
Constants required by the app
*/

// MusicGen Settings
const String musicGenUrl = 'http://10.147.17.252:8000/generate_music';

const String musicPromptExamples = '''
'A dynamic blend of hip-hop and orchestral elements, with sweeping strings and brass, evoking the vibrant energy of the city',
'Smooth jazz, with a saxophone solo, piano chords, and snare full drums',
'90s rock song with electric guitar and heavy drums'.
''';

// Gemini Settings
const String jsonSchemaForGemini = '''
{"Content Description": "string", "Music Prompt": "string"}
''';

const String systemInstructions = '''
You are a music supervisor who analyzes the content and tone of images and videos to describe music that fits well with the mood, evokes emotions, and enhances the narrative of the visuals. Given an image or video, describe the scene and generate a prompt suitable for music generation models. Use keywords related to genre, instruments, mood, context, and setting to craft a concise single-sentence prompt, like:

$musicPromptExamples
 
You must return your response using this JSON schema: $jsonSchemaForGemini.
''';

const String mllmPrompt = '''
Generate content description and music prompt for the given video.
''';

// Extension to Mime-Type links
const Map<String, String> extension2MimeType = {
  'png': 'image/png',
  'jpeg': 'image/jpeg',
  'jpg': 'image/jpeg',
  'webp': 'image/webp',
  'heic': 'image/heic',
  'heif': 'image/heif',
  'mp4': 'video/mp4',
  'mpeg': 'video/mpeg',
  'mov': 'video/mov',
  'avi': 'video/avi',
  'flv': 'video/x-flv',
  'mpg': 'video/mpg',
  'webm': 'video/webm',
  'wmv': 'video/wmv',
  '3gpp': 'video/3gpp'
};

// File-Type to Mime-Type links, useful for dynamic prompting.
const Map<String, Set<String>> type2MimeTypes = {
  'video': {
    'mp4', 
    'mpeg', 
    'mov', 
    'avi', 
    'x-flv', 
    'mpg', 
    'webm', 
    'wmv', 
    '3gpp'
  },
  'image': {
    'png',
    'jpeg',
    'jpg',
    'webp',
    'heic',
    'heif',
  }
};


// File size limit for In-line Gemini inference - 7MB
const int maxFileSizeInBytes = 7*1024*1024;