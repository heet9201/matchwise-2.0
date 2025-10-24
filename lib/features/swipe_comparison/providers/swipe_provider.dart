import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/comparison_models.dart';

// Swipe state
class SwipeState {
  final List<ComparisonResult> allResults;
  final int currentIndex;
  final List<ComparisonResult> shortlist;
  final List<ComparisonResult> passed;
  final List<SwipeAction> history;
  final bool isAnimating;
  final SwipeDirection? currentSwipeDirection;
  final double swipeProgress;

  SwipeState({
    required this.allResults,
    this.currentIndex = 0,
    this.shortlist = const [],
    this.passed = const [],
    this.history = const [],
    this.isAnimating = false,
    this.currentSwipeDirection,
    this.swipeProgress = 0.0,
  });

  SwipeState copyWith({
    List<ComparisonResult>? allResults,
    int? currentIndex,
    List<ComparisonResult>? shortlist,
    List<ComparisonResult>? passed,
    List<SwipeAction>? history,
    bool? isAnimating,
    SwipeDirection? currentSwipeDirection,
    double? swipeProgress,
  }) {
    return SwipeState(
      allResults: allResults ?? this.allResults,
      currentIndex: currentIndex ?? this.currentIndex,
      shortlist: shortlist ?? this.shortlist,
      passed: passed ?? this.passed,
      history: history ?? this.history,
      isAnimating: isAnimating ?? this.isAnimating,
      currentSwipeDirection:
          currentSwipeDirection ?? this.currentSwipeDirection,
      swipeProgress: swipeProgress ?? this.swipeProgress,
    );
  }

  bool get hasMore => currentIndex < allResults.length;
  bool get canUndo => history.isNotEmpty;
  ComparisonResult? get currentResult =>
      hasMore ? allResults[currentIndex] : null;
}

enum SwipeDirection { left, right, up }

class SwipeAction {
  final int index;
  final SwipeDirection direction;
  final ComparisonResult result;

  SwipeAction({
    required this.index,
    required this.direction,
    required this.result,
  });
}

// Swipe Notifier
class SwipeNotifier extends StateNotifier<SwipeState> {
  SwipeNotifier(List<ComparisonResult> results)
      : super(SwipeState(allResults: results));

  void updateSwipeProgress(double progress, SwipeDirection? direction) {
    state = state.copyWith(
      swipeProgress: progress,
      currentSwipeDirection: direction,
    );
  }

  void swipeLeft() {
    if (!state.hasMore || state.isAnimating) return;

    state = state.copyWith(isAnimating: true);

    final currentResult = state.currentResult!;
    final newPassed = [...state.passed, currentResult];
    final newHistory = [
      ...state.history,
      SwipeAction(
        index: state.currentIndex,
        direction: SwipeDirection.left,
        result: currentResult,
      ),
    ];

    // Delay to allow animation
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        passed: newPassed,
        history: newHistory,
        isAnimating: false,
        swipeProgress: 0.0,
        currentSwipeDirection: null,
      );
    });
  }

  void swipeRight() {
    if (!state.hasMore || state.isAnimating) return;

    state = state.copyWith(isAnimating: true);

    final currentResult = state.currentResult!;
    final newShortlist = [...state.shortlist, currentResult];
    final newHistory = [
      ...state.history,
      SwipeAction(
        index: state.currentIndex,
        direction: SwipeDirection.right,
        result: currentResult,
      ),
    ];

    // Delay to allow animation
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        shortlist: newShortlist,
        history: newHistory,
        isAnimating: false,
        swipeProgress: 0.0,
        currentSwipeDirection: null,
      );
    });
  }

  void swipeUp() {
    // Super like / Details
    if (!state.hasMore || state.isAnimating) return;
    state = state.copyWith(isAnimating: true);
    // Reset after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      state = state.copyWith(
        isAnimating: false,
        swipeProgress: 0.0,
        currentSwipeDirection: null,
      );
    });
  }

  void undo() {
    if (!state.canUndo || state.isAnimating) return;

    final lastAction = state.history.last;
    final newHistory = state.history.sublist(0, state.history.length - 1);

    List<ComparisonResult> newShortlist = [...state.shortlist];
    List<ComparisonResult> newPassed = [...state.passed];

    if (lastAction.direction == SwipeDirection.right) {
      newShortlist.remove(lastAction.result);
    } else if (lastAction.direction == SwipeDirection.left) {
      newPassed.remove(lastAction.result);
    }

    state = state.copyWith(
      currentIndex: lastAction.index,
      shortlist: newShortlist,
      passed: newPassed,
      history: newHistory,
      swipeProgress: 0.0,
      currentSwipeDirection: null,
    );
  }
}

// Provider
final swipeProvider = StateNotifierProvider.family<SwipeNotifier, SwipeState,
    List<ComparisonResult>>(
  (ref, results) => SwipeNotifier(results),
);
