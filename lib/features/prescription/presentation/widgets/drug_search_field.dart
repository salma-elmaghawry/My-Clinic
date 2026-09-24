import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clinic/core/animations/animations.dart';
import 'package:my_clinic/features/prescription/domain/entities/drug.dart';

class DrugSearchField extends StatefulWidget {
  final List<Drug> results;
  final ValueChanged<String> onChanged;
  final ValueChanged<Drug> onSelect;

  /// Called with the typed text when the doctor adds a drug that isn't in
  /// the list yet.
  final ValueChanged<String> onAddCustom;

  const DrugSearchField({
    super.key,
    required this.results,
    required this.onChanged,
    required this.onSelect,
    required this.onAddCustom,
  });

  @override
  State<DrugSearchField> createState() => _DrugSearchFieldState();
}

class _DrugSearchFieldState extends State<DrugSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _controller.text.trim();
    final hasExactMatch = widget.results.any(
      (d) => d.name.toLowerCase() == query.toLowerCase(),
    );
    final showAddCustom = query.isNotEmpty && !hasExactMatch;
    final showList =
        query.isNotEmpty && (widget.results.isNotEmpty || showAddCustom);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: (value) {
            setState(() {});
            widget.onChanged(value);
          },
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: 'prescription.new.drug_search_hint'.tr(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _clear();
                      setState(() {});
                    },
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        if (showList)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            constraints: BoxConstraints(maxHeight: 240.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              children: [
                if (showAddCustom)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.add_box_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'prescription.new.add_custom_drug'.tr(
                        namedArgs: {'name': query},
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    onTap: () {
                      widget.onAddCustom(query);
                      _clear();
                    },
                  ),
                ...widget.results.map(
                  (drug) => ListTile(
                    dense: true,
                    title: Text(drug.name, style: theme.textTheme.bodyMedium),
                    subtitle: Text(
                      [
                        drug.genericName,
                        drug.commonDose,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      widget.onSelect(drug);
                      _clear();
                    },
                  ),
                ),
              ],
            ),
          ).fadeInSlideUp(),
      ],
    );
  }
}
