/// backend.dart

library backend;

import 'dart:convert'
    as convert; // https://dart.dev/libraries/dart-convert#decoding-and-encoding-json
import 'dart:io';
import 'package:postgres/postgres.dart'
    as postgres; // https://pub.dev/documentation/postgres/latest/
import 'package:intl/intl.dart'; // for datetime stuff
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:path/path.dart' as path;

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
  // final postgres.Connection connection; // connection cannot be used as a setter if it's final
  late postgres.Connection _connection;
  // marked as late because this non-nullable needs to blah-blah-blah
  // -- options were: (1) mark as late 🩹 (2) initialise connection with a placeholder 🚫 (3) use a factory constructor ⌛
  // probably not going to use a placeholder

  // Backend(this.connection); // using a constructor now (I think?)
  // Backend._();

  Backend._() {
    // _connectToDatabase();
    _initConnection();
  }

  static final Backend _instance = Backend._();

  // factory Backend() {
  //   // _instance._connectToDatabase(); //?
  //   _instance._init(); //?
  //   return _instance;
  // }
  factory Backend() {
    // _instance._connectToDatabase();
    return _instance;
  }

  // Future<void> _init() async {
  //   // await ensureTableExists();
  //   await _connectToDatabase();
  //   // await ensureTableExists();
  // }

  /// ## `_connectToDatabase`
  ///
  /// refactoring; better idea to connect to db in the backend module
  ///
  ///
  // Future<void> _connectToDatabase() async {
  Future<void> _initConnection() async {
    dotenv.DotEnv env = dotenv.DotEnv(includePlatformEnvironment: true);
    env.load(['.env']);

    /// `env. vars.`
    String? postgresUsername = env['POSTGRES_USERNAME'] as String;
    String? postgresDatabase = env['POSTGRES_DATABASE'] as String;
    String? postgresHost = env['POSTGRES_HOST'] as String; // probably localhost
    // int? postgresPort = env['POSTGRES_PORT'] as int; // probably 5432
    // int postgresPort = int.parse(dotenv.env['POSTGRES_PORT']!);// probably 5432
    int postgresPort = 5432;
    String? postgressPassword = env['POSTGRES_PASSWORD'] as String;

    /// ## `endpoint`
    ///
    /// 🌐: https://stablekernel.com/article/binding-rest-interface-postgres-dart/
    /// 🌐: https://pub.dev/documentation/postgres/latest/postgres/Endpoint-class.html
    final endpoint = postgres.Endpoint(
      host: postgresHost,
      port: postgresPort,
      database: postgresDatabase,
      username: postgresUsername,
      password: postgressPassword,
    ); // ... creating an endpoint

    try {
      _connection = await postgres.Connection.open(endpoint);
      String query = '''
      CREATE TABLE IF NOT EXISTS conversations (
        id SERIAL PRIMARY KEY,
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP NOT NULL,
        messages JSONB NOT NULL
      );
      ''';
      await _connection.execute(query);
    } on postgres.PgException catch (err) {
      print("Error connecting to the database: $err");
      rethrow;
    }
  }

  Future<bool> connectionIsOpen() async {
    await _initConnection();
    return _connection.isOpen;
  }

  Future<void> executeSQLFile(String filePath) async {
    final currentDir = Directory.current;
    final sqlFilePath = path.join(currentDir.path, 'lib/sql', 'ADDCHAT.sql');
    if (File(sqlFilePath).existsSync()) {
      await _connection.execute(File(filePath).readAsStringSync());
    }
  }

  /// ## `storeConversation`
  ///
  /// store the chat into the database(s) using SQL queries
  Future<void> storeConversation(Conversation conversation) async {
    // await _initConnection(); // Retry initialization

    String conversationJSON = convert.jsonEncode(conversation);
    String query =
        "INSERT INTO conversations (start_time, end_time, messages) VALUES (@startTime, @endTime, @messages)";
    await _connection.execute(query, parameters: {
      'startTime': conversation.startTime,
      'endTime': conversation.endTime,
      'messages': conversation.messages,
    });
  }

  /// ## `ifNotExists`
  ///
  /// should not be here 🩹
  //
  // Future<void> ensureTableExists() async {
  //   if (_connection.isOpen) {
  //     String query = '''
  //   CREATE TABLE IF NOT EXISTS conversations (
  //     id SERIAL PRIMARY KEY,
  //     start_time TIMESTAMP NOT NULL,
  //     end_time TIMESTAMP NOT NULL,
  //     messages JSONB NOT NULL
  //   );
  //   ''';
  //     await _connection.execute(query);
  //   } else {
  //     print("Error: Database connection is not open");
  //   }
  // }
}
