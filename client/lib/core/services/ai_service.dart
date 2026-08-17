import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final _storage = const FlutterSecureStorage();
  late final GenerativeModel _model;

  AIService() {
    _init();
  }

  Future<void> _init() async {
    // Retrieve API key from secure storage (must be set elsewhere)
    final apiKey = await _storage.read(key: 'gemini_api_key');
    if (apiKey == null) {
      throw Exception('Gemini API key not found in secure storage');
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Sends a user prompt to Gemini and returns the generated text.
  Future<String> sendPrompt(String prompt) async {
    // Ensure model is initialized
    if (_model == null) {
      await _init();
    }
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }
}
