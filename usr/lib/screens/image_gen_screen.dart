import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'services/storage_service.dart';
import 'package:workmanager/workmanager.dart';

class ImageGenScreen extends StatefulWidget {
  @override
  _ImageGenScreenState createState() => _ImageGenScreenState();
}

class _ImageGenScreenState extends State<ImageGenScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _generatedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLatestImage();
  }

  Future<void> _loadLatestImage() async {
    final images = await StorageService.getGeneratedImages();
    if (images.isNotEmpty) {
      setState(() {
        _generatedImagePath = images.last;
      });
    }
  }

  Future<void> _generateImage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    // Use WorkManager for background generation
    await Workmanager().registerOneOffTask(
      'imageGenTask',
      'imageGeneration',
      inputData: {'prompt': prompt},
    );

    // Simulate waiting for background task
    await Future.delayed(Duration(seconds: 2));
    await _loadLatestImage();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    await StorageService.clearImageHistory();
    setState(() {
      _generatedImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter image prompt',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _generateImage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text('Generate Image'),
            ),
            SizedBox(height: 16.0),
            if (_isLoading) CircularProgressIndicator(),
            if (_generatedImagePath != null)
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Image.file(File(_generatedImagePath!)),
                ),
              ),
            Spacer(),
            ElevatedButton(
              onPressed: _clearHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text('Clear Image History'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageInference {
  static Future<List<int>> generateImage(String prompt) async {
    // Mock image generation: create a random color image
    final random = Random();
    final image = img.Image(width: 256, height: 256);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final color = img.ColorRgb8(random.nextInt(256), random.nextInt(256), random.nextInt(256));
        image.setPixelRgb(x, y, color.r, color.g, color.b);
      }
    }
    return img.encodePng(image);
  }
}
