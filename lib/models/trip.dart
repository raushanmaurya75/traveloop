import 'package:isar/isar.dart';

part 'trip.g.dart';

@collection
class Trip {
  Id id = Isar.autoIncrement;

  late String name;
  late String destination;
  late DateTime startDate;
  late DateTime endDate;
  String? coverImageUrl;
  String notes = '';
  double budget = 0;
}
