import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/theme/app_colors.dart';
import 'package:woolet/core/utils/uuid.dart';
import 'package:woolet/core/widgets/alert_dialog.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';
import 'package:woolet/features/presentation/sheets/icon_picker_sheet.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/color_picker.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/icon_picker.dart';

class AccountFormSheet extends StatelessWidget {
  const AccountFormSheet({super.key, this.account, this.onSaved});

  final AccountEntity? account;
  final ValueChanged<AccountEntity>? onSaved;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountBloc>(),
      child: _AccountFormView(account: account, onSaved: onSaved),
    );
  }
}

class _AccountFormView extends StatefulWidget {
  const _AccountFormView({required this.account, required this.onSaved});

  final AccountEntity? account;
  final ValueChanged<AccountEntity>? onSaved;

  @override
  State<_AccountFormView> createState() => _AccountFormViewState();
}

class _AccountFormViewState extends State<_AccountFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AppIcon _icon;
  late Color _color;
  AccountEntity? _submittedAccount;
  bool _deleting = false;

  bool get _isEditing => widget.account != null;
  String get _currencyCode =>
      widget.account?.currencyCode ?? sl<CurrencyController>().value.code;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _nameController = TextEditingController(text: account?.name ?? '');
    _balanceController = TextEditingController(
      text: _formatBalance(account?.balanceMinor ?? 0),
    );
    _icon = AppIcon.fromCode(account?.iconCode ?? AppIcon.wallet.code);
    _color = account?.colorValue == null
        ? const Color(0xFF2563EB)
        : Color(account!.colorValue!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(
      listenWhen: (previous, current) =>
          previous.isProcessing && !current.isProcessing,
      listener: (context, state) {
        if (state.status == AccountStatus.failure) return;
        if (_deleting) {
          Navigator.pop(context);
          return;
        }

        final account = _submittedAccount;
        if (account != null) widget.onSaved?.call(account);
        Navigator.pop(context, account);
      },
      builder: (context, state) {
        final fieldBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        );

        return CustomBottomSheet(
          title: Text(_isEditing ? 'Edit account' : 'New account'),
          leading: IconButton.filled(
            onPressed: state.isProcessing ? null : () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x),
          ),
          actions: [
            if (_isEditing)
              IconButton.filled(
                onPressed: state.isProcessing ? null : _delete,
                style: IconButton.styleFrom(
                  foregroundColor: context.c.error,
                  backgroundColor: context.c.error.withValues(alpha: 0.14),
                ),
                icon: const Icon(LucideIcons.trash_2),
              ),
          ],
          footer: ColoredBox(
            color: context.c.surface,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Button(
                label: _isEditing ? 'Save changes' : 'Create account',
                isLoading: state.isProcessing,
                onPressed: _submit,
              ),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconPreview(icon: _icon, color: _color),
                const SizedBox(height: 24),
                Text('Name', style: context.t.titleLarge),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  autofocus: !_isEditing,
                  maxLength: AccountEntity.maxNameLength,
                  textCapitalization: TextCapitalization.sentences,
                  style: context.t.bodyMedium,
                  decoration: _fieldDecoration(
                    context,
                    border: fieldBorder,
                    hintText: 'Account name',
                  ).copyWith(counterText: ''),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an account name'
                      : null,
                ),
                const SizedBox(height: 24),
                Text('Balance', style: context.t.titleLarge),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [_BalanceInputFormatter()],
                  style: context.t.bodyMedium,
                  decoration: _fieldDecoration(
                    context,
                    border: fieldBorder,
                    hintText: '0',
                  ).copyWith(suffixText: _currencyCode),
                  validator: (value) {
                    final normalized = value?.replaceFirst(',', '.');
                    return double.tryParse(normalized ?? '') == null
                        ? 'Enter a valid balance'
                        : null;
                  },
                ),
                const SizedBox(height: 24),
                IconPickerField(
                  selected: _icon,
                  color: _color,
                  onSeeAll: _openIconPicker,
                  onChanged: (icon) => setState(() => _icon = icon),
                ),
                const SizedBox(height: 24),
                Text('Color', style: context.t.titleLarge),
                const SizedBox(height: 10),
                ColorPicker(
                  colors: AppColors.pickerColors,
                  selected: _color,
                  onChanged: (color) => setState(() => _color = color),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage!,
                    style: context.t.bodyMedium?.copyWith(
                      color: context.c.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required OutlineInputBorder border,
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: context.c.surfaceContainer,
      contentPadding: const EdgeInsets.all(12),
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
      focusedErrorBorder: border,
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final original = widget.account;
    final balance = double.parse(
      _balanceController.text.replaceFirst(',', '.'),
    );
    final account = AccountEntity(
      uuid: original?.uuid ?? createUuidV4(),
      name: _nameController.text.trim(),
      sortOrder: original?.sortOrder ?? -1,
      iconCode: _icon.code,
      currencyCode: _currencyCode,
      balanceMinor: (balance * 100).round(),
      createdAt: original?.createdAt ?? DateTime.now().toUtc(),
      colorValue: _color.toARGB32(),
      visible: original?.visible ?? true,
    );

    _deleting = false;
    _submittedAccount = account;
    context.read<AccountBloc>().add(
      original == null
          ? AccountCreateRequested(account)
          : AccountUpdateRequested(account),
    );
  }

  Future<void> _openIconPicker() async {
    final selected = await context.openBottomSheet<AppIcon>(
      showDragHandle: true,
      child: IconPickerSheet(selected: _icon, color: _color),
    );
    if (selected == null || !mounted) return;
    setState(() => _icon = selected);
  }

  Future<void> _delete() async {
    final account = widget.account;
    if (account == null) return;

    final confirmed = await AppAlertDialog.show(
      context,
      title: 'Delete account?',
      message: 'Are you sure you want to delete “${account.name}”?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    _deleting = true;
    context.read<AccountBloc>().add(AccountDeleteRequested(account.uuid));
  }

  String _formatBalance(int minor) {
    final amount = minor / 100;
    return amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }
}

class _BalanceInputFormatter extends TextInputFormatter {
  static final _pattern = RegExp(r'^\d*(?:[.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
