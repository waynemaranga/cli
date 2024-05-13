import 'package:cli/client.dart' as client;
import 'package:cli/tui.dart' as tui;

void main() {
  client.ChatClient bot = client.ChatClient();
  // tui.TUI tui = ; //! erroneous: latter tui shadows former tui
  tui.TUI chatui = tui.TUI(bot);

  chatui.startChat();
}
