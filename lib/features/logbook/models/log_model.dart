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

  @HiveField(7)
  final bool isPublic;

  @HiveField(8)
  final bool isSynced; // false = belum tersinkron ke Cloud

  @HiveField(9)
  final bool isDeleted; // true = soft-delete, menunggu hapus di Cloud

  Logbook({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.authorId,
    required this.teamId,
    this.isPublic = false,
    this.isSynced = false,
    this.isDeleted = false,
  });

  Logbook copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    String? authorId,
    String? teamId,
    bool? isPublic,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Logbook(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      authorId: authorId ?? this.authorId,
      teamId: teamId ?? this.teamId,
      isPublic: isPublic ?? this.isPublic,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'authorId': authorId,
      'teamId': teamId,
      'isPublic': isPublic,
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
      authorId: (map['authorId'] ?? map['username'] ?? 'unknown_user').toString(),
      teamId: (map['teamId'] ?? 'no_team').toString(),
      isPublic: map['isPublic'] ?? false,
      isSynced: true,   // data dari Cloud selalu dianggap sudah tersinkron
      isDeleted: false, // data dari Cloud tidak mungkin soft-deleted
    );
  }
}