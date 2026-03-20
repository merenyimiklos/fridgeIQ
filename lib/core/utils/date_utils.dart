import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('MMM dd, yyyy');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatForDisplay(DateTime date) => _displayFormat.format(date);

  static int daysUntilExpiration(DateTime expirationDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      expirationDate.year,
      expirationDate.month,
      expirationDate.day,
    );
    return expiry.difference(today).inDays;
  }

  static bool isExpired(DateTime expirationDate) {
    return daysUntilExpiration(expirationDate) < 0;
  }

  static bool isExpiringSoon(DateTime expirationDate, {int warningDays = 3}) {
    final days = daysUntilExpiration(expirationDate);
    return days >= 0 && days <= warningDays;
  }

  static String expirationLabel(DateTime expirationDate) {
    final days = daysUntilExpiration(expirationDate);
    if (days < 0) return 'Expired ${-days} day${-days == 1 ? '' : 's'} ago';
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires tomorrow';
    return 'Expires in $days days';
  }
}
