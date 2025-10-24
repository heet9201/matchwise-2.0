import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Advanced image caching service with memory and disk caching
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  late final CacheManager _cacheManager;
  bool _initialized = false;

  // Cache configuration
  static const int maxCacheObjects = 200;
  static const Duration cacheDuration = Duration(days: 30);
  static const Duration maxCacheDuration = Duration(days: 90);

  /// Initialize the cache manager
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final directory = await getTemporaryDirectory();

      _cacheManager = CacheManager(
        Config(
          'matchwise_image_cache',
          stalePeriod: cacheDuration,
          maxNrOfCacheObjects: maxCacheObjects,
          repo: JsonCacheInfoRepository(databaseName: 'matchwise_image_cache'),
          fileSystem: IOFileSystem(directory.path),
        ),
      );

      _initialized = true;
      debugPrint('ImageCacheService initialized');
    } catch (e) {
      debugPrint('ImageCacheService initialization error: $e');
      // Don't set _initialized to true if initialization failed
      rethrow;
    }
  }

  /// Get file from cache or download
  Future<File> getFile(String url) async {
    if (!_initialized) await initialize();

    try {
      final file = await _cacheManager.getSingleFile(url);
      return file;
    } catch (e) {
      debugPrint('Error loading image from cache: $e');
      rethrow;
    }
  }

  /// Get file stream (with progress)
  Stream<FileResponse> getFileStream(String url) {
    if (!_initialized) {
      return Stream.error('ImageCacheService not initialized');
    }
    return _cacheManager.getFileStream(url);
  }

  /// Preload images for faster access
  Future<void> preloadImages(List<String> urls) async {
    if (!_initialized) await initialize();

    await Future.wait(
      urls.map((url) async {
        try {
          await _cacheManager.downloadFile(url);
        } catch (e) {
          debugPrint('Error preloading image $url: $e');
        }
      }),
    );
  }

  /// Check if image is cached
  Future<bool> isCached(String url) async {
    if (!_initialized) await initialize();

    final fileInfo = await _cacheManager.getFileFromCache(url);
    return fileInfo != null;
  }

  /// Remove specific image from cache
  Future<void> removeImage(String url) async {
    if (!_initialized) await initialize();
    await _cacheManager.removeFile(url);
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    if (!_initialized) await initialize();
    await _cacheManager.emptyCache();
    debugPrint('Image cache cleared');
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    if (!_initialized) await initialize();

    int totalSize = 0;
    final directory = await getTemporaryDirectory();
    final cacheDir = Directory('${directory.path}/matchwise_image_cache');

    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    }

    return totalSize;
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!_initialized) await initialize();

    final size = await getCacheSize();
    final directory = await getTemporaryDirectory();
    final cacheDir = Directory('${directory.path}/matchwise_image_cache');

    int fileCount = 0;
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          fileCount++;
        }
      }
    }

    return {
      'totalSize': size,
      'totalSizeMB': (size / (1024 * 1024)).toStringAsFixed(2),
      'fileCount': fileCount,
      'maxFiles': maxCacheObjects,
      'cacheDuration': cacheDuration.inDays,
    };
  }

  /// Clean old cached files
  Future<void> cleanOldCache() async {
    if (!_initialized) await initialize();

    final directory = await getTemporaryDirectory();
    final cacheDir = Directory('${directory.path}/matchwise_image_cache');

    if (await cacheDir.exists()) {
      final now = DateTime.now();
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);

          if (age > maxCacheDuration) {
            try {
              await entity.delete();
              debugPrint('Deleted old cached file: ${entity.path}');
            } catch (e) {
              debugPrint('Error deleting cached file: $e');
            }
          }
        }
      }
    }
  }
}

/// Global instance
final imageCacheService = ImageCacheService();
