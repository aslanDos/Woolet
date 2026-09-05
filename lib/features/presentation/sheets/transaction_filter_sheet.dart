import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/extensions/transaction_type_x.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

enum TransactionSort { newest, oldest, highestAmount, lowestAmount }

extension TransactionSortX on TransactionSort {
  String get label => switch (this) {
    TransactionSort.newest => 'Newest',
    TransactionSort.oldest => 'Oldest',
    TransactionSort.highestAmount => 'Highest amount',
    TransactionSort.lowestAmount => 'Lowest amount',
  };
}

@immutable
class TransactionFilter {
  const TransactionFilter({
    this.types = const {
      TransactionType.income,
      TransactionType.expense,
      TransactionType.transfer,
    },
    this.sort = TransactionSort.newest,
  });

  final Set<TransactionType> types;
  final TransactionSort sort;

  bool get isDefault =>
      types.length == TransactionType.values.length &&
      sort == TransactionSort.newest;
}

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({
    super.key,
    this.filter = const TransactionFilter(),
  });

  final TransactionFilter filter;

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late Set<TransactionType> _selectedTypes;
  late TransactionSort _sort;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.of(widget.filter.types);
    _sort = widget.filter.sort;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      // height: 430,
      title: Text(context.l10n.filterTransactions),
      leading: IconButton.filled(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(LucideIcons.x),
      ),
      footer: Row(
        children: [
          Expanded(
            child: Button(
              label: context.l10n.reset,
              backgroundColor: context.c.surfaceContainerHigh,
              foregroundColor: context.c.onSurface,
              onPressed: _reset,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Button(
              label: context.l10n.save,
              onPressed: _selectedTypes.isEmpty ? null : _save,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.transactionType, style: context.t.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              for (
                var index = 0;
                index < TransactionType.values.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(width: 4),
                Expanded(child: _buildTypeChip(TransactionType.values[index])),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Text(context.l10n.sortBy, style: context.t.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.5,
            children: TransactionSort.values.map(_buildSortChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(TransactionSort sort) {
    final selected = _sort == sort;

    return SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ChoiceChip(
          selected: selected,
          showCheckmark: false,
          label: SizedBox(
            width: double.infinity,
            child: Text(
              sort.label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          labelStyle: context.t.titleMedium?.copyWith(
            color: selected ? context.c.onPrimary : context.c.onSurfaceVariant,
          ),
          backgroundColor: context.c.surfaceContainer,
          selectedColor: context.c.primary,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (_) => setState(() => _sort = sort),
        ),
      ),
    );
  }

  Widget _buildTypeChip(TransactionType type) {
    final selected = _selectedTypes.contains(type);

    return SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: FilterChip(
          selected: selected,
          showCheckmark: false,
          label: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.icon,
                  size: 14,
                  color: selected
                      ? context.c.onPrimary
                      : context.c.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    type.localizedLabel(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          labelStyle: context.t.titleMedium?.copyWith(
            color: selected ? context.c.onPrimary : context.c.onSurfaceVariant,
          ),
          backgroundColor: context.c.surfaceContainer,
          selectedColor: context.c.primary,
          side: .none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedTypes.add(type);
              } else {
                _selectedTypes.remove(type);
              }
            });
          },
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _selectedTypes = TransactionType.values.toSet();
      _sort = TransactionSort.newest;
    });
  }

  void _save() {
    Navigator.pop(
      context,
      TransactionFilter(
        types: Set<TransactionType>.unmodifiable(_selectedTypes),
        sort: _sort,
      ),
    );
  }
}
