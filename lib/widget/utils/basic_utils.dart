import 'package:intl/intl.dart';

String getFormattedTimeNew() {
  try {
    final now = DateTime.now();
    final twoHoursLater =
        now.add(const Duration(hours: 2)); // Add 2 hours to the current time
    final formatter = DateFormat('hh:mm aa');
    return formatter.format(twoHoursLater);
  } catch (e) {
    return '';
  }
}

String getFormattedTimeNow() {
  try {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm aa');
    return formatter.format(now);
  } catch (e) {
    return '';
  }
}
