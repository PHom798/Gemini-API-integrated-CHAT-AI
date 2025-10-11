class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isLoading': isLoading,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isLoading: json['isLoading'] ?? false,
    );
  }
}