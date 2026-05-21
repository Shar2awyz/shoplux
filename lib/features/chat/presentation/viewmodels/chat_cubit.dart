import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/chat_message.dart';
import '../states/chat_state.dart';

const _model = 'llama-3.1-8b-instant';

const _systemPrompt = '''
You are Alex, a friendly and knowledgeable technical support specialist for ShopLux — a premium e-commerce mobile app.

Your responsibilities:
- Help customers with account issues: login problems, sign-up errors, password reset
- Assist with orders: tracking, cancellations, returns, and refunds
- Resolve payment issues: failed transactions, billing questions, promo codes
- Explain app features: cart, wishlist, product search, categories, profile settings
- Troubleshoot app bugs: crashes, loading errors, display issues
- Guide users through the app interface step-by-step when needed

Tone & style:
- Friendly, professional, and concise
- Use clear, simple language — avoid jargon
- If you cannot resolve an issue, ask for more details or suggest the user email support@shoplux.com
- Keep responses focused and under 150 words unless a detailed walkthrough is needed

Boundaries:
- Only answer questions related to ShopLux, online shopping, or e-commerce
- If asked something off-topic, politely redirect to ShopLux support topics
''';

class ChatCubit extends Cubit<ChatState> {
  final List<Map<String, String>> _history = [
    {'role': 'system', 'content': _systemPrompt},
  ];

  ChatCubit() : super(const ChatState()) {
    emit(state.copyWith(
      messages: [
        ChatMessage(
          text: "Hi! I'm Alex, your ShopLux support assistant. How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    ));
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _history.add({'role': 'user', 'content': trimmed});

    emit(state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: trimmed, isUser: true, timestamp: DateTime.now()),
      ],
      isLoading: true,
      clearError: true,
    ));

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${(dotenv.env['GROQ_API_KEY'] ?? '').trim()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': _history,
        }),
      );

      // ignore: avoid_print
      print('[ChatCubit] status=${response.statusCode}');
      // ignore: avoid_print
      print('[ChatCubit] body=${response.body}');

      if (response.statusCode == 200) {
        final reply = _parseReply(response.body);
        _history.add({'role': 'assistant', 'content': reply});

        emit(state.copyWith(
          messages: [
            ...state.messages,
            ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()),
          ],
          isLoading: false,
        ));
      } else {
        _history.removeLast();
        final errorMsg = _parseErrorMessage(response.body, response.statusCode);
        emit(state.copyWith(isLoading: false, error: errorMsg));
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ChatCubit] sendMessage error: $e');
      _history.removeLast();
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to send message. Check your connection.',
      ));
    }
  }

  String _parseReply(String body) {
    try {
      final data = jsonDecode(body);
      final choices = data['choices'];
      if (choices == null || choices is! List || choices.isEmpty) {
        throw Exception('choices is null or empty');
      }
      final message = choices[0]['message'];
      if (message == null || message is! Map) {
        throw Exception('message is null or not a map');
      }
      final content = message['content'];
      if (content == null || content is! String || content.trim().isEmpty) {
        return 'Sorry, I could not generate a response.';
      }
      return content.trim();
    } catch (e) {
      // ignore: avoid_print
      print('[ChatCubit] _parseReply error: $e | body=$body');
      return 'Sorry, I received an unexpected response. Please try again.';
    }
  }

  String _parseErrorMessage(String body, int statusCode) {
    try {
      final data = jsonDecode(body);
      final error = data['error'];
      if (error != null && error is Map) {
        final msg = error['message'];
        if (msg != null && msg is String && msg.isNotEmpty) {
          return 'Error $statusCode: $msg';
        }
      }
    } catch (_) {}
    return 'Request failed with status $statusCode.';
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
