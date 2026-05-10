import 'package:isar/isar.dart';

part 'activity.g.dart';

@collection
class Activity {
  Id id = Isar.autoIncrement;

  late int stopId;
  late String title;
  late String category;
  late String time;
  late String price;
  String description = '';
}
