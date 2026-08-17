import 'package:flutter/material.dart';
import 'package:papersafe/core/services/ai_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final _controller = TextEditingController();
  final _aiService = AIService();
  final List<String> _messages = [];
  bool _isLoading = false;

  Future<void> _send() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _messages.add('You: $prompt');
      _isLoading = true;
    });
    try {
      final response = await _aiService.sendPrompt(prompt);
      setState(() {
        _messages.add('Gemini: $response');
      });
    } catch (e) {
      setState(() {
        _messages.add('Error: ${e.toString()}');
      });
    } finally {
      setState(() {
        _isLoading = false;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12.r),
              itemCount: _messages.length,
              itemBuilder: (context, index) => Text(_messages[index]),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask Gemini...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                SizedBox(width: 8.r),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
