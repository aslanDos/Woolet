import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/utils/amount_formatter.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/core/utils/uuid.dart';
import 'package:woolet/core/widgets/alert_dialog.dart';
import 'package:woolet/core/widgets/error_toast.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/form_tile.dart';
import 'package:woolet/features/presentation/widgets/icon_color_selector.dart';

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

class _AccountFormViewState extends State<_AccountFormView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AppIcon _icon;
  late Color _color;
  AccountEntity? _submittedAccount;
  bool _deleting = false;
  late final ErrorToastController _errorToast;

  bool get _isEditing => widget.account != null;
  String get _currencyCode =>
      widget.account?.currencyCode ?? sl<CurrencyController>().value.code;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _nameController = TextEditingController(text: account?.name ?? '');
    _balanceController = TextEditingController(
      text: AmountUtils.formatMinor(account?.balanceMinor ?? 0),
    );
    _icon = AppIcon.fromCode(account?.iconCode ?? AppIcon.wallet.code);
    _color = account?.colorValue == null
        ? const Color(0xFF2563EB)
        : Color(account!.colorValue!);
    _errorToast = ErrorToastController(vsync: this);
  }

  @override
  void dispose() {
    _errorToast.dispose();
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
        if (state.status == AccountStatus.failure) {
          _errorToast.show(
            context,
            state.errorMessage ?? 'Could not save account',
          );
          return;
        }
        if (_deleting) {
          Navigator.pop(context);
          return;
        }

        final account = _submittedAccount;
        if (account != null) widget.onSaved?.call(account);
        Navigator.pop(context, account);
      },
      builder: (context, state) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconColorSelector(
                icon: _icon,
                color: _color,
                compact: true,
                onIconChanged: (icon) => setState(() => _icon = icon),
                onColorChanged: (color) => setState(() => _color = color),
              ),
              const SizedBox(height: 4),
              FormTile(
                icon: LucideIcons.a_large_small,
                label: 'Name',
                field: TextFormField(
                  controller: _nameController,
                  autofocus: !_isEditing,
                  maxLength: AccountEntity.maxNameLength,
                  textCapitalization: TextCapitalization.sentences,
                  style: context.t.bodyMedium,
                  textAlign: TextAlign.end,
                  decoration: _inlineFieldDecoration(
                    hintText: 'Account name',
                    hideCounter: true,
                  ),
                  onChanged: (_) => _errorToast.hide(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
              const SizedBox(height: 4),
              FormTile(
                icon: LucideIcons.badge_dollar_sign,
                label: 'Balance',
                field: TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [AmountFormatter()],
                  style: context.t.bodyMedium,
                  textAlign: TextAlign.end,
                  decoration: _inlineFieldDecoration(hintText: '0'),
                  onChanged: (_) => _errorToast.hide(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inlineFieldDecoration({
    required String hintText,
    bool hideCounter = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      counterText: hideCounter ? '' : null,
      isCollapsed: true,
      filled: false,
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final name = _nameController.text.trim();
    final balance = AmountUtils.parse(_balanceController.text);
    String? error;
    if (name.isEmpty) error = 'Enter an account name';
    if (error == null && balance == null) error = 'Enter a valid balance';
    if (error != null) {
      _errorToast.show(context, error);
      return;
    }

    final original = widget.account;
    final account = AccountEntity(
      uuid: original?.uuid ?? createUuidV4(),
      name: name,
      sortOrder: original?.sortOrder ?? -1,
      iconCode: _icon.code,
      currencyCode: _currencyCode,
      balanceMinor: AmountUtils.toMinor(balance!),
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
}
