import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/widgets/confirm_dialog.dart';
import 'package:my_clinic/features/drug_database/presentation/cubit/drug_database_cubit.dart';
import 'package:my_clinic/features/drug_database/presentation/widgets/add_drug_sheet.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug.dart';

class DrugDatabaseScreen extends StatefulWidget {
  const DrugDatabaseScreen({super.key});

  @override
  State<DrugDatabaseScreen> createState() => _DrugDatabaseScreenState();
}

class _DrugDatabaseScreenState extends State<DrugDatabaseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DrugDatabaseCubit>().load();
  }

  Future<void> _add() async {
    final cubit = context.read<DrugDatabaseCubit>();
    final input = await showAddDrugSheet(context);
    if (input == null) return;
    await cubit.addCustomDrug(
      name: input.name,
      genericName: input.genericName,
      commonDose: input.commonDose,
      category: input.category,
      defaultFrequency: input.defaultFrequency,
      defaultWhenToTake: input.defaultWhenToTake,
    );
  }

  Future<void> _delete(Drug drug) async {
    final cubit = context.read<DrugDatabaseCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'drugs.delete_confirm.title'.tr(),
      message: 'drugs.delete_confirm.message'.tr(
        namedArgs: {'name': drug.name},
      ),
    );
    if (confirmed) await cubit.deleteCustomDrug(drug);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('home.quick_nav.drug_database'.tr())),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text('drugs.add'.tr()),
      ),
      body: SafeArea(
        child: BlocBuilder<DrugDatabaseCubit, DrugDatabaseState>(
          builder: (context, state) {
            final cubit = context.read<DrugDatabaseCubit>();
            final drugs = state.visibleDrugs;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: TextField(
                    onChanged: cubit.setQuery,
                    decoration: InputDecoration(
                      hintText: 'prescription.new.drug_search_hint'.tr(),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 44.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: 8.w),
                        child: ChoiceChip(
                          label: Text('drugs.all'.tr()),
                          selected: state.category == null,
                          onSelected: (_) => cubit.setCategory(null),
                        ),
                      ),
                      ...state.availableCategories.map(
                        (c) => Padding(
                          padding: EdgeInsetsDirectional.only(end: 8.w),
                          child: ChoiceChip(
                            label: Text('drugs.categories.${c.name}'.tr()),
                            selected: state.category == c,
                            onSelected: (_) => cubit.setCategory(c),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(4),
                Expanded(
                  child: state.isLoading && state.drugs.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : drugs.isEmpty
                      ? Center(child: Text('common.no_data'.tr()))
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 88.h),
                          itemCount: drugs.length,
                          itemBuilder: (context, index) {
                            final drug = drugs[index];
                            final details = [
                              drug.genericName,
                              drug.commonDose,
                              drug.defaultFrequency ?? '',
                            ].where((s) => s.isNotEmpty).join(' · ');
                            return Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              child: ListTile(
                                leading: Icon(
                                  Icons.medication_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                title: Text(drug.name),
                                subtitle: Text(
                                  [
                                    'drugs.categories.${drug.category.name}'
                                        .tr(),
                                    if (details.isNotEmpty) details,
                                  ].join('\n'),
                                ),
                                isThreeLine: details.isNotEmpty,
                                trailing: drug.isCustom
                                    ? IconButton(
                                        tooltip: 'common.delete'.tr(),
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _delete(drug),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
