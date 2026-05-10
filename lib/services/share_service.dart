import 'package:share_plus/share_plus.dart';
import '../models/activity.dart';
import '../models/trip.dart';
import 'isar_service.dart';

class ShareService {
  static Future<void> shareItinerary(Trip trip) async {
    final stops = await IsarService().getStopsForTrip(trip.id);
    stops.sort((a, b) => a.date.compareTo(b.date));

    final buf = StringBuffer();
    double grandTotal = 0;

    buf.writeln('✈️  ${trip.name}');
    buf.writeln('📍 ${trip.destination}');
    buf.writeln('🗓  ${_fmt(trip.startDate)} → ${_fmt(trip.endDate)}'
        '  (${_dayCount(trip)} days)');
    buf.writeln();

    if (stops.isEmpty) {
      buf.writeln('No stops planned yet.');
    } else {
      for (final stop in stops) {
        buf.writeln('─────────────────────');
        buf.writeln('📌 ${stop.city}  •  ${_fmt(stop.date)}');

        final activities = await IsarService().getActivitiesForStop(stop.id);
        activities.sort((a, b) => a.time.compareTo(b.time));

        if (activities.isEmpty) {
          buf.writeln('   No activities yet.');
        } else {
          for (final act in activities) {
            grandTotal += _parsePrice(act.price);
            buf.writeln(_activityLine(act));
          }
        }
        buf.writeln();
      }
    }

    buf.writeln('─────────────────────');
    final costStr = grandTotal > 0
        ? '\$${grandTotal.toStringAsFixed(0)}'
        : 'Not specified';
    buf.writeln('💰 Total estimated cost: $costStr');
    buf.writeln();
    buf.writeln('Shared via Traveloop 🌍');

    await Share.share(
      buf.toString(),
      subject: '${trip.name} — Itinerary',
    );
  }

  static double _parsePrice(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty || s == 'free' || s == 'n/a' || s == 'varies') return 0;
    final match = RegExp(r'(\d{1,6}(?:\.\d{1,2})?)').firstMatch(raw);
    if (match == null) return 0;
    final value = double.tryParse(match.group(1)!) ?? 0;
    return value > 9999 ? 0 : value;
  }

  static String _activityLine(Activity act) {
    final time = act.time.isNotEmpty ? '${act.time}  ' : '';
    final price = act.price.isNotEmpty && act.price.toLowerCase() != 'free'
        ? '  (${act.price})'
        : '';
    return '   ${_emoji(act.category)} $time${act.title}$price';
  }

  static String _emoji(String cat) {
    switch (cat) {
      case 'Food':          return '🍽';
      case 'Adventure':     return '🏄';
      case 'Transport':     return '🚌';
      case 'Accommodation': return '🏨';
      case 'Sightseeing':   return '📸';
      default:              return '📌';
    }
  }

  static String _fmt(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}';

  static int _dayCount(Trip t) =>
      t.endDate.difference(t.startDate).inDays.abs() + 1;

  static String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
