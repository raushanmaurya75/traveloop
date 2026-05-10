import '../models/activity.dart';
import '../models/stop.dart';
import '../models/trip.dart';
import 'isar_service.dart';

class TripParser {
  static const _knownCategories = {
    'Sightseeing', 'Food', 'Adventure', 'Transport', 'Accommodation', 'Other'
  };

  /// Maps Groq's freeform category strings to our fixed set.
  static String _normalizeCategory(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.contains('food') || s.contains('eat') || s.contains('restaurant') ||
        s.contains('dining') || s.contains('cafe') || s.contains('drink') ||
        s.contains('cuisine') || s.contains('lunch') || s.contains('dinner') ||
        s.contains('breakfast') || s.contains('snack')) return 'Food';
    if (s.contains('transport') || s.contains('flight') || s.contains('train') ||
        s.contains('bus') || s.contains('taxi') || s.contains('ferry') ||
        s.contains('transfer') || s.contains('drive') || s.contains('car')) return 'Transport';
    if (s.contains('hotel') || s.contains('accommodation') || s.contains('hostel') ||
        s.contains('resort') || s.contains('stay') || s.contains('lodge') ||
        s.contains('airbnb') || s.contains('motel')) return 'Accommodation';
    if (s.contains('adventure') || s.contains('sport') || s.contains('hike') ||
        s.contains('trek') || s.contains('surf') || s.contains('dive') ||
        s.contains('climb') || s.contains('kayak') || s.contains('bike') ||
        s.contains('outdoor') || s.contains('activity')) return 'Adventure';
    if (s.contains('sight') || s.contains('tour') || s.contains('museum') ||
        s.contains('landmark') || s.contains('temple') || s.contains('monument') ||
        s.contains('gallery') || s.contains('park') || s.contains('beach') ||
        s.contains('castle') || s.contains('palace') || s.contains('market') ||
        s.contains('cultural') || s.contains('historic') || s.contains('visit') ||
        s.contains('attraction') || s.contains('explore')) return 'Sightseeing';
    // If it's already a known category, keep it
    for (final known in _knownCategories) {
      if (s == known.toLowerCase()) return known;
    }
    return 'Other';
  }

  /// Sanitizes price strings — keeps only the first numeric value.
  static String _normalizePrice(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty || s == 'free' || s == 'n/a' || s == 'varies' ||
        s == 'included' || s == 'complimentary') return 'Free';
    final match = RegExp(r'(\d{1,6}(?:\.\d{1,2})?)').firstMatch(raw);
    if (match == null) return 'Free';
    final value = double.tryParse(match.group(1)!) ?? 0;
    if (value == 0 || value > 9999) return 'Free';
    return '\$${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  static Future<Trip> parseAndSave({
    required Map<String, dynamic> json,
    required String tripName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final trip = Trip()
      ..name = tripName
      ..destination = destination
      ..startDate = startDate
      ..endDate = endDate;

    final tripId = await IsarService().saveTrip(trip);
    trip.id = tripId;

    final rawStops = json['stops'] as List<dynamic>? ?? [];

    for (final rawStop in rawStops) {
      final stop = Stop()
        ..tripId = tripId
        ..city = rawStop['city'] as String? ?? destination
        ..date = DateTime.tryParse(rawStop['date'] as String? ?? '') ?? startDate;

      final stopId = await IsarService().saveStop(stop);

      final rawActivities = rawStop['activities'] as List<dynamic>? ?? [];
      for (final raw in rawActivities) {
        final activity = Activity()
          ..stopId = stopId
          ..title = raw['title'] as String? ?? ''
          ..category = _normalizeCategory(raw['category'] as String? ?? '')
          ..time = raw['time'] as String? ?? ''
          ..price = _normalizePrice(raw['price'] as String? ?? '')
          ..description = raw['description'] as String? ?? '';
        await IsarService().saveActivity(activity);
      }
    }

    return trip;
  }
}
