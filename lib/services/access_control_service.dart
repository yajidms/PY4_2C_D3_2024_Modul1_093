import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessControlService {
  // Mengambil roles dari .env, default ke 'Anggota' jika tidak ada
  static List<String> get availableRoles =>
      dotenv.env['APP_ROLES']?.split(',') ?? ['Anggota'];

  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  // Matrix perizinan (Role-Based Access Control)
  static final Map<String, List<String>> _rolePermissions = {
    'Pemilik Catatan': [actionCreate, actionRead, actionUpdate, actionDelete],
    'Ketua Tim':       [actionRead],
    'Anggota':         [actionRead],
  };

  static bool canPerform(String role, String action, {bool isOwner = false}) {
    if (role == 'Pemilik Catatan') {
      // Create & Read bebas tanpa syarat isOwner
      if (action == actionCreate || action == actionRead) return true;
      // Update & Delete hanya jika pemilik data
      return isOwner;
    }

    // Ketua Tim & Anggota: hanya Read, tidak ada syarat isOwner
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains(action);
  }
}

