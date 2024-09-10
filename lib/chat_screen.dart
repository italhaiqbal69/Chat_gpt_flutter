import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

import 'chat_const.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _openAi = OpenAI.instance.build(
      token: 'Api_key',
      baseOption: HttpSetup(receiveTimeout: Duration(seconds: 5)),
      enableLog: true);

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Talha', lastName: 'iqbal');
  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Chat', lastName: 'GPT');

  List<ChatMessage> _messages = <ChatMessage>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat gpt Ai'),
      ),
      body: DashChat(
          currentUser: _currentUser,
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
    });

    List<Map<String, dynamic>> _messageHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return {
          'role': 'user',
          'content': m.text,
        };
      } else {
        return {
          'role': 'assistant',
          'content': m.text,
        };
      }
    }).toList();

    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: _messageHistory,
      maxToken: 200,
    );

    final response = await _openAi.onChatCompletion(request: request);

    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: element.message!.content),
          );
        });
      }
    }

    // Additional code to handle the request (e.g., sending the request to the API)
  }

// Future<void> getChatResponse(ChatMessage m) async {
//   setState(() {
//     _messages.insert(0, m);
//   });
//   List<Messages> _messageHistory = _messages.reversed.map((m) {
//     if (m.user == _currentUser) {
//       return Messages(role: Role.user, content: m.text);
//     } else {
//       return Messages(role: Role.assistant, content: m.text);
//     }
//   }).toList();
//
//   final request = ChatCompleteText(
//       model: GptTurbo0301ChatModel(),
//       messages: _messageHistory,
//       maxToken: 200);
// }
}
