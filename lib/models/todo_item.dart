import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final String ownerId;
  final String ownerEmail;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.ownerId,
    required this.ownerEmail,
  });

  factory TodoItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle null timestamp gracefully
    DateTime createdAt;
    if (data['createdAt'] != null) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      // Fallback to current time if timestamp is null
      createdAt = DateTime.now();
    }

    return TodoItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: createdAt,
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
    };
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      ownerId: ownerId,
      ownerEmail: ownerEmail,
    );
  }
}
