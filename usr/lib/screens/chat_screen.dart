import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/text_inference.dart';
import 'package:workmanager/workmanager.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await StorageService.loadTextMessages();
    setState(() {
      _messages = messages;
    });
  }

  Future<void> _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add({'user': prompt, 'ai': ''});
      _isLoading = true;
    });

    // Use WorkManager for background generation
    await Workmanager().registerOneOffTask(
      'textGenTask',
      'textGeneration',
      inputData: {'prompt': prompt},
    );

    // Simulate waiting for background task
    await Future.delayed(Duration(seconds: 2));
    await _loadMessages();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _clearChat() async {
    await StorageService.clearTextChat();
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User: ${message['user']}', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.0),
                        Text('AI: ${message['ai']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter prompt',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text('Send'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _clearChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text('Clear Chat Data'),
            ),
          ),
        ],
      ),
    );
  }
}
