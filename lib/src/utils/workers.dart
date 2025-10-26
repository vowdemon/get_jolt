import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jolt_flutter/jolt_flutter.dart';

import '../rx/rx.dart';
import 'debouncer.dart';

/// Internal helper function to evaluate conditional expressions.
///
/// This function handles various types of conditions that can be passed
/// to worker functions, supporting both boolean values and functions
/// that return boolean values.
bool _conditional(dynamic condition) {
  if (condition == null) return true;
  if (condition is bool) return condition;
  if (condition is bool Function()) return condition();
  return true;
}

/// Callback function type for worker listeners.
///
/// This typedef defines the signature for functions that are called
/// when reactive variables change, providing a consistent interface
/// for all worker types.
typedef WorkerCallback<T> = Function(T callback);

/// Container for managing multiple workers.
///
/// This class provides a convenient way to manage multiple workers
/// together, allowing you to dispose of all workers at once.
///
/// Example:
/// ```dart
/// final workers = Workers([
///   ever(count, (value) => print('Count: $value')),
///   ever(name, (value) => print('Name: $value')),
/// ]);
///
/// // Later, dispose all workers
/// workers.dispose();
/// ```
class Workers {
  /// Creates a container for managing multiple workers.
  Workers(this.workers);

  /// List of workers to manage.
  final List<Worker> workers;

  /// Disposes all workers in the container.
  ///
  /// This method iterates through all workers and disposes them
  /// if they haven't been disposed already, ensuring proper cleanup.
  void dispose() {
    for (final worker in workers) {
      if (!worker._disposed) {
        worker.dispose();
      }
    }
  }
}

