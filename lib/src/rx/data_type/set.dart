part of '../rx.dart';

/// Reactive set that automatically notifies listeners when modified.
///
/// This class provides reactive behavior for sets, allowing UI components
/// and other reactive elements to automatically update when the set
/// contents change. It supports all standard Set operations while
/// maintaining reactive behavior.
///
/// Example:
/// ```dart
/// final tags = <String>{}.obs;
///
/// // Add tags
/// tags.add('flutter');
/// tags.add('dart');
///
/// // Use in UI
/// Obx(() => Text('Tags: ${tags.join(', ')}'))
/// ```
class RxSet<E> extends SetSignal<E>
    with RxObjectMixin<Set<E>>
    implements RxInterface<Set<E>> {
  /// Creates a reactive set with the specified initial values.
  RxSet([Set<E> super.initial = const {}]);

  /// Adds all elements from another set to this reactive set.
  ///
  /// This operator provides a convenient way to add multiple elements
  /// to the set in a reactive manner. It returns the set itself for
  /// method chaining.
  ///
  /// Example:
  /// ```dart
  /// final set1 = {'a', 'b'}.obs;
  /// final set2 = {'c', 'd'};
  /// set1 + set2; // set1 now contains 'a', 'b', 'c', 'd'
  /// ```
  RxSet<E> operator +(Set<E> val) {
    addAll(val);
    return this;
  }

  /// Updates the set using a callback function.
  ///
  /// This method provides a convenient way to update the set while
  /// ensuring all listeners are notified. The callback receives the
  /// current set value as a parameter.
  ///
  /// Example:
  /// ```dart
  /// final tags = {'flutter'}.obs;
  /// tags.update((currentTags) {
  ///   currentTags?.add('dart');
  ///   currentTags?.add('mobile');
  /// });
  /// ```
  void update(void Function(Iterable<E>? value) fn) {
    batch(() {
      fn(value);
    });
  }
}

/// Extension that adds reactive capabilities and utility methods to sets.
///
/// This extension provides the `.obs` getter for converting regular sets
/// to reactive sets, as well as utility methods for conditional operations
/// and batch updates.
///
/// Example:
/// ```dart
/// final tags = {'flutter', 'dart'};
/// final reactiveTags = tags.obs;
///
/// // Conditional operations
/// reactiveTags.addIf(true, 'mobile');
/// reactiveTags.addAllIf(condition, moreTags);
/// ```
extension SetExtension<E> on Set<E> {
  /// Converts this set to a reactive set.
  RxSet<E> get obs {
    return RxSet<E>(<E>{})..addAll(this);
  }

  /// Adds an item to the set only if the condition is true.
  ///
  /// The [condition] can be a boolean value or a function that returns
  /// a boolean. This is useful for conditional set operations.
  ///
  /// Example:
  /// ```dart
  /// final tags = <String>{}.obs;
  /// tags.addIf(true, 'flutter');           // Added
  /// tags.addIf(false, 'dart');             // Not added
  /// tags.addIf(() => someCondition, 'mobile'); // Added if condition is true
  /// ```
  void addIf(dynamic condition, E item) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) add(item);
  }

  /// Adds all items from an iterable only if the condition is true.
  ///
  /// The [condition] can be a boolean value or a function that returns
  /// a boolean. This is useful for conditional batch operations.
  ///
  /// Example:
  /// ```dart
  /// final tags = <String>{}.obs;
  /// final newTags = {'flutter', 'dart'};
  /// tags.addAllIf(true, newTags); // All items added
  /// ```
  void addAllIf(dynamic condition, Iterable<E> items) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(items);
  }

  /// Replaces all existing items in the set with a single item.
  ///
  /// This method clears the set and adds the specified item,
  /// ensuring that only one item remains in the set.
  ///
  /// Example:
  /// ```dart
  /// final tags = {'flutter', 'dart', 'mobile'}.obs;
  /// tags.assign('newTag'); // Set now contains only 'newTag'
  /// ```
  void assign(E item) {
    batch(() {
      clear();
      add(item);
    });
  }

  /// Replaces all existing items in the set with items from an iterable.
  ///
  /// This method clears the set and adds all items from the specified
  /// iterable, effectively replacing the entire set contents.
  ///
  /// Example:
  /// ```dart
  /// final tags = {'flutter'}.obs;
  /// tags.assignAll({'dart', 'mobile', 'web'}); // Set replaced
  /// ```
  void assignAll(Iterable<E> items) {
    batch(() {
      clear();
      addAll(items);
    });
  }
}
