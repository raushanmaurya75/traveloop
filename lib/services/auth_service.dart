import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  late Isar _isar;
  final _controller = StreamController<User?>.broadcast();

  User? _current;
  User? get currentUser => _current;
  Stream<User?> get userStream => _controller.stream;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    // Reuse existing Isar instance if already open, otherwise open a new one
    if (Isar.instanceNames.contains('auth')) {
      _isar = Isar.getInstance('auth')!;
    } else {
      _isar = await Isar.open(
        [UserSchema],
        directory: dir.path,
        name: 'auth',
      );
    }
    // Restore last logged-in user (first user found = single-user local app)
    _current = await _isar.users.where().findFirst();
    _controller.add(_current);
  }

  static String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  /// Returns null on success, or an error message string.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required int avatarColorValue,
  }) async {
    final existing = await _isar.users.getByEmail(email.toLowerCase().trim());
    if (existing != null) return 'An account with this email already exists.';

    final user = User()
      ..name = name.trim()
      ..email = email.toLowerCase().trim()
      ..passwordHash = _hash(password)
      ..joinedAt = DateTime.now()
      ..avatarColorValue = avatarColorValue;

    await _isar.writeTxn(() => _isar.users.put(user));
    _current = user;
    _controller.add(_current);
    return null;
  }

  /// Returns null on success, or an error message string.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final user = await _isar.users.getByEmail(email.toLowerCase().trim());
    if (user == null) return 'No account found with this email.';
    if (user.passwordHash != _hash(password)) return 'Incorrect password.';

    _current = user;
    _controller.add(_current);
    return null;
  }

  Future<void> logout() async {
    _current = null;
    _controller.add(null);
  }

  Future<void> updateProfile({
    required String name,
    String? bio,
    int? avatarColorValue,
  }) async {
    if (_current == null) return;
    _current!.name = name.trim();
    if (bio != null) _current!.bio = bio;
    if (avatarColorValue != null) _current!.avatarColorValue = avatarColorValue;
    await _isar.writeTxn(() => _isar.users.put(_current!));
    _controller.add(_current);
  }

  /// Copies the picked image into app documents dir and saves the path.
  Future<void> updateProfilePhoto(String sourcePath) async {
    if (_current == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = p.join(dir.path, 'avatar_${_current!.id}.jpg');
    await File(sourcePath).copy(dest);
    _current!.photoPath = dest;
    await _isar.writeTxn(() => _isar.users.put(_current!));
    _controller.add(_current);
  }

  void dispose() => _controller.close();
}
