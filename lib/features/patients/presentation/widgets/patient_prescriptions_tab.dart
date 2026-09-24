import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/extensions.dart';
import 'package:my_clinic/core/routes/routes.dart';
import 'package:my_clinic/core/theme/app_colors.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/presentation/screens/new_prescription_args.dart';

/// Every prescription written for this patient, newest first. Tapping a
/// generated one reopens its preview (to share again); tapping a draft
/// reopens it in the editor.
class PatientPrescriptionsTab extends StatelessWidget {
  final List<Prescription> prescriptions;

  const PatientPrescriptionsTab({super.key, required this.prescriptions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (prescriptions.isEmpty) {
      return Center(child: Text('patients.detail.prescriptions.empty'.tr()));
    }
    final dateFormat = DateFormat.yMMMd(context.locale.toString());
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final p = prescriptions[index];
        final badgeColor = p.isDraft ? AppColors.warning : AppColors.success;
        return Card(
          margin: EdgeInsets.only(bottom: 10.h),
          child: ListTile(
            leading: Icon(
              Icons.receipt_long_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              p.diagnosis,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${dateFormat.format(p.date)} · '
              '${'patients.detail.prescriptions.drug_count'.tr(namedArgs: {'count': '${p.drugs.length}'})}',
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'prescription.status.${p.status.name}'.tr(),
                style: theme.textTheme.labelSmall?.copyWith(color: badgeColor),
              ),
            ),
            onTap: () => p.isDraft
                ? context.pushNamed(
                    Routes.newPrescription,
                    arguments: NewPrescriptionArgs.fromDraft(p),
                  )
                : context.pushNamed(Routes.prescriptionPreview, arguments: p),
          ),
        );
      },
    );
  }
}
