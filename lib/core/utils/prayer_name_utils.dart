/// Utility to convert 'যোহর' related text to 'জুম'আ' on Fridays.
/// Data keys remain 'যোহর' — only display text changes.
String fridayAwareDisplay(String text, {DateTime? date}) {
  final d = date ?? DateTime.now();
  if (d.weekday != DateTime.friday) return text;
  return text
      .replaceAll('যোহরের', 'জুম\'আর')
      .replaceAll('যোহর', 'জুম\'আ');
}

/// On Fridays, Dhuhr sunnah after prayer is 4 rakats instead of 2.
/// Converts '২ রাকাত সুন্নাত (পরে)' → '৪ রাকাত সুন্নাত (পরে)' for display on Fridays.
String fridayAwareRakat(String prayer, String rakatKey, {DateTime? date}) {
  final d = date ?? DateTime.now();
  if (d.weekday == DateTime.friday &&
      prayer == 'যোহর' &&
      rakatKey == '২ রাকাত সুন্নাত (পরে)') {
    return '৪ রাকাত সুন্নাত (পরে)';
  }
  return rakatKey;
}
