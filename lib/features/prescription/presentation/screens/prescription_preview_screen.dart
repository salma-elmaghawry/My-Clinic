import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_drug_list_item.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_letterhead.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_qr_placeholder.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_share_button.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_signature_block.dart';

/// Receives its [Prescription] via route arguments — no cubit needed, this
/// screen is a pure read-only view of an already-generated prescription.
class PrescriptionPreviewScreen extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionPreviewScreen({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('prescription.preview.title'.tr()),
        actions: [
          const PrescriptionShareButton(),
          horizontalSpace(8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrescriptionLetterhead(prescription: prescription),
              verticalSpace(20),
              Text(
                'prescription.preview.diagnosis_label'.tr(),
                style: theme.textTheme.labelMedium,
              ),
              verticalSpace(4),
              Text(
                prescription.diagnosis,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.start,
              ),
              verticalSpace(16),
              Divider(color: theme.dividerColor),
              verticalSpace(8),
              ...prescription.drugs.asMap().entries.map(
                (entry) => PrescriptionDrugListItem(
                  index: entry.key + 1,
                  drug: entry.value,
                ),
              ),
              if (prescription.notes.isNotEmpty) ...[
                verticalSpace(12),
                Divider(color: theme.dividerColor),
                verticalSpace(8),
                Text(
                  'prescription.preview.notes_label'.tr(),
                  style: theme.textTheme.labelMedium,
                ),
                verticalSpace(4),
                ...prescription.notes.map(
                  (note) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      note,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ],
              verticalSpace(24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const PrescriptionQrPlaceholder(),
                  horizontalSpace(12),
                  const Flexible(child: PrescriptionSignatureBlock()),
                ],
              ),
            ],
          ),
        ).fadeInSlideUp(),
      ),
    );
  }
}
