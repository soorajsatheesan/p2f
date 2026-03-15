enum ChatRole {
  user,
  assistant;

  static ChatRole fromStorage(String value) {
    return ChatRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => ChatRole.assistant,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final ChatRole role;
  final String text;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'role': role.name,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: ChatRole.fromStorage(json['role'] as String? ?? 'assistant'),
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
