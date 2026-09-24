import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/helpers/spacing.dart';
import 'package:my_clinic/features/prescription/domain/entities/prescription.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR code holding a plain-text summary of the prescription, so a
/// pharmacist can scan the drug list instead of reading handwriting-style
/// text. Works offline: the data is in the code itself, not behind a link.
class PrescriptionQrCode extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionQrCode({super.key, required this.prescription});

  /// Longest summary we encode. Arabic text takes 2-3 bytes per character
  /// in a QR code, and very dense codes get hard to scan from paper.
  static const int _maxLength = 700;

  static String summaryFor(Prescription p) {
    final date = DateFormat('yyyy-MM-dd').format(p.date);
    final lines = <String>[
      '${p.patientName} · ${p.patientAge} · $date',
      'Dx: ${p.diagnosis}',
      ...p.drugs.asMap().entries.map((e) {
        final d = e.value;
        final parts = [
          d.drugName,
          d.dose,
          d.frequency,
          d.duration,
          d.whenToTake,
        ].where((s) => s.trim().isNotEmpty).join(' | ');
        return '${e.key + 1}. $parts';
      }),
    ];
    final text = lines.join('\n');
    return text.length <= _maxLength
        ? text
        : '${text.substring(0, _maxLength - 1)}…';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        QrImageView(
          data: summaryFor(prescription),
          size: 96.w,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
        ),
        verticalSpace(6),
        Text(
          'prescription.preview.qr_caption'.tr(),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
