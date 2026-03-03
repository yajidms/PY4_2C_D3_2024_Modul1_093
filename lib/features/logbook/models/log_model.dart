import 'package:mongo_dart/mongo_dart.dart';

class Logbook {
  final ObjectId? id; // Penanda unik global dari MongoDB
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final String username;

  Logbook({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(),
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'username': username,
    };
  }

  factory Logbook.fromMap(Map<String, dynamic> map) {
    return Logbook(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      category: (map['category'] ?? 'Pribadi').toString(),
      username: (map['username'] ?? '').toString(),
    );
  }
}