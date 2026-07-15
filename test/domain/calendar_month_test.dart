import 'package:fittin_v2/src/domain/calendar_month.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarMonthBuilder', () {
    const builder = CalendarMonthBuilder();

    test('builds complete weeks with leading and trailing dates', () {
      final month = builder.build(
        focusedMonth: DateTime(2024, 2, 18),
        today: DateTime(2024, 2, 29),
        recordedDates: [
          DateTime(2024, 2, 1, 6, 30),
          DateTime(2024, 2, 29, 22, 15),
        ],
      );

      expect(month.focusedMonth, DateTime(2024, 2));
      expect(month.weeks, hasLength(5));
      expect(month.days, hasLength(35));
      expect(month.days.first.date, DateTime(2024, 1, 29));
      expect(month.days.last.date, DateTime(2024, 3, 3));
      expect(month.days.first.isInMonth, isFalse);
      expect(month.days.last.isInMonth, isFalse);
      expect(
        month.days.singleWhere((day) => day.date == DateTime(2024, 2, 29)),
        isA<CalendarDay>()
            .having((day) => day.isInMonth, 'isInMonth', isTrue)
            .having((day) => day.isToday, 'isToday', isTrue)
            .having((day) => day.isRecorded, 'isRecorded', isTrue),
      );
    });

    test('renders a historical month without a recent-range cutoff', () {
      final month = builder.build(
        focusedMonth: DateTime(2026, 1, 20),
        today: DateTime(2026, 3, 20),
        recordedDates: [DateTime(2026, 1, 7, 23, 59)],
      );

      final recorded = month.days.where((day) => day.isRecorded).toList();
      expect(recorded, hasLength(1));
      expect(recorded.single.date, DateTime(2026, 1, 7));
      expect(recorded.single.isInMonth, isTrue);
    });

    test('produces valid four, five, and six week grids', () {
      final fourWeeks = builder.build(
        focusedMonth: DateTime(2021, 2),
        today: DateTime(2021, 1),
      );
      final fiveWeeks = builder.build(
        focusedMonth: DateTime(2024, 4),
        today: DateTime(2024, 1),
      );
      final sixWeeks = builder.build(
        focusedMonth: DateTime(2020, 8),
        today: DateTime(2020, 1),
      );

      expect(fourWeeks.weeks, hasLength(4));
      expect(fiveWeeks.weeks, hasLength(5));
      expect(sixWeeks.weeks, hasLength(6));
      expect(
        [
          ...fourWeeks.weeks,
          ...fiveWeeks.weeks,
          ...sixWeeks.weeks,
        ].every((week) => week.days.length == 7),
        isTrue,
      );
    });

    test('localizes month and Monday-first weekday labels', () {
      final english = builder.build(
        focusedMonth: DateTime(2026, 3),
        today: DateTime(2026, 1),
        localeCode: 'en_US',
      );
      final chinese = builder.build(
        focusedMonth: DateTime(2026, 3),
        today: DateTime(2026, 1),
        localeCode: 'zh-CN',
      );

      expect(english.label, 'March 2026');
      expect(english.weekdayLabels, [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ]);
      expect(chinese.label, '2026年3月');
      expect(chinese.weekdayLabels, ['周一', '周二', '周三', '周四', '周五', '周六', '周日']);
    });

    test('supports an injected display formatter', () {
      final customBuilder = CalendarMonthBuilder(
        monthLabelFormatter: (month, locale) =>
            '$locale:${month.year}/${month.month}',
        weekdayLabelFormatter: (weekday, locale) => '$locale:$weekday',
      );

      final month = customBuilder.build(
        focusedMonth: DateTime(2026, 7),
        today: DateTime(2026, 1),
        localeCode: 'custom',
      );

      expect(month.label, 'custom:2026/7');
      expect(month.weekdayLabels.first, 'custom:1');
      expect(month.weekdayLabels.last, 'custom:7');
    });

    test('can arrange labels and dates from another valid week start', () {
      final month = builder.build(
        focusedMonth: DateTime(2026, 3),
        today: DateTime(2026, 1),
        firstDayOfWeek: DateTime.sunday,
      );

      expect(month.weekdayLabels.first, 'Sun');
      expect(month.days.first.date.weekday, DateTime.sunday);
      expect(month.days.last.date.weekday, DateTime.saturday);
    });

    test('rejects an invalid first weekday', () {
      expect(
        () => builder.build(focusedMonth: DateTime(2026, 3), firstDayOfWeek: 0),
        throwsRangeError,
      );
    });
  });

  group('CalendarMonthSelection', () {
    test('navigates previous and next across year boundaries', () {
      final december = CalendarMonthSelection(DateTime(2026, 12, 15));
      final january = december.next();

      expect(january.focusedMonth, DateTime(2027, 1));
      expect(january.previous().focusedMonth, DateTime(2026, 12));
      expect(
        CalendarMonthSelection(DateTime(2026, 1)).previous().focusedMonth,
        DateTime(2025, 12),
      );
    });

    test('jumps to today and reports whether it is current', () {
      final selection = CalendarMonthSelection(DateTime(2024, 2));
      final current = selection.jumpToToday(now: DateTime(2026, 7, 15));

      expect(current.focusedMonth, DateTime(2026, 7));
      expect(current.isCurrentMonth(now: DateTime(2026, 7, 31)), isTrue);
      expect(current.isCurrentMonth(now: DateTime(2026, 8, 1)), isFalse);
    });
  });
}
