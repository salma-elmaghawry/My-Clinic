import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiagnosisField extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const DiagnosisField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      maxLines: 2,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: 'prescription.new.diagnosis_label'.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
