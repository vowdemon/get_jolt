part of '../rx.dart';

/// Reactive map that automatically notifies listeners when modified.
///
/// This class provides reactive behavior for maps, allowing UI components
/// and other reactive elements to automatically update when the map
/// contents change. It supports all standard Map operations while
/// maintaining reactive behavior.
///
/// Example:
/// ```dart
/// final userData = <String, dynamic>{}.obs;
///
/// // Add data
/// userData['name'] = 'John';
/// userData['age'] = 25;
///
/// // Use in UI
/// Obx(() => Text('Name: ${userData['name']}'))
/// ```
class RxMap<K, V> extends MapSignal<K, V>
    with RxObjectMixin<Map<K, V>>
    implements RxInterface<Map<K, V>> {
  /// Creates a reactive map with the specified initial values.
  RxMap([Map<K, V> super.initial = const {}]);

  /// Creates a reactive map from another map.
  factory RxMap.from(Map<K, V> other) {
    return RxMap(Map.from(other));
  }

  /// Creates a reactive map with the same keys and values as [other].
  factory RxMap.of(Map<K, V> other) {
    return RxMap(Map.of(other));
  }

  /// Creates an unmodifiable reactive map containing the entries of [other].
  factory RxMap.unmodifiable(Map<dynamic, dynamic> other) {
    return RxMap(Map.unmodifiable(other));
  }

  /// Creates an identity reactive map with the default implementation.
  factory RxMap.identity() {
    return RxMap(Map.identity());
  }
}

/// Extension that adds reactive capabilities and utility methods to maps.
///
/// This extension provides the `.obs` getter for converting regular maps
/// to reactive maps, as well as utility methods for conditional operations
/// and batch updates.
///
/// Example:
/// ```dart
/// final data = {'key1': 'value1'};
/// final reactiveData = data.obs;
///
/// // Conditional operations
/// reactiveData.addIf(true, 'key2', 'value2');
/// reactiveData.addAllIf(condition, moreData);
/// ```
extension MapExtension<K, V> on Map<K, V> {
  /// Converts this map to a reactive map.
  RxMap<K, V> get obs {
    return RxMap<K, V>(this);
  }

  /// Adds a key-value pair to the map only if the condition is true.
  ///
  /// The [condition] can be a boolean value or a function that returns
  /// a boolean. This is useful for conditional map operations.
  ///
  /// Example:
  /// ```dart
  /// final data = <String, String>{}.obs;
  /// data.addIf(true, 'name', 'John');           // Added
  /// data.addIf(false, 'age', '25');             // Not added
  /// data.addIf(() => someCondition, 'city', 'New York'); // Added if condition is true
  /// ```
  void addIf(dynamic condition, K key, V value) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) {
      this[key] = value;
    }
  }

  /// Adds all key-value pairs from another map only if the condition is true.
  ///
  /// The [condition] can be a boolean value or a function that returns
  /// a boolean. This is useful for conditional batch operations.
  ///
  /// Example:
  /// ```dart
  /// final data = <String, String>{}.obs;
  /// final newData = {'key1': 'value1', 'key2': 'value2'};
  /// data.addAllIf(true, newData); // All pairs added
  /// ```
  void addAllIf(dynamic condition, Map<K, V> values) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(values);
  }

  /// Replaces all existing entries in the map with a single key-value pair.
  ///
  /// This method clears the map and adds the specified key-value pair,
  /// ensuring that only one entry remains in the map.
  ///
  /// Example:
  /// ```dart
  /// final data = {'key1': 'value1', 'key2': 'value2'}.obs;
  /// data.assign('newKey', 'newValue'); // Map now contains only 'newKey': 'newValue'
  /// ```
  void assign(K key, V val) {
    batch(() {
      clear();
      this[key] = val;
    });
  }

  /// Replaces all existing entries in the map with entries from another map.
  ///
  /// This method clears the map and adds all entries from the specified
  /// map, effectively replacing the entire map contents.
  ///
  /// Example:
  /// ```dart
  /// final data = {'key1': 'value1'}.obs;
  /// data.assignAll({'newKey1': 'newValue1', 'newKey2': 'newValue2'}); // Map replaced
  /// ```
  void assignAll(Map<K, V> val) {
    batch(() {
      clear();
      addAll(val);
    });
  }
}
