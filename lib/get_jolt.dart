/// A GetX-compatible reactive state management library for Flutter.
///
/// This library provides a seamless migration path for developers familiar with GetX,
/// offering the same API surface while leveraging the power of Jolt Flutter's
/// reactive system under the hood.
///
/// ## Features
///
/// - **Reactive State Management**: Observable variables that automatically update UI
/// - **Reactive Widgets**: `Obx` and `ObxValue` widgets for reactive UI updates
/// - **Workers**: Powerful listeners for reactive programming patterns
/// - **Type-safe Extensions**: Comprehensive extensions for all Dart primitive types
///
/// ## Quick Start
///
/// ```dart
/// import 'package:get_jolt/get_jolt.dart';
///
/// // Create reactive variables
/// final count = 0.obs;
/// final name = 'GetX'.obs;
///
/// // Use in widgets
/// Obx(() => Text('Count: ${count.value}'))
///
/// // Listen to changes
/// ever(count, (value) => print('Count changed to $value'));
/// ```
///
/// ## Migration from GetX
///
/// This library maintains 100% API compatibility with GetX, allowing you to
/// migrate existing GetX projects with minimal code changes. Simply replace
/// your GetX dependency with this library and enjoy improved performance
/// and better integration with modern Flutter patterns.
library;

export 'src/widgets/obx.dart';
export 'src/utils/typedefs.dart';
export 'src/utils/workers.dart';
export 'src/rx/rx.dart';

export 'package:get/instance_manager.dart';
export 'package:get/route_manager.dart';
