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
  final List<Message> messages; // now using a list of message objects.
  // -- the Message object is new as of this point in the code (poor commit etiquette 😛)

  Conversation({required this.startTime})
      : endTime = startTime, // init. endTime as startTime
        messages = []; // init. messages as an empty list

  /// ## `addMessage`
  ///
  /// ... method to add messages to the backend
  void addMessage(String user, String message) {
    messages.add(Message(user: user, content: message));
  }

  // String toJson() => jsonEncode(this); // moving away from this because toJson can't handle DateTime, only String
  //* better practice: implement error handling rather than rewrite half the fxckin module
  // ... and moving to this

  Map<String, dynamic> toJson() => {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'messages': messages.map((msg) => msg.toJson()).toList(),
        // 'messages': messages.map((e) => null) //? One of you (IT'S YOU) will surely betray me
      };
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
    // String conversationJSON = conversation.toJson(); // convert the entire chat to a JSON object // ... pivot
    String conversationJSON = jsonEncode(conversation);
    String query =
        "INSERT INTO conversations (start_time, end_time, messages) VALUES (@startTime, @endTime, @messages)";
    await connection.execute(query, parameters: {
      'startTime': conversation.startTime,
      'endTime': conversation.endTime,
      'messages': conversation.messages,
    });
  }
}
