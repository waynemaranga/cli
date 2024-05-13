import 'dart:io';

import 'package:cli/client.dart' as client;
import 'package:cli/tui.dart' as tui;
import 'package:cli/backend.dart' as backend;
import 'package:postgres/postgres.dart' as postgres;
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:path/path.dart' as path;

void main() async {
  await runApp();
}

Future<void> runApp() async {
  try {
    /// Instance of `Backend` to handle connection
    ///
    /// -- (link to commit and it's comments: __)
    backend.Backend metal = backend.Backend();

    /// ...check if `connection` was successful...
    /// -->
    /// `connection.isOpen` returns a `bool`
    /// ....
    if (metal.connection.isOpen) {
      /// Instances of the `TUI` and `ChatClient`
      client.ChatClient bot = client.ChatClient();
      tui.TUI chatui = tui.TUI(bot, metal);

      /// Check if `ADDCHAT.sql` exists and exec it
      final currentDir = Directory.current;
      final sqlFilePath = path.join(currentDir.path, 'lib/sql', 'ADDCHAT.sql');
      if (File(sqlFilePath).existsSync()) {
        await metal.connection.execute(File(sqlFilePath).readAsStringSync());
      }

      /// start the chat
      // await chatui.startChat(); //! FIXME: I swear this await will be the end of me
      chatui.startChat();
    } else {
      print("Failed to connect to database");
    }
  } catch (err) {
    print("An error occurred: $err");
  }
}
