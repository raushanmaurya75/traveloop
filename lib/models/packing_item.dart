import 'package:isar/isar.dart';

part 'packing_item.g.dart';

@collection
class PackingItem {
  Id id = Isar.autoIncrement;

  late int tripId;
  late String name;
  bool isPacked = false;
}
