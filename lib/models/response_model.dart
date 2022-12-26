class ResponseModel {
  final int responseTimeMs;
  final String query;
  final String languageModel;
  final String choices;

  ResponseModel({
    required this.responseTimeMs,
    required this.query,
    required this.languageModel,
    required this.choices,
  });
}
