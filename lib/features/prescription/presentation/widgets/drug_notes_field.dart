import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrugNotesField extends StatelessWidget {
  final String? notes;
  final ValueChanged<String> onChanged;

  const DrugNotesField({super.key, this.notes, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: notes,
      onChanged: onChanged,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: 'prescription.new.notes_label'.tr(),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}
