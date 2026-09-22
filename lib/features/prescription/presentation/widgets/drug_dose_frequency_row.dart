import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dr_ahmed/core/helpers/spacing.dart';

class DrugDoseFrequencyRow extends StatelessWidget {
  final String dose;
  final String frequency;
  final ValueChanged<String> onDoseChanged;
  final ValueChanged<String> onFrequencyChanged;

  const DrugDoseFrequencyRow({
    super.key,
    required this.dose,
    required this.frequency,
    required this.onDoseChanged,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: dose,
            onChanged: onDoseChanged,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              labelText: 'prescription.new.dose_label'.tr(),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: TextFormField(
            initialValue: frequency,
            onChanged: onFrequencyChanged,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              labelText: 'prescription.new.frequency_label'.tr(),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
      ],
    );
  }
}
