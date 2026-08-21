import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';
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
      child: CustomBottomSheet(
        title: const Text('Accounts'),
        actions: [
          IconButton.filled(
            onPressed: onAddAccount,
            tooltip: 'Add account',
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

            if (accounts.isEmpty) return const _EmptyAccounts();

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
                    child: _AccountCard(
                      account: account,
                      onTap: onAccountTap == null
                          ? null
                          : () => onAccountTap!(account),
                      onEdit: onEditAccount == null
                          ? null
                          : () => onEditAccount!(account),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AllAccountsCard extends StatelessWidget {
  const _AllAccountsCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.c.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.check_check,
                  color: context.c.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('All accounts', style: context.t.titleMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, this.onTap, this.onEdit});

  final AccountEntity account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final accentColor = account.colorValue == null
        ? context.c.primary
        : Color(account.colorValue!);
    final icon = AppIcon.fromCode(account.iconCode).icon;

    return Material(
      color: context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.t.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatBalance(account.balanceMinor)} ${account.currencyCode}',
                      style: context.t.bodyMedium?.copyWith(
                        color: context.c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit account',
                icon: const Icon(LucideIcons.pen, size: 19),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBalance(int minor) {
    final amount = minor / 100;
    return amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
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
          Text(message ?? 'Could not load accounts'),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                context.read<AccountBloc>().add(const AccountLoadRequested()),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyAccounts extends StatelessWidget {
  const _EmptyAccounts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wallet, size: 32, color: context.c.onSurfaceVariant),
          const SizedBox(height: 8),
          Text('No accounts yet', style: context.t.bodyMedium),
        ],
      ),
    );
  }
}
