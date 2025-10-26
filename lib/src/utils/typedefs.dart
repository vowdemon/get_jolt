/// Type definition for conditional functions used in workers.
///
/// This typedef represents functions that return boolean values,
/// commonly used as conditions in worker functions like [ever],
/// [once], [interval], and [debounce].
///
/// Example:
/// ```dart
/// final count = 0.obs;
///
/// // Using a condition function
/// final worker = ever(count, (value) => print('Count: $value'),
///   condition: () => count.value > 5);
/// ```
typedef Condition = bool Function();

/// Type definition for data callback functions.
///
/// This typedef represents functions that handle data events,
/// commonly used in worker callbacks and reactive programming patterns.
///
/// Example:
/// ```dart
/// final count = 0.obs;
///
/// // Using OnData callback
/// OnData<int> onCountChange = (data) => print('Count changed to: $data');
/// count.listen(onCountChange);
/// ```
typedef OnData<T> = void Function(T data);

/// Type definition for simple callback functions.
///
/// This typedef represents functions that take no parameters and
/// return void, commonly used for simple actions and event handlers.
///
/// Example:
/// ```dart
/// final buttonPressed = () => print('Button pressed!');
///
/// // Using in a worker
/// final worker = ever(someVariable, (value) => buttonPressed());
/// ```
typedef Callback = void Function();
