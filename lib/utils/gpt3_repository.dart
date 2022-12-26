import 'package:openai_suggestions/models/enums.dart';
import 'package:openai_suggestions/models/response_model.dart';
import 'package:openai_suggestions/utils/openai_helper.dart';

abstract class BaseGptRepository {
  Future<ResponseModel> getSuggestions(
    String decisionTitle,
    DecisionLevel decisionLevel, {
    Gpt3Model engine = Gpt3Model.textDaVinci,
  });
}

class Gpt3Repository extends BaseGptRepository {
  @override
  Future<ResponseModel> getSuggestions(
    String decisionTitle,
    DecisionLevel decisionLevel, {
    Gpt3Model engine = Gpt3Model.textDaVinci,
  }) async {
    final bool forChoice = decisionLevel == DecisionLevel.choices;
    final String query =
        'Suggest 9 ${forChoice ? 'options' : 'criteria'} for to be used in AHP"$decisionTitle with maximum 4 words for each suggestion"';

    final DateTime sentTime = DateTime.now();

    final dynamic resp = await OpenAiHelper().completeSearch(
      query,
      engine: engine,
    );

    final DateTime receivedTome = DateTime.now();
    final int respTime = receivedTome.difference(sentTime).inMilliseconds;
    return ResponseModel(
      responseTimeMs: respTime,
      query: query,
      languageModel: resp['model'],
      choices: (resp['choices'] as List<dynamic>)[0]['text'],
    );
  }
}
