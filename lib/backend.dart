/// backend.dart
/// Dart keywords: https://dart.dev/language/keywords

library backend;

import 'dart:convert'
    as convert; // https://dart.dev/libraries/dart-convert#decoding-and-encoding-json
import 'dart:io';
import 'package:postgres/postgres.dart'
    as postgres; // https://pub.dev/documentation/postgres/latest/
// import 'package:intl/intl.dart' show DateFormat; // TODO; usefor datetime stuff,
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:path/path.dart' as path;

/// ## `Message`
///
/// message object
class Message {
  final String user;
  final String content;
  DateTime timestamp; // TODO: implement intl date here, maybe

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
/// object for database storage
/// contains a start time, an end time and the conversation
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
  /// ... method to add messages to the message object (incorrect?)
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
      };
}

/// `Backend`
///
/// a backend to write to the database (and any other database)
///
/// try run in memory db from here, and python scripts
class Backend {
  late postgres.Connection _connection;

  /// a private named constructor
  ///
  /// Named Constructors: https://dart.dev/language/constructors#named-constructors
  Backend._() {
    _initConnection();
  }

  /// a `static` `final` field in this class, initialised by an instance of this
  /// class
  ///
  /// `static`: https://dart.dev/language/classes#static-variables
  ///
  /// `final`: https://dart.dev/language/variables#final-and-const
  static final Backend _instance = Backend._();

  /// a factory constructor
  /// https://dart.dev/language/constructors#factory-constructors
  factory Backend() {
    return _instance;
  }

  /// ## `_initConnection`
  ///
  /// load the env. vars from `.env`, connect to Postgres via endpoint
  /// create the table if it doesn't exist
  /// TODO: try intermediate Postgres stuff like server, ssl and multi-user
  /// TODO: try over network e.g NeonDB
  /// this method is asynchr. and returns a `Future<void>` asynchronously
  /// Futures: https://dart.dev/libraries/dart-async#future
  /// Async: https://dart.dev/language/async
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
      //? SQL queries must be read from files
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

  /// ## `connectionIsOpen`
  ///
  /// Futures: https://dart.dev/libraries/dart-async#future
  /// Returns a `Future<bool>` asynchronously...
  Future<bool> connectionIsOpen() async {
    await _initConnection(); // https://dart.dev/language/async
    return _connection.isOpen;
  }

  /// ## `executeSQLFile`
  ///
  /// finds file on os, executes Postgres-style, since `_connection` implements
  /// `execute`
  Future<void> executeSQLFile(String filePath) async {
    final currentDir = Directory.current;
    final sqlFilePath = path.join(currentDir.path, 'lib/sql', 'ADDCHAT.sql');
    if (File(sqlFilePath).existsSync()) {
      await _connection.execute(File(filePath).readAsStringSync());
    }
  }

  /// ## `storeConversation`
  ///
  /// Write to database by executing query on `_connection`
  Future<void> storeConversation(Conversation conversation) async {
    String messagesJSON = convert.jsonEncode(conversation.messages);
    String query =
        "INSERT INTO conversations (start_time, end_time, messages) VALUES (\$1, \$2, \$3)";
    await _connection.execute(query, parameters: [
      conversation.startTime.toIso8601String(), // Convert DateTime to string
      conversation.endTime.toIso8601String(), // Convert DateTime to string
      messagesJSON,
    ]);
  }
}
