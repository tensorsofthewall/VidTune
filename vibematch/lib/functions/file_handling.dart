// General file handling methods (File select, upload, delete)
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:io' show File;
import 'package:vibematch/assets/constants.dart' as app_constants;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' show basename;

// Method to select files
Future<PlatformFile?> selectFile() async {
  PlatformFile? inputFile;
  do {
    FilePickerResult? selected = await FilePicker.platform.pickFiles(type: FileType.video, allowedExtensions: null, allowMultiple: false, allowCompression: true);

    if (selected == null) return null ;
    inputFile = selected.files.first;
  } while(!app_constants.extension2MimeType.containsKey(inputFile.path?.split(".").last));
  return inputFile;
}

// Method to upload media to Firebase storage
Future<FileData> uploadMedia(String filePath, Reference storage) async{
  final fileForFirebase = File(filePath);
  final fileRef = storage.child(basename(filePath));

  final information = await FFprobeKit.getMediaInformation(filePath);
  final uploadTask = fileRef.putFile(
    fileForFirebase, 
    SettableMetadata(
      contentType: app_constants.extension2MimeType[filePath.split(".").last],
      customMetadata:  {'videoDuration': (await information.getDuration()).toString()}
    ));

  uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
    switch(taskSnapshot.state) {
      case TaskState.running:
        // Task in Progress
        // print("File upload progress: ${100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes)}");
      case TaskState.paused:
        // Task Paused
        // print("File upload progress: ${100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes)}} (paused)");
      case TaskState.success:
        // print("File uploaded to bucket.");
      case TaskState.canceled:
        // print("File upload canceled.");
      case TaskState.error:
        // print("File upload failed.");
    }
  });
  
  final snapshot = await uploadTask.whenComplete(() => null);
  final metadata = await snapshot.ref.getMetadata();
  final mimeType = metadata.contentType.toString();
  final bucket = fileRef.bucket;
  final fullPath = fileRef.fullPath;

  // print("Metadata stuff: $mimeType, $bucket, $fullPath");

  final filePart = FileData(mimeType, 'gs://$bucket/$fullPath');
  return filePart;
}

// Method to delete all media in Firebase storage bucket
Future<void> deleteAllMedia(Reference storage) async {
  final listResult = await storage.listAll();
  if (listResult.items.isNotEmpty) {
    for (var item in listResult.items) {
      // print(item.name);
      await item.delete(); // Commented temporarily
    }
    // print("All media has been deleted from Cloud.");
  } 
  // else {
  //   print("No media to delete from Cloud.");
  // }
}