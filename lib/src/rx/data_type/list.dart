part of '../rx.dart';

/// Reactive list that automatically notifies listeners when modified.
///
/// This class provides reactive behavior for lists, allowing UI components
/// and other reactive elements to automatically update when the list
/// contents change. It supports all standard List operations while
/// maintaining reactive behavior.
///
/// Example:
/// ```dart
/// final items = <String>[].obs;
///
/// // Add items
/// items.add('Item 1');
/// items.add('Item 2');
///
/// // Use in UI
/// Obx(() => ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) => Text(items[index]),
/// ))
/// ```
class RxList<E> extends ListSignalImpl<E>
    with RxObjectMixin<List<E>>
    implements RxInterface<List<E>> {
  /// Creates a reactive list with the specified initial values.
  RxList([List<E> super.initial = const []]);

  /// Creates a reactive list of the given length with [fill] at each position.
  factory RxList.filled(int length, E fill, {bool growable = false}) {
    return RxList(List.filled(length, fill, growable: growable));
  }

  /// Creates an empty reactive list.
  factory RxList.empty({bool growable = false}) {
    return RxList(List.empty(growable: growable));
  }

  /// Creates a reactive list containing all [elements].
  factory RxList.from(Iterable elements, {bool growable = true}) {
    return RxList(List.from(elements, growable: growable));
  }

  /// Creates a reactive list from [elements].
  factory RxList.of(Iterable<E> elements, {bool growable = true}) {
    return RxList(List.of(elements, growable: growable));
  }

  /// Generates a reactive list of values using the provided generator function.
  factory RxList.generate(int length, E Function(int index) generator,
      {bool growable = true}) {
    return RxList(List.generate(length, generator, growable: growable));
  }

  /// Creates an unmodifiable reactive list containing all [elements].
  factory RxList.unmodifiable(Iterable elements) {
    return RxList(List.unmodifiable(elements));
  }
}

/// Extension that adds reactive capabilities and utility methods to lists.
///
/// This extension provides the `.obs` getter for converting regular lists
/// to reactive lists, as well as utility methods for conditional operations
/// and batch updates.
///
/// Example:
/// ```dart
/// final items = ['Item 1', 'Item 2'];
/// final reactiveItems = items.obs;
///
/// // Conditional operations
/// reactiveItems.addIf(true, 'Item 3');
/// reactiveItems.addAllIf(condition, moreItems);
/// ```
extension ListExtension<E> on List<E> {
  /// Converts this list to a reactive list.
  RxList<E> get obs => RxList<E>(this);

  /// Adds an item to the list only if it is not null.
  ///
  /// This method provides a safe way to add items without null checks.
  /// It's particularly useful when working with nullable types.
  void addNonNull(E item) {
    if (item != null) add(item);
  }

  /// Adds an item to the list only if the condition is true.
  ///
  /// The [condition] can be a boolean value or a function that returns
  /// a boolean. This is useful for conditional list operations.
  ///
  /// Example:
  /// ```dart
  /// final items = <String>[].obs;
  /// items.addIf(true, 'Item 1');           // Added
  /// items.addIf(false, 'Item 2');          // Not added
  /// items.addIf(() => someCondition, 'Item 3'); // Added if condition is true
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
  /// final items = <String>[].obs;
  /// final newItems = ['Item 1', 'Item 2'];
  /// items.addAllIf(true, newItems); // All items added
  /// ```
  void addAllIf(dynamic condition, Iterable<E> items) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(items);
  }

  /// Replaces all existing items in the list with a single item.
  ///
  /// This method clears the list and adds the specified item,
  /// ensuring that only one item remains in the list.
  ///
  /// Example:
  /// ```dart
  /// final items = ['Item 1', 'Item 2', 'Item 3'].obs;
  /// items.assign('New Item'); // List now contains only 'New Item'
  /// ```
  void assign(E item) {
    batch(() {
      clear();
      add(item);
    });
  }

  /// Replaces all existing items in the list with items from an iterable.
  ///
  /// This method clears the list and adds all items from the specified
  /// iterable, effectively replacing the entire list contents.
  ///
  /// Example:
  /// ```dart
  /// final items = ['Item 1', 'Item 2'].obs;
  /// items.assignAll(['New Item 1', 'New Item 2']); // List replaced
  /// ```
  void assignAll(Iterable<E> items) {
    batch(() {
      clear();
      addAll(items);
    });
  }
}
