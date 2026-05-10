import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/trip.dart';
import '../models/stop.dart';
import '../models/activity.dart';
import '../models/packing_item.dart';

class IsarService {
  static final IsarService _instance = IsarService._();
  factory IsarService() => _instance;
  IsarService._();

  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TripSchema, StopSchema, ActivitySchema, PackingItemSchema],
      directory: dir.path,
    );
  }

  // ── Trips ──────────────────────────────────────────────────────────────────

  Stream<List<Trip>> watchTrips() =>
      _isar.trips.where().watch(fireImmediately: true);

  Future<Trip?> getTrip(int id) => _isar.trips.get(id);

  Future<int> saveTrip(Trip trip) =>
      _isar.writeTxn(() => _isar.trips.put(trip));

  Future<void> saveNote(int tripId, String notes) async {
    final trip = await _isar.trips.get(tripId);
    if (trip == null) return;
    trip.notes = notes;
    await _isar.writeTxn(() => _isar.trips.put(trip));
  }

  Future<void> saveBudget(int tripId, double budget) async {
    final trip = await _isar.trips.get(tripId);
    if (trip == null) return;
    trip.budget = budget;
    await _isar.writeTxn(() => _isar.trips.put(trip));
  }

  /// Deep-copies a trip with all its stops, activities, and packing items.
  Future<Trip> copyTrip(int sourceTripId) async {
    final source = await _isar.trips.get(sourceTripId);
    if (source == null) throw Exception('Trip not found');

    final newTrip = Trip()
      ..name = '${source.name} (Copy)'
      ..destination = source.destination
      ..startDate = source.startDate
      ..endDate = source.endDate
      ..notes = source.notes
      ..budget = source.budget;
    final newTripId = await _isar.writeTxn(() => _isar.trips.put(newTrip));
    newTrip.id = newTripId;

    final stops = await _isar.stops.filter().tripIdEqualTo(sourceTripId).findAll();
    for (final stop in stops) {
      final newStop = Stop()
        ..tripId = newTripId
        ..city = stop.city
        ..date = stop.date;
      final newStopId = await _isar.writeTxn(() => _isar.stops.put(newStop));

      final activities = await _isar.activitys.filter().stopIdEqualTo(stop.id).findAll();
      for (final act in activities) {
        final newAct = Activity()
          ..stopId = newStopId
          ..title = act.title
          ..category = act.category
          ..time = act.time
          ..price = act.price
          ..description = act.description;
        await _isar.writeTxn(() => _isar.activitys.put(newAct));
      }
    }

    final packingItems = await _isar.packingItems.filter().tripIdEqualTo(sourceTripId).findAll();
    for (final item in packingItems) {
      final newItem = PackingItem()
        ..tripId = newTripId
        ..name = item.name
        ..isPacked = false;
      await _isar.writeTxn(() => _isar.packingItems.put(newItem));
    }

    return newTrip;
  }

  Future<void> deleteTrip(int id) => _isar.writeTxn(() async {
        await _isar.trips.delete(id);
        final stopIds = await _isar.stops
            .filter()
            .tripIdEqualTo(id)
            .idProperty()
            .findAll();
        for (final sid in stopIds) {
          final actIds = await _isar.activitys
              .filter()
              .stopIdEqualTo(sid)
              .idProperty()
              .findAll();
          await _isar.activitys.deleteAll(actIds);
        }
        await _isar.stops.deleteAll(stopIds);
        final packingIds = await _isar.packingItems
            .filter()
            .tripIdEqualTo(id)
            .idProperty()
            .findAll();
        await _isar.packingItems.deleteAll(packingIds);
      });

  // ── Stops ──────────────────────────────────────────────────────────────────

  Stream<List<Stop>> watchStopsForTrip(int tripId) => _isar.stops
      .filter()
      .tripIdEqualTo(tripId)
      .watch(fireImmediately: true);

  Future<int> saveStop(Stop stop) =>
      _isar.writeTxn(() => _isar.stops.put(stop));

  Future<List<Stop>> getStopsForTrip(int tripId) =>
      _isar.stops.filter().tripIdEqualTo(tripId).findAll();

  Future<void> deleteStop(int stopId) => _isar.writeTxn(() async {
        final actIds = await _isar.activitys
            .filter()
            .stopIdEqualTo(stopId)
            .idProperty()
            .findAll();
        await _isar.activitys.deleteAll(actIds);
        await _isar.stops.delete(stopId);
      });

  // ── Activities ─────────────────────────────────────────────────────────────

  Stream<List<Activity>> watchActivitiesForStop(int stopId) => _isar.activitys
      .filter()
      .stopIdEqualTo(stopId)
      .watch(fireImmediately: true);

  Stream<List<Activity>> watchActivitiesForTrip(int tripId) async* {
    await for (final stops in watchStopsForTrip(tripId)) {
      final stopIds = stops.map((s) => s.id).toList();
      if (stopIds.isEmpty) {
        yield [];
        continue;
      }
      final activities = await _isar.activitys
          .filter()
          .anyOf(stopIds, (q, id) => q.stopIdEqualTo(id))
          .findAll();
      yield activities;
    }
  }

  Stream<List<Activity>> watchAllActivities() =>
      _isar.activitys.where().watch(fireImmediately: true);

  Future<int> saveActivity(Activity activity) =>
      _isar.writeTxn(() => _isar.activitys.put(activity));

  Future<void> deleteActivity(int id) =>
      _isar.writeTxn(() => _isar.activitys.delete(id));

  Future<List<Activity>> getActivitiesForStop(int stopId) =>
      _isar.activitys.filter().stopIdEqualTo(stopId).findAll();

  // ── Packing Items ──────────────────────────────────────────────────────────

  Stream<List<PackingItem>> watchPackingItems(int tripId) => _isar.packingItems
      .filter()
      .tripIdEqualTo(tripId)
      .watch(fireImmediately: true);

  Future<int> savePackingItem(PackingItem item) =>
      _isar.writeTxn(() => _isar.packingItems.put(item));

  Future<void> togglePackingItem(int id) async {
    final item = await _isar.packingItems.get(id);
    if (item == null) return;
    item.isPacked = !item.isPacked;
    await _isar.writeTxn(() => _isar.packingItems.put(item));
  }

  Future<void> deletePackingItem(int id) =>
      _isar.writeTxn(() => _isar.packingItems.delete(id));
}
