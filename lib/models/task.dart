///
/// Boundary Class for a Task object,
/// @authors Spencer Hoag & Zachary Hudelson
/// @version 1.0
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  late DateTime dateTime;
  late String title;
  late String description;
  late String category;

  ///Task object
  /// @param dateTime The date and time by which a task should be completed
  /// @param title The name of a given task
  /// @param description The description of a task, currently no text limit
  /// @param category The list to which a task belong, category(s) are of a limited type
  Task(
      {required this.dateTime,
      required this.title,
      required this.description,
      required this.category});

  ///
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'title': title,
      'description': description,
      'category': category,
    };
  }

  ///
  ///
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      title: map['title'],
      description: map['description'],
      category: map['category'],
    );
  }
}
