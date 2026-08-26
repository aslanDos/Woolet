import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/transaction_type_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/core/utils/uuid.dart';
import 'package:woolet/core/widgets/alert_dialog.dart';
import 'package:woolet/core/widgets/error_toast.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';
import 'package:woolet/features/presentation/blocs/transaction/transaction_bloc.dart';
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
    this.transaction,
    this.initialAccount,
  });

  final TransactionType initialTransactionType;
  final TransactionEntity? transaction;
  final AccountEntity? initialAccount;

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet>
    with SingleTickerProviderStateMixin {
  late TransactionType _type;
  late double _amount;
  late DateTime _date;
  late final TextEditingController _noteController;
  AccountEntity? _account;
  AccountEntity? _toAccount;
  CategoryEntity? _category;
  List<AccountEntity> _accounts = const [];
  bool _deleting = false;
  late final ErrorToastController _errorToast;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final value = widget.transaction;
    _type = value?.type ?? widget.initialTransactionType;
    _amount = AmountUtils.fromMinor(value?.amountMinor ?? 0);
    _date = value?.occurredAt ?? DateTime.now();
    _account = widget.initialAccount;
    _noteController = TextEditingController(text: value?.note ?? '');
    _errorToast = ErrorToastController(vsync: this);
    _loadLinkedValues(value);
  }

  Future<void> _loadLinkedValues(TransactionEntity? value) async {
    final accounts = await sl<AccountRepository>().getAccounts();
    final categories = value == null
        ? null
        : await sl<CategoryRepository>().getCategories();
    if (!mounted) return;
    accounts.fold(
      (_) {},
      (items) => setState(() {
        _accounts = items.where((account) => account.visible).toList();
        _account = value == null
            ? widget.initialAccount ??
                  (_accounts.isEmpty ? null : _accounts.first)
            : _findAccount(_accounts, value.accountUuid);
        _toAccount = value == null
            ? _defaultToAccount()
            : _findAccount(_accounts, value.toAccountUuid);
      }),
    );
    categories?.fold(
      (_) {},
      (items) => setState(() {
        for (final item in items) {
          if (item.uuid == value!.categoryUuid) _category = item;
        }
      }),
    );
  }

  AccountEntity? _findAccount(List<AccountEntity> values, String? uuid) {
    for (final value in values) {
      if (value.uuid == uuid) return value;
    }
    return null;
  }

  AccountEntity? _defaultToAccount() {
    if (_type != TransactionType.transfer || _account == null) return null;
    for (final account in _accounts) {
      if (account.uuid != _account!.uuid) return account;
    }
    return null;
  }

  @override
  void dispose() {
    _errorToast.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectAccount({required bool destination}) async {
    await context.openBottomSheet(
      child: AccountsSheet(
        onAccountTap: (account) {
          if (account == null) return;
          setState(() {
            if (destination) _toAccount = account;
            if (!destination) {
              _account = account;
              if (_type == TransactionType.transfer &&
                  _toAccount?.uuid == account.uuid) {
                _toAccount = _defaultToAccount();
              }
            }
            _errorToast.hide();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          previous.isProcessing && !current.isProcessing,
      listener: (context, state) {
        if (state.status == TransactionStatus.failure) {
          _errorToast.show(
            context,
            state.errorMessage ?? 'Could not save transaction',
          );
        } else {
          Navigator.pop(context, !_deleting);
        }
      },
      builder: (context, state) => CustomBottomSheet(
        // height: MediaQuery.sizeOf(context).height * 0.9,
        footer: Button(
          label: 'Save',
          isLoading: state.isProcessing,
          onPressed: _submit,
        ),
        leading: IconButton.filled(
          onPressed: state.isProcessing ? null : () => Navigator.pop(context),
          icon: const Icon(LucideIcons.x),
        ),
        title: AccountSelector(
          account: _account,
          onTap: () => _selectAccount(destination: false),
        ),
        actions: [
          if (_isEditing)
            IconButton.filled(
              onPressed: state.isProcessing ? null : _delete,
              icon: const Icon(LucideIcons.trash_2),
              style: IconButton.styleFrom(
                foregroundColor: context.c.error,
                backgroundColor: context.c.error.withValues(alpha: 0.3),
              ),
            ),
        ],
        child: SizedBox(
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
                selected: _type,
                onChanged: (type) => setState(() {
                  _type = type;
                  _category = null;
                  _toAccount = type == TransactionType.transfer
                      ? _defaultToAccount()
                      : null;
                  _errorToast.hide();
                }),
              ),
              const SizedBox(height: 56),
              AmountField(
                initialValue: _amount,
                currencySymbol: _account == null
                    ? sl<CurrencyController>().value.symbol
                    : sl<CurrencyController>().symbolForCode(
                        _account!.currencyCode,
                      ),
                onChanged: (amount) => _amount = amount,
              ),
              const SizedBox(height: 12),
              DateSelector(
                value: _date,
                onChanged: (date) => setState(() => _date = date),
              ),
              const SizedBox(height: 56),
              if (_type == TransactionType.transfer) ...[
                ToAccountField(
                  account: _toAccount,
                  onTap: () => _selectAccount(destination: true),
                ),
                const SizedBox(height: 4),
              ],
              if (_type != TransactionType.transfer) ...[
                CategorySelector(
                  type: _type == TransactionType.income
                      ? CategoryType.income
                      : CategoryType.expense,
                  selected: _category,
                  onChanged: (value) => setState(() {
                    _category = value;
                    _errorToast.hide();
                  }),
                ),
                const SizedBox(height: 4),
              ],
              NoteField(controller: _noteController),
              // const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final account = _account;
    String? error;
    if (_amount <= 0) error = 'Amount can not be 0';
    if (account == null) error = 'Select an account';
    if (_type == TransactionType.transfer && _toAccount == null) {
      error = 'Select a destination account';
    }
    if (_type == TransactionType.transfer &&
        _toAccount != null &&
        _toAccount!.uuid == account?.uuid) {
      error = 'Select a different destination account';
    }
    if (_type != TransactionType.transfer && _category == null) {
      error = 'Select a category';
    }
    if (error != null) {
      _errorToast.show(context, error);
      return;
    }

    final original = widget.transaction;
    final value = TransactionEntity(
      uuid: original?.uuid ?? createUuidV4(),
      type: _type,
      amountMinor: AmountUtils.toMinor(_amount),
      accountUuid: account!.uuid,
      toAccountUuid: _type == TransactionType.transfer
          ? _toAccount!.uuid
          : null,
      categoryUuid: _type == TransactionType.transfer ? null : _category!.uuid,
      note: _noteController.text.trim(),
      occurredAt: _date,
      createdAt: original?.createdAt ?? DateTime.now().toUtc(),
    );
    context.read<TransactionBloc>().add(
      original == null
          ? TransactionCreateRequested(value)
          : TransactionUpdateRequested(value),
    );
  }

  Future<void> _delete() async {
    final confirmed = await AppAlertDialog.show(
      context,
      title: 'Delete transaction?',
      message:
          'This transaction will be permanently deleted and the account balance will be adjusted.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    _deleting = true;
    context.read<TransactionBloc>().add(
      TransactionDeleteRequested(widget.transaction!.uuid),
    );
  }
}
