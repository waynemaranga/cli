// Terminal user interface
import 'dart:io';
import './client.dart';
import 'package:dart_console/dart_console.dart';

class TUI {
  final ChatClient bot;
  final Console console = Console();

  TUI(this.bot);

  void startChat() async {
    console.setForegroundColor(ConsoleColor
        .green); // styling can be done robustly in a separate module as long as arg/param & return types are consistent, and checked by tests
    console.writeLine('Chat with Elizabot:');
    console.resetColorAttributes();

    while (true) {
      console.setForegroundColor(ConsoleColor.blue);
      console.write('You: ');
      console.resetColorAttributes();
      String input = stdin.readLineSync()!;

      if (input.toLowerCase() == 'exit') {
        break;
      }

      // String response = bot.getResponse(input);
      // String response = bot.getResponse(input) as String; // type-casting, but wrong, doesn't work with Futures
      String response = await bot.getResponse(input);
      console.setForegroundColor(ConsoleColor.red);
      console.write('Bot: ');
      console.resetColorAttributes();
      console.writeLine(response);
    }

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
