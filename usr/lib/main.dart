import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'screens/chat_screen.dart';
import 'screens/image_gen_screen.dart';
import 'services/model_downloader.dart';
import 'services/storage_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'textGeneration':
        final prompt = inputData!['prompt'] as String;
        // Mock text generation
        final response = 'AI Response to: $prompt';
        await StorageService.saveTextMessage(prompt, response);
        break;
      case 'imageGeneration':
        final prompt = inputData!['prompt'] as String;
        // Mock image generation - create a random color image
        final imageBytes = await ImageInference.generateImage(prompt);
        await StorageService.saveGeneratedImage(imageBytes);
        break;
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  if (isFirstLaunch) {
    await ModelDownloader.downloadModels();
    await prefs.setBool('isFirstLaunch', false);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _screens = [
    ChatScreen(),
    ImageGenScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Text Chat' : 'Image Generation'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Text Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Image Gen',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
