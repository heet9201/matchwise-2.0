import 'package:flutter/material.dart';
import '../services/card_cache_service.dart';

/// Optimized list builder with virtual scrolling and caching
class OptimizedListBuilder extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final String Function(int)? keyBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? itemExtent;
  final int preloadOffset;

  const OptimizedListBuilder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.keyBuilder,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.itemExtent,
    this.preloadOffset = 5,
  }) : super(key: key);

  @override
  State<OptimizedListBuilder> createState() => _OptimizedListBuilderState();
}

class _OptimizedListBuilderState extends State<OptimizedListBuilder> {
  late ScrollController _scrollController;
  final Set<int> _preloadedIndices = {};

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);

    // Preload initial items
    _preloadItems(0);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    // Calculate visible range
    final position = _scrollController.position;
    final viewportDimension = position.viewportDimension;
    final scrollOffset = position.pixels;

    if (widget.itemExtent != null) {
      final lastVisibleIndex =
          ((scrollOffset + viewportDimension) / widget.itemExtent!).ceil();

      // Preload items ahead
      _preloadItems(lastVisibleIndex);
    }
  }

  void _preloadItems(int fromIndex) {
    final endIndex =
        (fromIndex + widget.preloadOffset).clamp(0, widget.itemCount);

    for (int i = fromIndex; i < endIndex; i++) {
      if (!_preloadedIndices.contains(i) && widget.keyBuilder != null) {
        final key = widget.keyBuilder!(i);
        cardCacheService.getCachedCard(
            key, () => widget.itemBuilder(context, i));
        _preloadedIndices.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.itemCount,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemExtent: widget.itemExtent,
      itemBuilder: (context, index) {
        if (widget.keyBuilder != null) {
          final key = widget.keyBuilder!(index);
          return cardCacheService.getCachedCard(
            key,
            () => widget.itemBuilder(context, index),
          );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Optimized grid builder with virtual scrolling and caching
class OptimizedGridBuilder extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final String Function(int)? keyBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final SliverGridDelegate gridDelegate;
  final int preloadOffset;

  const OptimizedGridBuilder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.keyBuilder,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.preloadOffset = 10,
  }) : super(key: key);

  @override
  State<OptimizedGridBuilder> createState() => _OptimizedGridBuilderState();
}

class _OptimizedGridBuilderState extends State<OptimizedGridBuilder> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      itemCount: widget.itemCount,
      gridDelegate: widget.gridDelegate,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemBuilder: (context, index) {
        if (widget.keyBuilder != null) {
          final key = widget.keyBuilder!(index);
          return cardCacheService.getCachedCard(
            key,
            () => widget.itemBuilder(context, index),
          );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Optimized card widget with automatic caching
class CachedCard extends StatelessWidget {
  final String cacheKey;
  final Widget child;
  final bool useCache;

  const CachedCard({
    Key? key,
    required this.cacheKey,
    required this.child,
    this.useCache = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!useCache) return child;

    return cardCacheService.getCachedCard(
      cacheKey,
      () => child,
    );
  }
}
