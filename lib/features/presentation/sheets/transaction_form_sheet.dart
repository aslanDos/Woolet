import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/transaction_category.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/transaction_type_x.dart';
import 'package:woolet/features/presentation/widgets/account_selector.dart';
import 'package:woolet/features/presentation/widgets/amount_field.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/category_selector.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/date_selector.dart';
import 'package:woolet/features/presentation/widgets/note_field.dart';
import 'package:woolet/features/presentation/widgets/type_toggle.dart';

class TransactionFormSheet extends StatelessWidget {
  const TransactionFormSheet({
    super.key,
    this.initialTransactionType = TransactionType.expense,
  });

  final TransactionType initialTransactionType;

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      height: MediaQuery.sizeOf(context).height * 0.9,
      footer: Button(label: 'Save', onPressed: () {}),
      leading: IconButton.filled(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          context.pop();
        },
        icon: Icon(LucideIcons.x),
      ),
      title: AccountSelector(icon: LucideIcons.building_2, title: 'Kaspi'),
      actions: [
        IconButton.filled(
          onPressed: () => {},
          icon: Icon(LucideIcons.trash_2),
          style: IconButton.styleFrom(
            foregroundColor: context.c.error,
            backgroundColor: context.c.error.withValues(alpha: 0.3),
          ),
        ),
      ],
      child: _TransactionForm(initialTransactionType: initialTransactionType),
    );
  }
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({required this.initialTransactionType});

  final TransactionType initialTransactionType;

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  late TransactionType _selectedType;
  double _amount = 0;
  DateTime _selectedDate = DateTime.now();
  TransactionCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialTransactionType;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TypeToggle<TransactionType>(
            items: TransactionType.values
                .map(
                  (type) => TypeToggleItem(
                    value: type,
                    label: type.label,
                    icon: type.icon,
                    selectedBackgroundColor: type.backgroundColor,
                  ),
                )
                .toList(),
            selected: _selectedType,
            onChanged: (type) {
              setState(() {
                _selectedType = type;
                _selectedCategory = null;
              });
            },
          ),
          const SizedBox(height: 56),
          AmountField(
            initialValue: _amount,
            onChanged: (amount) => _amount = amount,
          ),
          const SizedBox(height: 12),
          DateSelector(
            value: _selectedDate,
            onChanged: (date) => setState(() => _selectedDate = date),
          ),
          const SizedBox(height: 56),
          NoteField(),
          if (_selectedType != TransactionType.transfer) ...[
            const SizedBox(height: 14),
            CategorySelector(
              categories: TransactionCategory.forType(_selectedType),
              selected: _selectedCategory,
              foregroundColor: context.c.primary,
              onChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
          ],
        ],
      ),
    );
  }
}
