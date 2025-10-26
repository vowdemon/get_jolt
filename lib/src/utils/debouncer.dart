import 'dart:async';

/// A debouncer utility that delays function execution.
///
/// This class provides debouncing functionality by delaying the execution
/// of a function until a specified time period has passed without new calls.
/// If a new call is made before the delay period expires, the previous
/// call is canceled and the delay is reset.
///
/// This is particularly useful for:
/// - Search input fields (wait for user to stop typing)
/// - API calls that should be batched
/// - UI updates that should be throttled
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(delay: Duration(seconds: 1));
///
/// // Multiple rapid calls
/// debouncer(() => print('First call'));     // Canceled
/// debouncer(() => print('Second call'));     // Canceled
/// debouncer(() => print('Final call'));     // Executes after 1 second
/// ```
class Debouncer {
  /// The delay period before executing the function.
  final Duration? delay;
  Timer? _timer;

  /// Creates a debouncer with the specified delay.
  ///
  /// The [delay] parameter determines how long to wait before executing
  /// the function. If null, a default delay will be used.
  Debouncer({this.delay});

  /// Schedules a function to be executed after the delay period.
  ///
  /// If a function is already scheduled, it will be canceled and
  /// replaced with the new function. The delay timer is reset.
  ///
  /// Example:
  /// ```dart
  /// final debouncer = Debouncer(delay: Duration(milliseconds: 500));
  /// debouncer(() => performSearch(query));
  /// ```
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay!, action);
  }

  /// Whether a delayed call is currently active.
  ///
  /// Returns true if there is a scheduled function waiting to be executed,
  /// false otherwise.
  bool get isRunning => _timer?.isActive ?? false;

  /// Cancels the current delayed call.
  ///
  /// This method cancels any scheduled function execution. It's safe
  /// to call even when no function is scheduled.
  void cancel() => _timer?.cancel();
}
