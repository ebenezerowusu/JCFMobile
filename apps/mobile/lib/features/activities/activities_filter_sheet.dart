import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import 'activity_models.dart';

const _muted = Color(0xFF54689B);

/// The advanced filter sheet.
///
/// It edits a *draft* and only hands it back when "Show results" is
/// pressed, so half-made choices never reload the list behind the sheet and
/// dismissing it really does cancel.
class ActivitiesFilterSheet extends StatefulWidget {
  const ActivitiesFilterSheet({
    super.key,
    required this.initial,
    required this.available,
  });

  final ActivityQuery initial;
  final AvailableFilters available;

  @override
  State<ActivitiesFilterSheet> createState() =>
      _ActivitiesFilterSheetState();

  /// Returns the chosen filters, or null when the sheet was dismissed.
  static Future<ActivityQuery?> show(
    BuildContext context, {
    required ActivityQuery initial,
    required AvailableFilters available,
  }) =>
      showModalBottomSheet<ActivityQuery>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => ActivitiesFilterSheet(
            initial: initial, available: available),
      );
}

class _ActivitiesFilterSheetState extends State<ActivitiesFilterSheet> {
  late ActivityQuery _draft = widget.initial;

  void _toggle(Set<String> current, String value,
      ActivityQuery Function(Set<String>) apply) {
    final next = {...current};
    if (!next.remove(value)) next.add(value);
    setState(() => _draft = apply(next));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8E0EE),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.activitiesFiltersTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: JcfColors.inkOnLight,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _draft.advancedCount == 0
                        ? null
                        : () => setState(
                            () => _draft = _draft.clearedAdvanced()),
                    child: Text(t.activitiesFilterClearAll),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                children: [
                  if (widget.available.types.isNotEmpty)
                    _group(
                      t.activitiesFilterTypeGroup,
                      [
                        for (final facet in widget.available.types)
                          _chip(
                            label: '${facet.label} (${facet.count})',
                            selected: _draft.types.contains(facet.value),
                            onTap: () => _toggle(
                              _draft.types,
                              facet.value,
                              (next) => _draft.copyWith(types: next),
                            ),
                          ),
                      ],
                    ),
                  if (widget.available.languages.length > 1)
                    _group(
                      t.activitiesFilterLanguageGroup,
                      [
                        for (final facet in widget.available.languages)
                          _chip(
                            label: '${facet.label} (${facet.count})',
                            selected:
                                _draft.languages.contains(facet.value),
                            onTap: () => _toggle(
                              _draft.languages,
                              facet.value,
                              (next) => _draft.copyWith(languages: next),
                            ),
                          ),
                      ],
                    ),
                  _group(
                    t.activitiesFilterFeeGroup,
                    [
                      for (final entry in <(FeeFilter, String)>[
                        (FeeFilter.any, t.activitiesFilterFeeAny),
                        (FeeFilter.free, t.activitiesFilterFeeFree),
                        (FeeFilter.paid, t.activitiesFilterFeePaid),
                      ])
                        _chip(
                          label: entry.$2,
                          selected: _draft.fee == entry.$1,
                          onTap: () => setState(
                              () => _draft = _draft.copyWith(fee: entry.$1)),
                        ),
                    ],
                  ),
                  _group(
                    t.activitiesFilterAccessGroup,
                    [
                      _chip(
                        label: t.activitiesFilterOpenToMe,
                        selected: _draft.openToMeOnly,
                        onTap: () => setState(() => _draft = _draft.copyWith(
                            openToMeOnly: !_draft.openToMeOnly)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 6, 20, 16 + media.viewInsets.bottom),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_draft),
                  style: FilledButton.styleFrom(
                    backgroundColor: JcfColors.skyPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: Text(t.activitiesFilterApply),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(String title, List<Widget> chips) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: JcfColors.inkOnLight,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],
        ),
      );

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected
                  ? JcfColors.skyPrimary
                  : const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? JcfColors.skyPrimary
                    : const Color(0xFFE3EAF7),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _muted,
              ),
            ),
          ),
        ),
      );
}
