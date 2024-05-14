import 'dart:io';

import 'package:cli/client.dart' as client;
import 'package:cli/tui.dart' as tui;
import 'package:cli/backend.dart' as backend;
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
    // if (metal.connection.isOpen) {
    // if (metal._connection != null && metal._connection.isOpen) {
    if (await metal.connectionIsOpen()) {
      /// Instances of the `TUI` and `ChatClient`
      client.ChatClient bot = client.ChatClient();
      tui.TUI chatui = tui.TUI(bot, metal);

      /// Check if `ADDCHAT.sql` exists and exec it
      final currentDir = Directory.current;
      final sqlFilePath = path.join(currentDir.path, 'lib/sql', 'ADDCHAT.sql');
      if (File(sqlFilePath).existsSync()) {
        await metal.executeSQLFile(sqlFilePath);
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
