///
/// Boundary Class for a Task object,
/// @authors Spencer Hoag & Zachary Hudelson
/// @version 1.0
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Task({required this.daysOfWeek, required this.title,
        required this.description, required this.category});
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
      daysOfWeek: (map['daysOfWeek'] as Map<String, dynamic>)
      .map((key, value) => MapEntry(key, value as bool)),
      title: map['title'],
      description: map['description'],
      category: map['category'],
    );
  }

}
