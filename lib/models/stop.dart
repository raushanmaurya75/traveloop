import 'package:isar/isar.dart';

part 'stop.g.dart';

@collection
class Stop {
  Id id = Isar.autoIncrement;

  late int tripId;
  late String city;
  late DateTime date;
}
