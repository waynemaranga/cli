/// backend.dart

library backend;

import 'dart:convert'; // https://dart.dev/libraries/dart-convert#decoding-and-encoding-json
import 'package:postgres/postgres.dart'
    as postgres; // https://pub.dev/documentation/postgres/latest/
import 'package:intl/intl.dart'; // for datetime stuff

/// ## `Message`
///
/// a message class, let's hope this works
class Message {
  final String user;
  final String content;
  DateTime timestamp;

  Message({required this.user, required this.content})
      : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
        'user': user,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// ## `Conversation`
///
/// for database storage
class Conversation {
  final DateTime startTime;
  DateTime endTime;

  // final List<Map<String, String>> messages;
  // ---a List of Map objects containing String and String objects -- changed due to error
  final List<Map<String, String>> messages;
  // ---a List of Map objects containing String and dynamic objects

  Conversation({required this.startTime})
      : endTime = startTime, // init. endTime as startTime
        messages = []; // init. messages as an empty list

  /// ## `addMessage`
  ///
  /// ... method to add messages to the backend
  void addMessage(String user, String message) {
    messages.add({
      'user': user,
      'message': message,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  String toJson() => jsonEncode(this);
}

//// class Backend(){} // class declaration, needs a body
/// `Backend`
///
/// a backend to write to the database (and any other database)
///
/// try run in memory db from here, and python scripts
class Backend {
  final postgres.Connection connection;
  Backend(this.connection);

  /// ## `storeConversation`
  ///
  /// store the chat into the database(s) using SQL queries
  Future<void> storeConversation(Conversation conversation) async {
    String conversationJSON =
        conversation.toJson(); // convert the entire chat to a JSON object
    String query =
        "INSERT INTO conversations (start_time, end_time, messages) VALUES (@startTime, @endTime, @messages)";
    await connection.execute(query, parameters: {
      'startTime': conversation.startTime,
      'endTime': conversation.endTime,
      'messages': conversation.messages,
    });
  }
}
