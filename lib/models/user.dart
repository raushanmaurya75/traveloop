import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String email;

  late String name;
  late String passwordHash;
  late DateTime joinedAt;
  int avatarColorValue = 0xFF6366F1; // default: AppColors.primary
  String bio = '';
  String? photoPath; // absolute path saved via path_provider
}
