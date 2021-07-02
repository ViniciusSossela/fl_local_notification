extension MonetaryParsing on String {
  double? fromMonetaryToDouble() {
    return double.tryParse(replaceAll('.', '').replaceAll(',', '.'));
  }

  String removeAllButLast(String token) {
    final parts = split(token);
    return parts.length > 1
        ? parts.sublist(0, parts.length - 1).join('') +
            token +
            parts.sublist(parts.length - 1).join('')
        : this;
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get setToSixHours {
    return DateTime(year, month, day, 6, 0, 0);
  }
}
