import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openai_suggestions/models/enums.dart';

const String OPENAI_API_KEY = ''; //provide your API key here.

class OpenAiHelper {
  final String _completetionApi = 'https://api.openai.com/v1/completions';

  final Map<Gpt3Model, String> _mapGpt3Models = <Gpt3Model, String>{
    Gpt3Model.textDaVinci: 'text-davinci-003',
    Gpt3Model.textCurie: 'text-curie-001',
    Gpt3Model.textBabbage: 'text-babbage-001',
    Gpt3Model.textAda: 'text-ada-001',
  };

  Future<dynamic> completeSearch(
    String query, {
    Gpt3Model engine = Gpt3Model.textDaVinci,
  }) async {
    final String? model = _mapGpt3Models[engine];

    final Map<String, dynamic> body = <String, dynamic>{
      'model': model,
      'prompt': query,
      'temperature': 1,
      'max_tokens': 200,
      'top_p': 0.2,
      'frequency_penalty': 2,
      'presence_penalty': 2
    };

    final http.Response response = await http.post(
      Uri.parse(_completetionApi),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $OPENAI_API_KEY',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw OpenAiCompletionException(response.body);
    }

    return json.decode(response.body);
  }
}

class OpenAiCompletionException implements Exception {
  const OpenAiCompletionException(this.message);

  final String message;

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}
