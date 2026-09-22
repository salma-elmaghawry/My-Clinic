import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrugDurationField extends StatelessWidget {
  final String duration;
  final ValueChanged<String> onChanged;

  const DrugDurationField({
    super.key,
    required this.duration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: duration,
      onChanged: onChanged,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: 'prescription.new.duration_label'.tr(),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}