/// Creates a worker that listens to changes in a reactive variable.
///
/// This worker is called every time the [listener] changes, but only
/// when the [condition] evaluates to true. The worker continues to
/// listen until manually disposed.
///
/// The [condition] can be:
/// - A boolean value
/// - A function that returns a boolean
/// - null (always true)
///
/// Example:
/// ```dart
/// final count = 0.obs;
///
/// // Listen to all changes
/// final worker1 = ever(count, (value) => print('Count: $value'));
///
/// // Listen only when count > 5
/// final worker2 = ever(count, (value) {
///   print('Count is high: $value');
///   if (value == 10) worker2.dispose();
/// }, condition: () => count.value > 5);
/// ```
///
/// See also:
/// - [once] for one-time listeners
/// - [interval] for time-based listeners
/// - [debounce] for debounced listeners
Worker ever<T>(
  RxInterface<T> listener,
  WorkerCallback<T> callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  StreamSubscription sub = listener.listen(
    (event) {
      if (_conditional(condition)) callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, '[ever]');
}

/// Creates a worker that listens to multiple reactive variables.
///
/// This worker is similar to [ever], but it listens to multiple
/// reactive variables at once. The [callback] is executed whenever
/// any of the [listeners] change, but only when the [condition]
/// evaluates to true.
///
/// The worker manages all subscriptions together, so calling
/// `dispose()` will cancel all streams at once.
///
/// Example:
/// ```dart
/// final count = 0.obs;
/// final name = 'John'.obs;
/// final age = 25.obs;
///
/// final worker = everAll([count, name, age], (value) {
///   print('Something changed: $value');
/// });
///
/// // Later, dispose all listeners at once
/// worker.dispose();
/// ```
///
/// See also:
/// - [ever] for single variable listeners
Worker everAll(
  List<RxInterface> listeners,
  WorkerCallback callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  final evers = <StreamSubscription>[];
  for (var i in listeners) {
    final sub = i.listen(
      (event) {
        if (_conditional(condition)) callback(event);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    evers.add(sub);
  }

  Future<void> cancel() {
    for (var i in evers) {
      i.cancel();
    }

    return Future.value();
  }

  return Worker(cancel, '[everAll]');
}

/// Creates a worker that executes only once when a condition is met.
///
/// This worker listens to the [listener] and executes the [callback]
/// only the first time the [condition] evaluates to true. After
/// execution, the worker automatically disposes itself.
///
/// This is useful for one-time actions like initialization, cleanup,
/// or triggering events that should only happen once.
///
/// Example:
/// ```dart
/// final count = 0.obs;
///
/// // Execute once when count reaches 5
/// final worker = once(count, (value) {
///   print('Count reached 5 for the first time!');
/// }, condition: () => count.value >= 5);
///
/// count.value = 3; // Nothing happens
/// count.value = 5; // Callback executes, worker disposes
/// count.value = 6; // Nothing happens (worker is disposed)
/// ```
///
/// See also:
/// - [ever] for continuous listeners
/// - [interval] for time-based listeners
Worker once<T>(
  RxInterface<T> listener,
  WorkerCallback<T> callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  late Worker ref;
  StreamSubscription? sub;
  sub = listener.listen(
    (event) {
      if (!_conditional(condition)) return;
      ref._disposed = true;
      ref._log('called');
      sub?.cancel();
      callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  ref = Worker(sub.cancel, '[once]');
  return ref;
}

/// Creates a worker that executes at regular intervals.
///
/// This worker ignores all changes in the [listener] during the specified
/// [time] period (1 second by default) or until the [condition] is met.
/// It processes the first value that occurs after the time period.
///
/// This is useful for:
/// - Rate limiting user interactions
/// - Periodic data processing
/// - Preventing excessive API calls
///
/// Example:
/// ```dart
/// final count = 0.obs;
///
/// // Process count changes every 2 seconds
/// final worker = interval(count, (value) {
///   print('Processing count: $value');
/// }, time: Duration(seconds: 2));
///
/// count.value = 1; // Ignored
/// count.value = 2; // Ignored
/// count.value = 3; // After 2 seconds, processes 3
/// ```
///
/// See also:
/// - [debounce] for debounced execution
/// - [ever] for immediate execution
Worker interval<T>(
  RxInterface<T> listener,
  WorkerCallback<T> callback, {
  Duration time = const Duration(seconds: 1),
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  var debounceActive = false;
  StreamSubscription sub = listener.listen(
    (event) async {
      if (debounceActive || !_conditional(condition)) return;
      debounceActive = true;
      await Future.delayed(time);
      debounceActive = false;
      callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, '[interval]');
}

/// Creates a worker that debounces rapid changes.
///
/// This worker is similar to [interval], but it sends the last value
/// after the specified time period. It's particularly useful for
/// anti-DDoS scenarios, such as when a user stops typing for a period.
///
/// The worker waits for the [time] period to pass without new changes,
/// then executes the [callback] with the last emitted value.
///
/// This is ideal for:
/// - Search input fields (wait for user to stop typing)
/// - API calls that should be batched
/// - UI updates that should be throttled
///
/// Example:
/// ```dart
/// final searchQuery = ''.obs;
///
/// // Debounce search input
/// final worker = debounce(searchQuery, (query) {
///   if (query.isNotEmpty) {
///     performSearch(query);
///   }
/// }, time: Duration(milliseconds: 500));
///
/// searchQuery.value = 'a';     // Ignored
/// searchQuery.value = 'ab';    // Ignored
/// searchQuery.value = 'abc';  // After 500ms, searches for 'abc'
/// ```
///
/// See also:
/// - [interval] for periodic execution
/// - [ever] for immediate execution
Worker debounce<T>(
  RxInterface<T> listener,
  WorkerCallback<T> callback, {
  Duration? time,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  final debouncerCallback =
      Debouncer(delay: time ?? const Duration(milliseconds: 800));
  StreamSubscription sub = listener.listen(
    (event) {
      debouncerCallback(() {
        callback(event);
      });
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, '[debounce]');
}

/// Represents a worker that listens to reactive variables.
///
/// Workers are the foundation of reactive programming in GetX. They
/// provide a way to listen to changes in reactive variables and
/// execute callbacks when those changes occur.
///
/// Workers can be of different types:
/// - [ever] - Continuous listeners
/// - [once] - One-time listeners
/// - [interval] - Time-based listeners
/// - [debounce] - Debounced listeners
///
/// Example:
/// ```dart
/// final count = 0.obs;
/// final worker = ever(count, (value) => print('Count: $value'));
///
/// // Later, dispose the worker
/// worker.dispose();
/// ```
class Worker {
  /// Creates a worker with the specified cancel function and type.
  Worker(this.worker, this.type);

  /// The function to call when disposing this worker.
  final Future<void> Function() worker;

  /// The type of worker (ever, once, interval, debounce).
  final String type;
  bool _disposed = false;

  /// Whether this worker has been disposed.
  bool get disposed => _disposed;

  /// Internal logging method for debugging.
  void _log(String msg) {
    debugPrint('$runtimeType $type $msg');
  }

  /// Disposes this worker, canceling all subscriptions.
  ///
  /// This method should be called when the worker is no longer needed
  /// to prevent memory leaks and unnecessary processing.
  ///
  /// Calling dispose on an already disposed worker is safe and will
  /// be ignored.
  void dispose() {
    if (_disposed) {
      _log('already disposed');
      return;
    }
    _disposed = true;
    worker();
    _log('disposed');
  }

  /// Convenience method to dispose the worker.
  ///
  /// This allows the worker to be called as a function for disposal.
  void call() => dispose();
}
