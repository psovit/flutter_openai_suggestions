import 'package:flutter/material.dart';
import 'package:openai_suggestions/models/enums.dart';

import 'package:openai_suggestions/models/response_model.dart';
import 'package:openai_suggestions/utils/gpt3_repository.dart';
import 'package:openai_suggestions/utils/openai_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open AI Suggestions',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _textEditingController;
  final ValueNotifier<List<ResponseModel>> _responsesNotifier =
      ValueNotifier(<ResponseModel>[]);
  bool _forCriteria = false;
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open AI Suggestions'),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter prompt for Decision'),
              TextField(
                controller: _textEditingController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Text('For Criteria?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                    value: _forCriteria,
                    onChanged: ((value) => setState(() {
                          _forCriteria = !_forCriteria;
                        })),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_textEditingController.text.isEmpty) {
                        return;
                      }
                      try {
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Getting Prompts...')),
                        );

                        final DecisionLevel dl = _forCriteria
                            ? DecisionLevel.criteria
                            : DecisionLevel.choices;
                        final String title = _textEditingController.text;
                        final List<ResponseModel> responses = <ResponseModel>[];

                        await Future.forEach(Gpt3Model.values, (model) async {
                          final ResponseModel resp =
                              await Gpt3Repository().getSuggestions(
                            title,
                            dl,
                            engine: model,
                          );

                          responses.add(resp);
                        });
                        _responsesNotifier.value = responses;
                      } on OpenAiCompletionException catch (err) {
                        print(err);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err.message)),
                        );
                      }
                    },
                    child: const Text('Get Suggestions'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder(
                valueListenable: _responsesNotifier,
                builder: (BuildContext ctxt, List<ResponseModel> responses,
                    Widget? child) {
                  if (responses.isEmpty) {
                    return const SizedBox();
                  }
                  return Column(
                    children: List.generate(responses.length, (index) {
                      final ResponseModel resp = responses[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.amberAccent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Model Used: ${resp.languageModel}'),
                            Text('Query: ${resp.query}'),
                            Text(
                              'Response Time (milliseconds): ${resp.responseTimeMs}',
                            ),
                            Text('Response Choices: ${resp.choices}'),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
