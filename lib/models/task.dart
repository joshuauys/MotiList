class Task {
  late Map<String, bool> daysOfWeek;
  late String title;
  late String description;
  late String category;

  ///Task object
  /// @param daysOfWeek The days of the week a task is assigned to
  /// @param title The name of a given task
  /// @param description The description of a task, currently no text limit
  /// @param category The list to which a task belong, category(s) are of a limited type
  Task(
      {required this.daysOfWeek,
      required this.title,
      required this.description,
      required this.category});

  ///
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'daysOfWeek': daysOfWeek,
      'title': title,
      'description': description,
      'category': category,
    };
  }

  ///
  ///
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      // Ensure 'daysOfWeek' is not null and has the correct type
      daysOfWeek: (map['daysOfWeek'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as bool)) ??
          {}, // Provide a default empty map if null

      // Use 'as String?' to cast as a nullable String, and provide default value if null
      title: map['name'] as String? ?? 'Default Title',

      // Same nullable cast and default value for description
      description: map['description'] as String? ?? 'No description provided',

      // Same nullable cast and default value for category
      category: map['category'] as String? ?? 'Uncategorized',
    );
  }
}

// static Task fromMap(Map<String, dynamic> map) {
//     return Task(
//       daysOfWeek: (map['daysOfWeek'] as Map<String, dynamic>)
//           .map((key, value) => MapEntry(key, value as bool)),
//       title: map['title'],
//       description: map['description'],
//       category: map['category'],
//     );
// }
