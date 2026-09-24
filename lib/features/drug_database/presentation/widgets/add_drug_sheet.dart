import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/app_validators.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug_category.dart';

class NewDrugInput {
  final String name;
  final String genericName;
  final String commonDose;
  final DrugCategory category;
  final String defaultFrequency;
  final String defaultWhenToTake;

  const NewDrugInput({
    required this.name,
    required this.genericName,
    required this.commonDose,
    required this.category,
    required this.defaultFrequency,
    required this.defaultWhenToTake,
  });
}

Future<NewDrugInput?> showAddDrugSheet(BuildContext context) {
  return showModalBottomSheet<NewDrugInput>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _AddDrugSheet(),
  );
}

class _AddDrugSheet extends StatefulWidget {
  const _AddDrugSheet();

  @override
  State<_AddDrugSheet> createState() => _AddDrugSheetState();
}

class _AddDrugSheetState extends State<_AddDrugSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _generic = TextEditingController();
  final _dose = TextEditingController();
  final _frequency = TextEditingController();
  final _whenToTake = TextEditingController();
  DrugCategory _category = DrugCategory.other;

  @override
  void dispose() {
    for (final c in [_name, _generic, _dose, _frequency, _whenToTake]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _decoration(String key) => InputDecoration(
    labelText: key.tr(),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'drugs.add_title'.tr(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              verticalSpace(16),
              TextFormField(
                controller: _name,
                autofocus: true,
                decoration: _decoration('drugs.form.name'),
                validator: (v) => AppValidators.validateRequired(
                  v,
                  'drugs.form.name_required'.tr(),
                ),
              ),
              verticalSpace(12),
              TextFormField(
                controller: _generic,
                decoration: _decoration('drugs.form.generic'),
              ),
              verticalSpace(12),
              TextFormField(
                controller: _dose,
                decoration: _decoration('drugs.form.dose'),
              ),
              verticalSpace(12),
              DropdownButtonFormField<DrugCategory>(
                initialValue: _category,
                decoration: _decoration('drugs.form.category'),
                items: DrugCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('drugs.categories.${c.name}'.tr()),
                      ),
                    )
                    .toList(),
                onChanged: (c) =>
                    setState(() => _category = c ?? DrugCategory.other),
              ),
              verticalSpace(12),
              TextFormField(
                controller: _frequency,
                decoration: _decoration('drugs.form.frequency'),
              ),
              verticalSpace(12),
              TextFormField(
                controller: _whenToTake,
                decoration: _decoration('drugs.form.when_to_take'),
              ),
              verticalSpace(20),
              FilledButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.of(context).pop(
                    NewDrugInput(
                      name: _name.text,
                      genericName: _generic.text,
                      commonDose: _dose.text,
                      category: _category,
                      defaultFrequency: _frequency.text,
                      defaultWhenToTake: _whenToTake.text,
                    ),
                  );
                },
                child: Text('common.save'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
