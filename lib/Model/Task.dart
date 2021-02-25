import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  Task({
    this.name,
    this.description,
    this.isComplete,
    this.repReward,
    this.uploadDate,
    this.dueDate,
    this.id,
  });

  final String name;
  final String description;
  final bool isComplete;
  final int repReward;
  final Timestamp uploadDate;
  final Timestamp dueDate;
  final String id;
}
