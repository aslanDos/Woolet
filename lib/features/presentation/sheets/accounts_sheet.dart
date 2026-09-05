import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/core/widgets/app_empty_state.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';
import 'package:woolet/features/presentation/sheets/account_form_sheet.dart';
import 'package:woolet/features/presentation/widgets/account_card.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

class AccountsSheet extends StatelessWidget {
  const AccountsSheet({
    super.key,
    this.onAddAccount,
    this.onAccountTap,
    this.onEditAccount,
    this.allowAllAccounts = false,
  });

  final VoidCallback? onAddAccount;
  final ValueChanged<AccountEntity?>? onAccountTap;
  final ValueChanged<AccountEntity>? onEditAccount;
  final bool allowAllAccounts;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountBloc>()..add(const AccountLoadRequested()),
      child: Builder(
        builder: (context) => CustomBottomSheet(
          title: Text(context.l10n.allAccounts),
          actions: [
            IconButton.filled(
              onPressed:
                  onAddAccount ?? () => _openAccountForm(context: context),
              icon: const Icon(LucideIcons.plus),
            ),
          ],
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, state) {
              if (state.status == AccountStatus.loading &&
                  state.accounts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == AccountStatus.failure &&
                  state.accounts.isEmpty) {
                return _LoadError(message: state.errorMessage);
              }

              final accounts = state.accounts
                  .where((account) => account.visible)
                  .toList(growable: false);

              if (accounts.isEmpty) {
                return _EmptyAccounts(
                  onAction: () => _openAccountForm(context: context),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isProcessing)
                    const LinearProgressIndicator(minHeight: 2),
                  if (allowAllAccounts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AllAccountsCard(
                        onTap: onAccountTap == null
                            ? null
                            : () => onAccountTap!(null),
                      ),
                    ),
                  ...accounts.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AccountCard(
                        account: account,
                        currencySymbol: sl<CurrencyController>().symbolForCode(
                          account.currencyCode,
                        ),
                        onTap: onAccountTap == null
                            ? null
                            : () => onAccountTap!(account),
                        onEdit: onEditAccount == null
                            ? () => _openAccountForm(
                                context: context,
                                account: account,
                              )
                            : () => onEditAccount!(account),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openAccountForm({
    required BuildContext context,
    AccountEntity? account,
  }) async {
    final bloc = context.read<AccountBloc>();
    await context.openBottomSheet(child: AccountFormSheet(account: account));
    if (context.mounted) bloc.add(const AccountLoadRequested());
  }
}

class _AllAccountsCard extends StatelessWidget {
  const _AllAccountsCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.c.surfaceContainer,
          borderRadius: .circular(12),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.check_check, color: context.c.primary, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.allAccounts,
                style: context.t.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.circle_alert, color: context.c.error),
          const SizedBox(height: 8),
          Text(message ?? context.l10n.couldNotLoadAccounts),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                context.read<AccountBloc>().add(const AccountLoadRequested()),
            child: Text(context.l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}

class _EmptyAccounts extends StatelessWidget {
  const _EmptyAccounts({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: LucideIcons.wallet,
      title: context.l10n.noAccountsYet,
      actionLabel: context.l10n.createAccount,
      onAction: onAction,
      compact: true,
    );
  }
}
