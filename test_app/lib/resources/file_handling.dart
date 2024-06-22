import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:io';
import 'package:test_app/util/constants.dart' as app_constants;
import 'package:firebase_storage/firebase_storage.dart';


// Function for uploading media
Future<FileData> uploadMedia(PlatformFile file, Reference storage) async{
  final fileForFirebase = File(file.path??"");
  final fileRef = storage.child(file.name);

  final information = await FFprobeKit.getMediaInformation(file.path??"");
  final uploadTask = fileRef.putFile(
    fileForFirebase, 
    SettableMetadata(
      contentType: app_constants.extension2MimeType[file.path?.split(".").last],
      customMetadata:  {'videoDuration': (await information.getDuration()).toString()}
    ));

  uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
    switch(taskSnapshot.state) {
      case TaskState.running:
        // Task in Progress
        print("File upload progress: ${100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes)}");
      case TaskState.paused:
        // Task Paused
        print("File upload progress: ${100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes)}} (paused)");
      case TaskState.success:
        print("File uploaded to bucket.");
      case TaskState.canceled:
        print("File upload canceled.");
      case TaskState.error:
        print("File upload failed.");
    }
  });
  
  final snapshot = await uploadTask.whenComplete(() => null);
  final metadata = await snapshot.ref.getMetadata();
  final mimeType = metadata.contentType.toString();
  final bucket = fileRef.bucket;
  final fullPath = fileRef.fullPath;

  print("Metadata stuff: $mimeType, $bucket, $fullPath");

  final filePart = FileData(mimeType, 'gs://$bucket/$fullPath');
  return filePart;
}

Future<void> deleteAllMedia(Reference storage) async {
  final listResult = await storage.listAll();
  if (listResult.items.isNotEmpty) {
    for (var item in listResult.items) {
      print(item.name);
      await item.delete(); // Commented temporarily
    }
    print("All media has been deleted from Cloud.");
  } else {
    print("No media to delete from Cloud.");
  }
}