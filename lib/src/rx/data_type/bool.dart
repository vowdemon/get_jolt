part of '../rx.dart';

/// Reactive boolean variable.
///
/// This class provides reactive behavior for boolean values, allowing
/// UI components and other reactive elements to automatically update
/// when the boolean value changes.
///
/// Example:
/// ```dart
/// final isVisible = false.obs;
///
/// // Toggle visibility
/// isVisible.value = !isVisible.value;
///
/// // Use in UI
/// Obx(() => isVisible.value ? Text('Visible') : SizedBox.shrink())
/// ```
class RxBool extends Rx<bool> {
  /// Creates a reactive boolean with the specified initial value.
  RxBool(super.initial);

  @override
  String toString() {
    return value ? "true" : "false";
  }
}

/// Nullable reactive boolean variable.
///
/// This class extends RxBool to handle nullable boolean values,
/// providing the same reactive behavior while allowing null values.
///
/// Example:
/// ```dart
/// final isEnabled = RxnBool();
///
/// isEnabled.value = true;  // Can be true, false, or null
/// isEnabled.value = null;  // Also valid
/// ```
class RxnBool extends Rx<bool?> {
  /// Creates a nullable reactive boolean with the specified initial value.
  RxnBool([super.initial]);

  @override
  String toString() {
    return "$value";
  }
}

/// Extension that adds boolean-specific methods to reactive boolean variables.
///
/// This extension provides convenient methods for working with reactive
/// boolean values, including logical operations and toggling functionality.
///
/// Example:
/// ```dart
/// final flag = true.obs;
///
/// // Check boolean state
/// if (flag.isTrue) print('Flag is true');
///
/// // Toggle value
/// flag.toggle();
///
/// // Logical operations
/// final result = flag & otherFlag;
/// ```
extension RxBoolExt on Rx<bool> {
  /// Returns true if the reactive boolean value is true.
  bool get isTrue => value;

  /// Returns true if the reactive boolean value is false.
  bool get isFalse => !isTrue;

  /// Performs logical AND operation with another boolean.
  bool operator &(bool other) => other && value;

  /// Performs logical OR operation with another boolean.
  bool operator |(bool other) => other || value;

  /// Performs logical XOR operation with another boolean.
  bool operator ^(bool other) => !other == value;

  /// Toggles the boolean value between false and true.
  ///
  /// This is a convenient shortcut for `flag.value = !flag.value`.
  /// The method returns the reactive boolean itself for method chaining.
  ///
  /// Example:
  /// ```dart
  /// final flag = false.obs;
  /// flag.toggle(); // Now flag.value is true
  /// flag.toggle(); // Now flag.value is false
  /// ```
  // ignore: avoid_returning_this
  Rx<bool> toggle() {
    value = !value;
    return this;
  }
}

extension RxnBoolExt on Rx<bool?> {
  bool? get isTrue => value;

  bool? get isFalse {
    if (value != null) return !isTrue!;
    return null;
  }

  bool? operator &(bool other) {
    if (value != null) {
      return other && value!;
    }
    return null;
  }

  bool? operator |(bool other) {
    if (value != null) {
      return other || value!;
    }
    return null;
  }

  bool? operator ^(bool other) => !other == value;

  /// Toggles the bool [value] between false and true.
  /// A shortcut for `flag.value = !flag.value;`
  /// FIXME: why return this? fluent interface is not
  ///  not really a dart thing since we have '..' operator
  // ignore: avoid_returning_this
  Rx<bool?>? toggle() {
    if (value != null) {
      value = !value!;
      return this;
    }
    return null;
  }
}

extension BoolExtension on bool {
  /// Returns a `RxBool` with [this] `bool` as initial value.
  RxBool get obs => RxBool(this);
}
