import 'package:flutter/widgets.dart';
import 'package:jolt_flutter/jolt_flutter.dart';

import '../rx/rx.dart';

/// Base type for all GetX reactive widgets.
///
/// This typedef provides a common interface for reactive widgets,
/// ensuring consistent behavior across the GetX widget system.
/// It maps to Jolt Flutter's JoltBuilder for optimal performance.
///
/// See also:
/// - [Obx] - The simplest reactive widget
/// - [ObxValue] - Reactive widget with local state management
typedef ObxWidget = JoltBuilder;

/// The simplest reactive widget in GetX.
///
/// This widget automatically rebuilds whenever any reactive variable
/// used within its builder function changes. It provides the most
/// straightforward way to create reactive UI components.
///
/// The widget automatically tracks all reactive variables accessed
/// within the builder function and rebuilds only when those specific
/// variables change, ensuring optimal performance.
///
/// Example:
/// ```dart
/// final count = 0.obs;
/// final name = 'GetX'.obs;
///
/// Obx(() => Text('${name.value}: ${count.value}'))
/// ```
///
/// See also:
/// - [ObxValue] for widgets that manage local reactive state
class Obx extends ObxWidget {
  /// Creates a reactive widget that rebuilds when reactive variables change.
  ///
  /// The [builder] function is called whenever any reactive variable
  /// used within it changes. The function should return the widget
  /// tree to be displayed.
  Obx(Widget Function() builder, {super.key})
      : super(builder: (context) => builder());
}

/// Reactive widget that manages local state with a specific reactive variable.
///
/// Unlike [Obx], this widget is bound to a specific reactive variable
/// passed as a parameter. This is useful for simple local states like
/// toggles, visibility flags, themes, and button states.
///
/// The widget automatically rebuilds whenever the provided reactive
/// variable changes, making it perfect for localized reactive behavior.
///
/// Example:
/// ```dart
/// final isVisible = false.obs;
///
/// ObxValue((data) => Switch(
///   value: data.value,
///   onChanged: (flag) => data.value = flag,
/// ), isVisible)
/// ```
///
/// See also:
/// - [Obx] for widgets that use multiple reactive variables
class ObxValue<T extends RxInterface> extends ObxWidget {
  /// The reactive variable that this widget observes.
  final T data;

  /// Creates a reactive widget bound to a specific reactive variable.
  ///
  /// The [builder] function receives the reactive variable as a parameter
  /// and should return the widget tree to be displayed. The widget
  /// will rebuild whenever [data] changes.
  ObxValue(Widget Function(T) builder, this.data, {super.key})
      : super(builder: (context) => builder(data));
}
