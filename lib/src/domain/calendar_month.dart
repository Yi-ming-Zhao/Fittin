typedef CalendarMonthLabelFormatter =
    String Function(DateTime month, String localeCode);

typedef CalendarWeekdayLabelFormatter =
    String Function(int weekday, String localeCode);

/// A single local calendar date rendered in a month grid.
class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.isInMonth,
    required this.isToday,
    required this.isRecorded,
  });

  final DateTime date;
  final bool isInMonth;
  final bool isToday;
  final bool isRecorded;
}

/// A complete calendar week in display order.
class CalendarWeek {
  CalendarWeek(Iterable<CalendarDay> days)
    : days = List<CalendarDay>.unmodifiable(days) {
    if (this.days.length != DateTime.daysPerWeek) {
      throw ArgumentError.value(
        this.days.length,
        'days',
        'A calendar week must contain exactly seven days.',
      );
    }
  }

  final List<CalendarDay> days;
}

/// A complete 4-, 5-, or 6-week calendar grid for one focused month.
class CalendarMonth {
  CalendarMonth({
    required this.focusedMonth,
    required this.label,
    required List<String> weekdayLabels,
    required List<CalendarWeek> weeks,
    required this.firstDayOfWeek,
  }) : weekdayLabels = List<String>.unmodifiable(weekdayLabels),
       weeks = List<CalendarWeek>.unmodifiable(weeks) {
    if (this.weekdayLabels.length != DateTime.daysPerWeek) {
      throw ArgumentError.value(
        this.weekdayLabels.length,
        'weekdayLabels',
        'A calendar month must contain exactly seven weekday labels.',
      );
    }
  }

  /// The first day of the focused month.
  final DateTime focusedMonth;
  final String label;
  final List<String> weekdayLabels;
  final List<CalendarWeek> weeks;
  final int firstDayOfWeek;

  List<CalendarDay> get days =>
      List<CalendarDay>.unmodifiable(weeks.expand((week) => week.days));

  DateTime get previousMonth =>
      DateTime(focusedMonth.year, focusedMonth.month - 1);

  DateTime get nextMonth => DateTime(focusedMonth.year, focusedMonth.month + 1);
}

/// Pure selected-month state that is safe to keep in any state container.
class CalendarMonthSelection {
  CalendarMonthSelection(DateTime focusedMonth)
    : focusedMonth = CalendarMonthBuilder.monthOf(focusedMonth);

  CalendarMonthSelection.today({DateTime? now})
    : focusedMonth = CalendarMonthBuilder.monthOf(now ?? DateTime.now());

  final DateTime focusedMonth;

  CalendarMonthSelection previous() => CalendarMonthSelection(
    DateTime(focusedMonth.year, focusedMonth.month - 1),
  );

  CalendarMonthSelection next() => CalendarMonthSelection(
    DateTime(focusedMonth.year, focusedMonth.month + 1),
  );

  CalendarMonthSelection jumpToToday({DateTime? now}) =>
      CalendarMonthSelection.today(now: now);

  bool isCurrentMonth({DateTime? now}) =>
      focusedMonth == CalendarMonthBuilder.monthOf(now ?? DateTime.now());
}

/// Builds complete month grids without depending on workout providers or UI.
class CalendarMonthBuilder {
  const CalendarMonthBuilder({
    this.monthLabelFormatter,
    this.weekdayLabelFormatter,
  });

  final CalendarMonthLabelFormatter? monthLabelFormatter;
  final CalendarWeekdayLabelFormatter? weekdayLabelFormatter;

  CalendarMonth build({
    required DateTime focusedMonth,
    Iterable<DateTime> recordedDates = const [],
    DateTime? today,
    int firstDayOfWeek = DateTime.monday,
    String localeCode = 'en',
  }) {
    if (firstDayOfWeek < DateTime.monday || firstDayOfWeek > DateTime.sunday) {
      throw RangeError.range(
        firstDayOfWeek,
        DateTime.monday,
        DateTime.sunday,
        'firstDayOfWeek',
      );
    }

    final month = monthOf(focusedMonth);
    final currentDay = dateOf(today ?? DateTime.now());
    final recordedDays = recordedDates.map(dateOf).toSet();
    final leadingDayCount =
        (month.weekday - firstDayOfWeek + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final requiredDayCount = leadingDayCount + daysInMonth;
    final gridDayCount =
        ((requiredDayCount + DateTime.daysPerWeek - 1) ~/
            DateTime.daysPerWeek) *
        DateTime.daysPerWeek;
    final gridStart = DateTime(month.year, month.month, 1 - leadingDayCount);

    final days = List<CalendarDay>.generate(gridDayCount, (index) {
      final date = DateTime(
        gridStart.year,
        gridStart.month,
        gridStart.day + index,
      );
      return CalendarDay(
        date: date,
        isInMonth: date.year == month.year && date.month == month.month,
        isToday: date == currentDay,
        isRecorded: recordedDays.contains(date),
      );
    });

    final weeks = <CalendarWeek>[
      for (var index = 0; index < days.length; index += DateTime.daysPerWeek)
        CalendarWeek(days.sublist(index, index + DateTime.daysPerWeek)),
    ];
    final weekdays = List<String>.generate(DateTime.daysPerWeek, (index) {
      final weekday =
          ((firstDayOfWeek - DateTime.monday + index) % DateTime.daysPerWeek) +
          DateTime.monday;
      return weekdayLabelFormatter?.call(weekday, localeCode) ??
          _defaultWeekdayLabel(weekday, localeCode);
    });

    return CalendarMonth(
      focusedMonth: month,
      label:
          monthLabelFormatter?.call(month, localeCode) ??
          _defaultMonthLabel(month, localeCode),
      weekdayLabels: weekdays,
      weeks: weeks,
      firstDayOfWeek: firstDayOfWeek,
    );
  }

  static DateTime dateOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime monthOf(DateTime date) => DateTime(date.year, date.month);
}

String _defaultMonthLabel(DateTime month, String localeCode) {
  if (_isChinese(localeCode)) {
    return '${month.year}年${month.month}月';
  }

  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${monthNames[month.month - 1]} ${month.year}';
}

String _defaultWeekdayLabel(int weekday, String localeCode) {
  if (_isChinese(localeCode)) {
    const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return labels[weekday - DateTime.monday];
  }

  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[weekday - DateTime.monday];
}

bool _isChinese(String localeCode) =>
    localeCode.toLowerCase().replaceAll('-', '_').startsWith('zh');
