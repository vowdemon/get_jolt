part of 'rx.dart';

/// Type alias for reactive interface, providing compatibility with GetX.
///
/// This typedef maps to Jolt Flutter's Signal type, ensuring seamless
/// integration with the underlying reactive system while maintaining
/// GetX API compatibility.
typedef RxInterface<T> = Signal<T>;

/// Mixin that provides GetX-compatible methods for reactive objects.
///
/// This mixin adds compatibility methods to reactive objects, allowing
/// them to work seamlessly with existing GetX code while leveraging
/// the performance benefits of Jolt Flutter's reactive system.
mixin RxObjectMixin<T> on RxInterface<T> {
  /// Refreshes the reactive value, triggering all listeners.
  ///
  /// This method is provided for GetX compatibility and internally
  /// calls the underlying notify method to update all subscribers.
  void refresh() {
    notify();
  }

  /// Callable method for GetX compatibility.
  ///
  /// When called without arguments, returns the current value.
  /// When called with an argument, updates the value and returns it.
  ///
  /// Example:
  /// ```dart
  /// final count = 0.obs;
  /// print(count()); // 0
  /// count(5); // Sets value to 5
  /// print(count()); // 5
  /// ```
  T call([T? v]) {
    if (v != null) {
      value = v;
    }
    return value;
  }

  /// Returns the string representation of the current value.
  ///
  /// This getter provides GetX compatibility for string conversion.
  String get string => value.toString();

  /// Converts the reactive value to JSON.
  ///
  /// Returns the underlying value for JSON serialization.
  /// This method is provided for GetX compatibility.
  dynamic toJson() => value;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object o) {
    if (o is T) return value == o;
    if (o is RxObjectMixin<T>) return value == o.value;
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  /// Listens to changes and immediately pumps the current value.
  ///
  /// This method provides GetX compatibility for immediate value delivery
  /// when subscribing to reactive variables. The listener will be called
  /// immediately with the current value, then on every subsequent change.
  ///
  /// Example:
  /// ```dart
  /// final count = 0.obs;
  /// count.listenAndPump((value) => print('Count: $value')); // Prints immediately
  /// count.value = 5; // Prints again
  /// ```
  StreamSubscription<T> listenAndPump(void Function(T event) onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final subscription = listen(onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
        immediately: true);

    return subscription;
  }

  /// Binds this reactive variable to a stream.
  ///
  /// Any values emitted by the provided stream will automatically
  /// update this reactive variable, triggering all listeners.
  ///
  /// Example:
  /// ```dart
  /// final count = 0.obs;
  /// final stream = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// count.bindStream(stream); // count will update every second
  /// ```
  StreamSubscription<T> bindStream(Stream<T> stream) {
    return stream.listen((va) => value = va);
  }
}

/// Base implementation for reactive variables.
///
/// This abstract class provides the foundation for all reactive types,
/// managing stream logic and providing core reactive functionality.
/// It implements the IMutableCollection interface for collection-based
/// reactive types.
abstract class _RxImpl<T> extends RxInterface<T>
    with RxObjectMixin<T>
    implements IMutableCollection {
  _RxImpl(T super.initial);

  /// Maps the reactive stream to a new type.
  ///
  /// Creates a new stream that transforms each emitted value using
  /// the provided mapper function.
  Stream<R> map<R>(R Function(T? data) mapper) => stream.map(mapper);

  /// Updates the reactive value using a callback function.
  ///
  /// This method provides a convenient way to update the value while
  /// ensuring all listeners are notified. The callback receives the
  /// current value as a parameter, making it ideal for updating
  /// complex objects or performing batch operations.
  ///
  /// Example:
  /// ```dart
  /// class Person {
  ///   String name;
  ///   int age;
  ///   Person({required this.name, required this.age});
  /// }
  ///
  /// final person = Person(name: 'John', age: 18).obs;
  /// person.update((p) {
  ///   p?.name = 'Jane';
  ///   p?.age = 25;
  /// });
  /// ```
  void update(void Function(T? val) fn) {
    batch(() {
      fn(value);
    });
  }

  /// Forces a reactive update even when the value hasn't changed.
  ///
  /// Normally, reactive variables only notify listeners when their value
  /// actually changes. This method allows you to force a notification
  /// even when the new value is the same as the current value.
  ///
  /// This is particularly useful for:
  /// - Animation triggers that need to restart even with the same value
  /// - UI updates that should occur regardless of value changes
  /// - Debugging scenarios where you want to verify listener behavior
  ///
  /// Example:
  /// ```dart
  /// final count = 0.obs;
  /// count.listen((value) => print('Count updated: $value'));
  ///
  /// count.value = 5; // Triggers listener
  /// count.value = 5; // Won't trigger (same value)
  /// count.trigger(5); // Will trigger even though value is the same
  /// ```
  void trigger(T v) {
    pendingValue = v;
    notify();
  }
}

/// Generic reactive variable for any type.
///
/// This is the foundation class for reactive variables that can hold
/// any type of data. It's particularly useful for custom model classes
/// and complex objects that need reactive behavior.
///
/// Example:
/// ```dart
/// class User {
///   final String name;
///   final int age;
///   User(this.name, this.age);
/// }
///
/// final user = User('John', 25).obs;
/// user.value = User('Jane', 30); // Triggers all listeners
/// ```
class Rx<T> extends _RxImpl<T> {
  Rx(super.initial);

  @override
  dynamic toJson() {
    try {
      return (value as dynamic)?.toJson();
    } on Exception catch (_) {
      throw '$T has not method [toJson]';
    }
  }
}

/// Nullable reactive variable for any type.
///
/// This class extends Rx to handle nullable values, providing
/// the same reactive behavior while allowing null values.
///
/// Example:
/// ```dart
/// final name = Rxn<String>();
/// name.value = 'John'; // Can be null or a string
/// name.value = null;   // Also valid
/// ```
class Rxn<T> extends Rx<T?> {
  Rxn([super.initial]);

  @override
  dynamic toJson() {
    try {
      return (value as dynamic)?.toJson();
    } on Exception catch (_) {
      throw '$T has not method [toJson]';
    }
  }
}

/// Extension that adds reactive capabilities to any type.
///
/// This extension provides the `.obs` getter that converts any value
/// into a reactive variable, enabling reactive programming patterns
/// with any Dart type.
///
/// Example:
/// ```dart
/// final count = 0.obs;        // Creates RxInt
/// final name = 'Hello'.obs;    // Creates RxString
/// final flag = true.obs;       // Creates RxBool
/// ```
extension RxT<T> on T {
  /// Returns a `Rx` instance with [this] `T` as initial value.
  Rx<T> get obs => Rx<T>(this);
}
