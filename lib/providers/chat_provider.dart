import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';

class ChatProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  GeminiService? _geminiService;

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _apiKey;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get apiKey => _apiKey;
  bool get isApiKeySet => _apiKey != null && _apiKey!.isNotEmpty;

  ChatProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadApiKey();
    await _loadMessages();
  }

  Future<void> _loadApiKey() async {
    _apiKey = await _storageService.loadApiKey();
    if (_apiKey != null) {
      _geminiService = GeminiService(apiKey: _apiKey!);
    }
    notifyListeners();
  }

  Future<void> _loadMessages() async {
    _messages = await _storageService.loadMessages();
    notifyListeners();
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    _geminiService = GeminiService(apiKey: apiKey);
    await _storageService.saveApiKey(apiKey);
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (!isApiKeySet || _geminiService == null) {
      _error = 'Please set your Gemini API key first';
      notifyListeners();
      return;
    }

    if (content.trim().isEmpty) return;

    _error = null;

    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    notifyListeners();

    // Add loading message for AI response
    final loadingMessage = Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_loading',
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    _messages.add(loadingMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Get AI response
      final response = await _geminiService!.generateResponse(content);

      // Remove loading message and add actual response
      _messages.removeLast();

      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);

      // Save messages to storage
      await _storageService.saveMessages(_messages);

    } catch (e) {
      // Remove loading message
      _messages.removeLast();

      _error = e.toString();

      // Add error message
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    _messages.clear();
    await _storageService.clearMessages();
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    _apiKey = null;
    _geminiService = null;
    await _storageService.clearApiKey();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}