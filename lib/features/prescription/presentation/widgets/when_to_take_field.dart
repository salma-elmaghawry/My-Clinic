import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WhenToTakeField extends StatelessWidget {
  final String whenToTake;
  final ValueChanged<String> onChanged;

  const WhenToTakeField({
    super.key,
    required this.whenToTake,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: whenToTake,
      onChanged: onChanged,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: 'prescription.new.when_to_take_label'.tr(),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}
