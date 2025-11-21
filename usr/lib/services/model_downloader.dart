import 'package:flutter/material.dart';
import 'services/storage_service.dart';

class ModelDownloader {
  static Future<void> downloadModels() async {
    // Mock download with progress
    // In real implementation, download actual model files
    await StorageService.markTextModelDownloaded();
    await StorageService.markImageModelDownloaded();
  }
}
