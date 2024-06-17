//Google Generative Models Resource Format (REST)
class ModelResource {
  final String name;
  final String baseModelId;
  final String version;
  final String displayName;
  final String description;
  final int inputTokenLimit;
  final int outputTokenLimit;
  final List<String> supportedGenerationMethods;
  final double temperature;
  final double topP;
  final int topK;

  ModelResource({
    required this.name,
    required this.baseModelId,
    required this.version,
    required this.displayName,
    required this.description,
    required this.inputTokenLimit,
    required this.outputTokenLimit,
    required this.supportedGenerationMethods,
    required this.temperature,
    required this.topP,
    required this.topK,
  });

  // Factory constructor to create a ModelResource object from a JSON map
  factory ModelResource.fromJson(Map<String, dynamic> json) {
    return ModelResource(
      name: json['name'],
      baseModelId: json['baseModelId'] ?? '',
      version: json['version'],
      displayName: json['displayName'],
      description: json['description'],
      inputTokenLimit: json['inputTokenLimit'],
      outputTokenLimit: json['outputTokenLimit'],
      supportedGenerationMethods: List<String>.from(json['supportedGenerationMethods']),
      temperature: json['temperature']?.toDouble() ?? 0.0,
      topP: json['topP']?.toDouble() ?? 0.0,
      topK: json['topK'] ?? 0,
    );
  }

  // Method to convert a ModelResource object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseModelId': baseModelId,
      'version': version,
      'displayName': displayName,
      'description': description,
      'inputTokenLimit': inputTokenLimit,
      'outputTokenLimit': outputTokenLimit,
      'supportedGenerationMethods': supportedGenerationMethods,
      'temperature': temperature,
      'topP': topP,
      'topK': topK,
    };
  }

  // Factory constructor to create a list of ModelResource objects from a list of JSON maps
  static List<ModelResource> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ModelResource.fromJson(json)).toList();
  }

  // Method to convert a list of ModelResource objects to a list of JSON maps
  static List<Map<String, dynamic>> toJsonList(List<ModelResource> modelList) {
    return modelList.map((model) => model.toJson()).toList();
  }
}