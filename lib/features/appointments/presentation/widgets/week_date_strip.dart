import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/date_helpers.dart';

/// Seven-day strip for the week containing [selectedDate], with arrows to
/// move a week at a time and a dot under days that have appointments.
class WeekDateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Set<DateTime> busyDays;
  final ValueChanged<DateTime> onSelect;

  const WeekDateStrip({
    super.key,
    required this.selectedDate,
    required this.busyDays,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.toString();
    // Week starts on Saturday, the usual clinic week in Egypt and the region.
    final offset = (selectedDate.weekday - DateTime.saturday) % 7;
    final start = selectedDate.subtract(Duration(days: offset));
    final days = List.generate(
      7,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
    final today = DateTime.now();

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              onSelect(selectedDate.subtract(const Duration(days: 7))),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isSelected = day.isSameDay(selectedDate);
              final isToday = day.isSameDay(today);
              final fg = isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(day),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : null,
                      borderRadius: BorderRadius.circular(12.r),
                      border: isToday && !isSelected
                          ? Border.all(color: theme.colorScheme.primary)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat.E(locale).format(day),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: fg,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DateFormat.d(locale).format(day),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: fg,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: busyDays.contains(day)
                                ? (isSelected
                                      ? Colors.white
                                      : theme.colorScheme.secondary)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onSelect(selectedDate.add(const Duration(days: 7))),
        ),
      ],
    );
  }
}
