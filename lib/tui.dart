// Terminal user interface
import 'dart:io';
import './client.dart';
import 'package:dart_console/dart_console.dart'; //🌐: https://pub.dev/documentation/console/latest/console/console-library.html
import 'package:cli/backend.dart';

/// ## Terminal User Interface
/// ... but at this point, still a CLI
class TUI {
  final ChatClient bot; // ...
  final Console console = Console(); // ...
  final Backend backend; // ...

  TUI(this.bot, this.backend);

  /// ## `startChat()`
  ///
  /// starts (and implements, really) the chat functionality
  ///
  /// TODO: move the styling to another library, after finalising types
  void startChat() async {
    console.setForegroundColor(ConsoleColor.green);
    console.writeLine('Chat with Elizabot:');
    console.resetColorAttributes();

    Conversation conversation = Conversation(startTime: DateTime.now());
    // ... start tracking the chat
    // ... endTime will be startTime at this point

    while (true) {
      console.setForegroundColor(ConsoleColor.blue);
      console.write('You: ');
      console.resetColorAttributes();
      String input = stdin.readLineSync()!;

      if (input.toLowerCase() == 'exit') {
        break;
      }

      conversation.addMessage('User', input); // ... adding to the chat object
      conversation.addMessage(
          'Bot', "First Response: 🩹 It's a patch"); // FIXME: terrible patch

      /// `response` is a subset/component/part of `completion`
      /// not to be confused with the HTTP/REST API `Response` type
      String response = await bot.getResponse(input);
      conversation.addMessage('Elizabot', response); // ... adding to the chat
      console.setForegroundColor(ConsoleColor.red);
      console.write('Bot: ');
      console.resetColorAttributes();
      console.writeLine(response);
    }

    conversation.endTime = DateTime.now(); // ... change end-time

    // -- storing the conversation (writing to db with the query)
    await backend.storeConversation(conversation);

    // -- all this styling can be one function
    console.setForegroundColor(ConsoleColor.yellow);
    console.writeLine('Exiting chat. Goodbye!');
    console.resetColorAttributes();
  }
}

// -- draw terminal
// -- terminal features
// -- handle keypress events
// -- text input and output
// -- styling

Future<void> main() async {}
