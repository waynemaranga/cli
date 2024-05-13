/// Bot Client, with OpenAI
import 'dart:convert'; //https://api.dart.dev/stable/3.3.4/dart-convert/dart-convert-library.html

import 'package:dotenv/dotenv.dart'
    show
        DotEnv; //* consider using envied 🌐 https://pub.dev/documentation/envied/latest/#usage
import 'package:http/http.dart' as http;

// -- define request body, using classes and enums
// Classes: https://dart.dev/language#classes
// Enums: https://dart.dev/language#enums

/// Roles
enum Role { system, user, assistant }

const system = "system"; // unnecessary, just for kicks
const user = "user";
const assistant = "assistant";

/// Message object in the request body
class Message {
  /// Role should be an enum, or not
  final String role;
  final String content;

  Message({required this.role, required this.content});

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

class RequestBody {
  final String model;
  final List<Message> messages;

  RequestBody({required this.model, required this.messages});

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}

// -- define completion body
class Completion {}
// -- prompt input fn
// -- api call, for completion
// -- get response, parse & extract text
// -- return

Future<void> main() async {
  // -- get api keys
  DotEnv env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  // String geminiApiKey = env['GOOGLE_API_KEY']!;
  String openaiApiKey = env['OPENAI_API_KEY']!;
  // print(geminiApiKey + openaiApiKey);

  // -- build the request body
  final systemMessage =
      Message(role: system, content: "You are a very helpful assistant");
  final userMessage = Message(role: user, content: "Who are the Beastie Boys?");
  final request = RequestBody(
      model: "gpt-3.5-turbo", messages: [systemMessage, userMessage]);

  // print(request.toJson()); // test should check format of request body

  // -- API call https://platform.openai.com/docs/api-reference/making-requests
  // https://dart.dev/tutorials/server/fetch-data
  final url = Uri.parse("https://api.openai.com/v1/chat/completions");
  final headers = {
    'Content-type': 'application/json',
    'Authorization': 'Bearer $openaiApiKey'
  };

  final apiResponse = await http.post(url,
      headers: headers, body: jsonEncode(request.toJson()));

  if (apiResponse.statusCode == 200) {
    final data = jsonDecode(apiResponse.body);
    final completion = data['choices'][0]['message']['content'];
    print('Completion: $completion');
  } else {
    print('Request failed with status: ${apiResponse.statusCode}');
  }
}
