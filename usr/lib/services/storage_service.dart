import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<String> get _textChatDir async {
    final dir = await getApplicationDocumentsDirectory();
    final chatDir = Directory('${dir.path}/text-chat');
    if (!await chatDir.exists()) {
      await chatDir.create(recursive: true);
    }
    return chatDir.path;
  }

  static Future<String> get _imageGenDir async {
    final dir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${dir.path}/generated-images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir.path;
  }

  static Future<String> get _textModelDir async {
    final dir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${dir.path}/text-model');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return modelDir.path;
  }

  static Future<String> get _imageModelDir async {
    final dir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${dir.path}/image-model');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return modelDir.path;
  }

  static Future<void> saveTextMessage(String userMessage, String aiResponse) async {
    final dir = await _textChatDir;
    final file = File('$dir/chat_log.json');
    List<Map<String, String>> messages = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      messages = List<Map<String, String>>.from(json.decode(content));
    }
    messages.add({'user': userMessage, 'ai': aiResponse});
    await file.writeAsString(json.encode(messages));
  }

  static Future<List<Map<String, String>>> loadTextMessages() async {
    final dir = await _textChatDir;
    final file = File('$dir/chat_log.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      return List<Map<String, String>>.from(json.decode(content));
    }
    return [];
  }

  static Future<void> clearTextChat() async {
    final dir = await _textChatDir;
    final chatDir = Directory(dir);
    if (await chatDir.exists()) {
      await chatDir.delete(recursive: true);
    }
  }

  static Future<void> saveGeneratedImage(List<int> imageBytes) async {
    final dir = await _imageGenDir;
    final fileName = 'generated_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$dir/$fileName');
    await file.writeAsBytes(imageBytes);
  }

  static Future<List<String>> getGeneratedImages() async {
    final dir = await _imageGenDir;
    final imageDir = Directory(dir);
    if (await imageDir.exists()) {
      return imageDir.listSync().map((e) => e.path).toList();
    }
    return [];
  }

  static Future<void> clearImageHistory() async {
    final dir = await _imageGenDir;
    final imageDir = Directory(dir);
    if (await imageDir.exists()) {
      await imageDir.delete(recursive: true);
    }
  }

  static Future<bool> isTextModelDownloaded() async {
    final dir = await _textModelDir;
    final modelFile = File('$dir/text_model.bin');
    return await modelFile.exists();
  }

  static Future<bool> isImageModelDownloaded() async {
    final dir = await _imageModelDir;
    final modelFile = File('$dir/image_model.bin');
    return await modelFile.exists();
  }

  static Future<void> markTextModelDownloaded() async {
    final dir = await _textModelDir;
    final modelFile = File('$dir/text_model.bin');
    await modelFile.writeAsString('mock text model');
  }

  static Future<void> markImageModelDownloaded() async {
    final dir = await _imageModelDir;
    final modelFile = File('$dir/image_model.bin');
    await modelFile.writeAsString('mock image model');
  }
}
