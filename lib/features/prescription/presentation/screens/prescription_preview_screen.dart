import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/core/theme/app_theme.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_drug_list_item.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_letterhead.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_qr_code.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_share_button.dart';
import 'package:my_clinic/features/prescription/presentation/widgets/prescription_signature_block.dart';
import 'package:share_plus/share_plus.dart';

/// Read-only view of a saved prescription, received via route arguments.
/// The share button exports the prescription as a PNG image (so Arabic
/// text and the clinic letterhead come out exactly as on screen) and hands
/// it to the phone's share sheet: WhatsApp, print, save to files, etc.
class PrescriptionPreviewScreen extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionPreviewScreen({super.key, required this.prescription});

  @override
  State<PrescriptionPreviewScreen> createState() =>
      _PrescriptionPreviewScreenState();
}

class _PrescriptionPreviewScreenState extends State<PrescriptionPreviewScreen> {
  final GlobalKey _paperKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;
    setState(() => _sharing = true);
    try {
      final boundary =
          _paperKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('PNG encoding failed');

      final p = widget.prescription;
      final fileName =
          'prescription_${DateFormat('yyyyMMdd').format(p.date)}_${p.id}.png';
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes.buffer.asUint8List(), mimeType: 'image/png'),
          ],
          fileNameOverrides: [fileName],
          subject: 'prescription.preview.share_subject'.tr(
            namedArgs: {'name': p.patientName},
          ),
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('prescription.preview.share_failed'.tr())),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('prescription.preview.title'.tr()),
        actions: [
          PrescriptionShareButton(onPressed: _share, isBusy: _sharing),
          horizontalSpace(8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        // A prescription is a paper document: always render it in the light
        // theme so the shared image looks right even in dark mode.
        child: Theme(
          data: AppTheme.light,
          child: RepaintBoundary(
            key: _paperKey,
            child: _PrescriptionPaper(prescription: widget.prescription),
          ),
        ).fadeInSlideUp(),
      ),
    );
  }
}

class _PrescriptionPaper extends StatelessWidget {
  final Prescription prescription;

  const _PrescriptionPaper({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.bodyMedium!,
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
                PrescriptionQrCode(prescription: prescription),
                horizontalSpace(12),
                const Flexible(child: PrescriptionSignatureBlock()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
