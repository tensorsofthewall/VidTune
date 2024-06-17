// class GeminiApiConstants{
//   static String mediaFileUploadURL = "https://generativelanguage.googleapis.com/upload/v1beta/files";
//   static String mediaFileMetadataURL = "https://generativelanguage.googleapis.com/v1beta/files";
//   static const String apiKey = String.fromEnvironment('API_KEY');
// }
const String mediaFileUploadURL = "https://generativelanguage.googleapis.com/upload/v1beta/files";
const String mediaFileMetadataURL = "https://generativelanguage.googleapis.com/v1beta/files";
const String modelInfoURL = "https://generativelanguage.googleapis.com/v1beta/models/";
const String apiKey = String.fromEnvironment('API_KEY');

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