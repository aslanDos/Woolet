import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/widgets/app_empty_state.dart';
import 'package:woolet/core/models/currency_info.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({
    super.key,
    required this.currencies,
    required this.selected,
  });

  final List<CurrencyInfo> currencies;
  final CurrencyInfo selected;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final currencies = normalizedQuery.isEmpty
        ? widget.currencies
        : widget.currencies
              .where(
                (currency) =>
                    currency.code.toLowerCase().contains(normalizedQuery) ||
                    currency.name.toLowerCase().contains(normalizedQuery) ||
                    currency.symbol.toLowerCase().contains(normalizedQuery),
              )
              .toList(growable: false);

    return CustomBottomSheet(
      safeAreaBottom: false,
      height: MediaQuery.sizeOf(context).height * 0.78,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.selectCurrency, style: context.t.headlineMedium),
          const SizedBox(height: 16),
          TextField(
            autofocus: false,
            autocorrect: false,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            style: context.t.titleMedium,
            decoration: InputDecoration(
              hintStyle: context.t.titleMedium?.copyWith(
                color: context.c.onSurfaceVariant,
              ),
              hintText: context.l10n.search,
              prefixIcon: const Icon(LucideIcons.search, size: 16),
              filled: true,
              fillColor: context.c.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (currencies.isEmpty)
            AppEmptyState(
              icon: LucideIcons.search_x,
              title: context.l10n.noCurrenciesFound,
              compact: true,
            )
          else
            ...currencies.map(
              (currency) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CurrencyOption(
                  currency: currency,
                  selected: currency.code == widget.selected.code,
                  onTap: () => Navigator.pop(context, currency),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  const _CurrencyOption({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  final CurrencyInfo currency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = selected
        ? context.c.onPrimaryContainer
        : context.c.onSurface;

    return Material(
      color: selected ? context.c.primaryContainer : context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  currency.symbol,
                  style: context.t.titleLarge?.copyWith(color: foregroundColor),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.code,
                      style: context.t.titleMedium?.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                    Text(
                      currency.name,
                      style: context.t.bodySmall?.copyWith(
                        color: selected
                            ? foregroundColor.withValues(alpha: 0.72)
                            : context.c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(LucideIcons.check, size: 18, color: foregroundColor),
            ],
          ),
        ),
      ),
    );
  }
}
