import 'dart:collection';
import 'package:flutter/material.dart';

/// Memory-efficient caching service for comparison cards
class CardCacheService {
  static final CardCacheService _instance = CardCacheService._internal();
  factory CardCacheService() => _instance;
  CardCacheService._internal();

  // LRU cache for rendered cards
  final _cardCache = LinkedHashMap<String, Widget>();

  // Image cache for card images/icons
  final _imageCache = LinkedHashMap<String, ImageProvider>();

  // Maximum cache sizes
  static const int maxCardCacheSize = 50;
  static const int maxImageCacheSize = 100;

  // Cache statistics
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Get or create a cached card
  Widget getCachedCard(String key, Widget Function() builder) {
    if (_cardCache.containsKey(key)) {
      _cacheHits++;
      // Move to end (most recently used)
      final card = _cardCache.remove(key)!;
      _cardCache[key] = card;
      return card;
    }

    _cacheMisses++;
    final card = builder();
    _addToCache(key, card);
    return card;
  }

  /// Add a card to cache with LRU eviction
  void _addToCache(String key, Widget card) {
    if (_cardCache.length >= maxCardCacheSize) {
      // Remove least recently used (first item)
      _cardCache.remove(_cardCache.keys.first);
    }
    _cardCache[key] = card;
  }

  /// Cache an image provider
  void cacheImage(String key, ImageProvider image) {
    if (_imageCache.length >= maxImageCacheSize) {
      _imageCache.remove(_imageCache.keys.first);
    }
    _imageCache[key] = image;
  }

  /// Get cached image
  ImageProvider? getCachedImage(String key) {
    if (_imageCache.containsKey(key)) {
      final image = _imageCache.remove(key)!;
      _imageCache[key] = image;
      return image;
    }
    return null;
  }

  /// Preload cards for upcoming items
  void preloadCards(List<String> keys, Widget Function(String) builder) {
    for (final key in keys) {
      if (!_cardCache.containsKey(key) &&
          _cardCache.length < maxCardCacheSize) {
        _cardCache[key] = builder(key);
      }
    }
  }

  /// Clear specific cache entries
  void invalidateCard(String key) {
    _cardCache.remove(key);
  }

  /// Clear entire cache
  void clearCache() {
    _cardCache.clear();
    _imageCache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'cardCacheSize': _cardCache.length,
      'imageCacheSize': _imageCache.length,
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRate': _cacheHits + _cacheMisses > 0
          ? (_cacheHits / (_cacheHits + _cacheMisses) * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  /// Clear old cache entries based on time
  void pruneOldEntries(Duration maxAge) {
    // In a real implementation, you'd track timestamps
    // For now, just clear half the cache if it's full
    if (_cardCache.length >= maxCardCacheSize * 0.9) {
      final keysToRemove = _cardCache.keys.take(maxCardCacheSize ~/ 2).toList();
      for (final key in keysToRemove) {
        _cardCache.remove(key);
      }
    }
  }
}

/// Global cache service instance
final cardCacheService = CardCacheService();
