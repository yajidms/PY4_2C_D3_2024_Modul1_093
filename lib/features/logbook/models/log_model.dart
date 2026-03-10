import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0)
class Logbook {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String authorId;

  @HiveField(6)
  final String teamId;

  Logbook({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.authorId,
    required this.teamId,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'authorId': authorId,
      'teamId': teamId,
    };
  }

  factory Logbook.fromMap(Map<String, dynamic> map) {
    return Logbook(
      id: (map['_id'] as ObjectId?)?.oid ?? (map['_id'] is String ? map['_id'] : null),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null
          ? (map['date'] is String ? DateTime.parse(map['date']) : map['date'])
          : DateTime.now(),
      category: (map['category'] ?? 'Pribadi').toString(),
      authorId: (map['authorId'] ?? 'unknown_user').toString(),
      teamId: (map['teamId'] ?? 'no_team').toString(),
    );
  }
}