import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/transaction_type_x.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/sheets/accounts_sheet.dart';
import 'package:woolet/features/presentation/widgets/account_selector.dart';
import 'package:woolet/features/presentation/widgets/amount_field.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/category_selector.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/date_selector.dart';
import 'package:woolet/features/presentation/widgets/note_field.dart';
import 'package:woolet/features/presentation/widgets/to_account_field.dart';
import 'package:woolet/features/presentation/widgets/type_toggle.dart';

class TransactionFormSheet extends StatefulWidget {
  const TransactionFormSheet({
    super.key,
    this.initialTransactionType = TransactionType.expense,
  });

  final TransactionType initialTransactionType;

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  AccountEntity? _selectedAccount;

  Future<void> _selectAccount() async {
    await context.openBottomSheet(
      child: AccountsSheet(
        onAccountTap: (account) {
          setState(() => _selectedAccount = account);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = _selectedAccount;

    return CustomBottomSheet(
      height: MediaQuery.sizeOf(context).height * 0.9,
      footer: Button(
        label: 'Save',
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          context.pop();
        },
      ),
      leading: IconButton.filled(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          context.pop();
        },
        icon: Icon(LucideIcons.x),
      ),
      title: AccountSelector(account: account, onTap: _selectAccount),
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
      child: _TransactionForm(
        initialTransactionType: widget.initialTransactionType,
      ),
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
  CategoryEntity? _selectedCategory;
  AccountEntity? _toAccount;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialTransactionType;
  }

  Future<void> _selectToAccount() async {
    await context.openBottomSheet(
      child: AccountsSheet(
        onAccountTap: (account) {
          setState(() => _toAccount = account);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryType = switch (_selectedType) {
      TransactionType.income => CategoryType.income,
      TransactionType.expense => CategoryType.expense,
      TransactionType.transfer => null,
    };

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
          if (categoryType == null) ...[
            ToAccountField(account: _toAccount, onTap: _selectToAccount),
            const SizedBox(height: 24),
          ],
          NoteField(),
          if (categoryType != null) ...[
            const SizedBox(height: 24),
            CategorySelector(
              type: categoryType,
              selected: _selectedCategory,
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
