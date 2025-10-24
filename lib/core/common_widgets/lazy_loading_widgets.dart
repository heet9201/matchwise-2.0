import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_cache_service.dart';

/// Lazy loading image widget with placeholder and error handling
class LazyImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const LazyImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.broken_image,
        color: Colors.grey[600],
        size: 40,
      ),
    );
  }
}

/// Lazy loading list item with visibility detection
class LazyLoadingListItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onVisible;
  final double visibilityThreshold;

  const LazyLoadingListItem({
    Key? key,
    required this.child,
    this.onVisible,
    this.visibilityThreshold = 0.5,
  }) : super(key: key);

  @override
  State<LazyLoadingListItem> createState() => _LazyLoadingListItemState();
}

class _LazyLoadingListItemState extends State<LazyLoadingListItem> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (info) {
        if (!_isVisible && info.visibleFraction >= widget.visibilityThreshold) {
          _isVisible = true;
          widget.onVisible?.call();
        }
      },
      child: widget.child,
    );
  }
}

/// Simple visibility detector
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
    return widget.child;
  }

  void _checkVisibility() {
    try {
      final RenderObject? renderObject = context.findRenderObject();
      if (renderObject == null || !renderObject.attached) return;

      final RenderAbstractViewport? viewport =
          RenderAbstractViewport.maybeOf(renderObject);
      if (viewport == null) return;

      final Size size = renderObject.paintBounds.size;
      final Matrix4 transform = renderObject.getTransformTo(viewport);
      final Offset position =
          MatrixUtils.transformPoint(transform, Offset.zero);

      final viewportHeight = viewport.paintBounds.height;
      final itemTop = position.dy;
      final itemBottom = itemTop + size.height;

      double visibleFraction = 0.0;
      if (itemBottom > 0 && itemTop < viewportHeight) {
        final visibleTop = itemTop < 0 ? 0.0 : itemTop;
        final visibleBottom =
            itemBottom > viewportHeight ? viewportHeight : itemBottom;
        final visibleHeight = visibleBottom - visibleTop;
        visibleFraction = visibleHeight / size.height;
      }

      widget.onVisibilityChanged(VisibilityInfo(
        key: widget.key,
        size: size,
        visibleFraction: visibleFraction,
      ));
    } catch (e) {
      // Ignore errors during visibility check
    }
  }
}

/// Visibility info
class VisibilityInfo {
  final Key key;
  final Size size;
  final double visibleFraction;

  VisibilityInfo({
    required this.key,
    required this.size,
    required this.visibleFraction,
  });
}

/// Lazy loading comparison card
class LazyComparisonCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;
  final bool preload;

  const LazyComparisonCard({
    Key? key,
    required this.item,
    this.onTap,
    this.preload = false,
  }) : super(key: key);

  @override
  State<LazyComparisonCard> createState() => _LazyComparisonCardState();
}

class _LazyComparisonCardState extends State<LazyComparisonCard> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.preload) {
      _loadContent();
    }
  }

  void _loadContent() {
    if (_loaded) return;

    setState(() {
      _loaded = true;
    });

    // Preload image if available
    final imageUrl = widget.item['image_url'] as String?;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageCacheService.preloadImages([imageUrl]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return LazyLoadingListItem(
        onVisible: _loadContent,
        child: _buildPlaceholder(),
      );
    }

    return _buildCard();
  }

  Widget _buildPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildCard() {
    final title = widget.item['title'] as String? ?? 'Untitled';
    final score = widget.item['score'] as double? ?? 0.0;
    final imageUrl = widget.item['image_url'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                LazyImage(
                  imageUrl: imageUrl,
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.circular(8),
                ),
              if (imageUrl != null && imageUrl.isNotEmpty)
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score: ${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paginated lazy loading list
class PaginatedLazyList extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function(int page, int limit)
      loadPage;
  final Widget Function(BuildContext, Map<String, dynamic>) itemBuilder;
  final int pageSize;
  final Widget? emptyWidget;
  final Widget? errorWidget;

  const PaginatedLazyList({
    Key? key,
    required this.loadPage,
    required this.itemBuilder,
    this.pageSize = 20,
    this.emptyWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<PaginatedLazyList> createState() => _PaginatedLazyListState();
}

class _PaginatedLazyListState extends State<PaginatedLazyList> {
  final List<Map<String, dynamic>> _items = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || !_hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newItems = await widget.loadPage(_currentPage, widget.pageSize);

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length >= widget.pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return widget.errorWidget ?? Center(child: Text('Error: $_error'));
    }

    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('No items found'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, _items[index]);
      },
    );
  }
}
