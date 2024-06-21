//Google FILE Resource (REST)
class FileResource {
  final String? name;
  final String? displayName;
  final String? mimeType;
  final String? sizeBytes;
  final String? createTime;
  final String? updateTime;
  final String? expirationTime;
  final String? sha256Hash;
  final String? uri;
  final State? state;
  final Status? error;
  final VideoMetadata? videoMetadata;

  FileResource({
    this.name,
    this.displayName,
    this.mimeType,
    this.sizeBytes,
    this.createTime,
    this.updateTime,
    this.expirationTime,
    this.sha256Hash,
    this.uri,
    this.state,
    this.error,
    this.videoMetadata,
  });

  factory FileResource.fromJson(Map<String, dynamic> json) {
    return FileResource(
      name: json['name'],
      displayName: json['displayName']??"",
      mimeType: json['mimeType'],
      sizeBytes: json['sizeBytes'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      expirationTime: json['expirationTime'],
      sha256Hash: json['sha256Hash'],
      uri: json['uri'],
      state: State.values.firstWhere((e) => e.toString().split('.').last == json['state']),
      error: json['error'] != null ? Status.fromJson(json['error']) : null,
      videoMetadata: json['videoMetadata'] != null ? VideoMetadata.fromJson(json['videoMetadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'createTime': createTime,
      'updateTime': updateTime,
      'expirationTime': expirationTime,
      'sha256Hash': sha256Hash,
      'uri': uri,
      'state': state.toString().split('.').last,
      'error': error?.toJson(),
      'videoMetadata': videoMetadata?.toJson(),
    };
  }

  static List<FileResource> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FileResource.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<FileResource> modelList) {
    return modelList.map((model) => model.toJson()).toList();
  }
}


//File State
enum State { STATE_UNSPECIFIED, PROCESSING, ACTIVE, FAILED }

// Status Object
class Status {
  final int code;
  final String message;
  final List<Detail> details;

  Status({
    required this.code,
    required this.message,
    required this.details,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      code: json['code'],
      message: json['message'],
      details: (json['details'] as List<dynamic>)
          .map((detailJson) => Detail.fromJson(detailJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}

//Class for handling Detail
class Detail {
  final String type;
  final Map<String, dynamic> additionalFields;

  Detail({
    required this.type,
    required this.additionalFields,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    final type = json['@type'];
    final additionalFields = Map<String, dynamic>.from(json)
      ..remove('@type');
    return Detail(
      type: type,
      additionalFields: additionalFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      ...additionalFields,
    };
  }
}

//Class for handling VideoMetadata
class VideoMetadata {
  final double videoDuration;

  VideoMetadata({
    required this.videoDuration,
  });

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      videoDuration: json['videoDuration']?..toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': videoDuration,
    };
  }
}