import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  static const String _messagesKey = 'chat_messages';
  static const String _apiKeyKey = 'gemini_api_key';

  // Save messages to local storage
  Future<void> saveMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((message) => message.toJson()).toList();
      await prefs.setString(_messagesKey, jsonEncode(messagesJson));
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  // Load messages from local storage
  Future<List<Message>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString(_messagesKey);

      if (messagesString != null) {
        final messagesJson = jsonDecode(messagesString) as List;
        return messagesJson
            .map((json) => Message.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
    return [];
  }

  // Save API key
  Future<void> saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyKey, apiKey);
    } catch (e) {
      print('Error saving API key: $e');
    }
  }

  // Load API key
  Future<String?> loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiKeyKey);
    } catch (e) {
      print('Error loading API key: $e');
      return null;
    }
  }

  // Clear all messages
  Future<void> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
    } catch (e) {
      print('Error clearing messages: $e');
    }
  }

  // Clear API key
  Future<void> clearApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyKey);
    } catch (e) {
      print('Error clearing API key: $e');
    }
  }
}