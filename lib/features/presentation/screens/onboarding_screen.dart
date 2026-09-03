import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_constants.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/router/routes.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/presentation/widgets/analytics/category_breakdown_controller.dart';
import 'package:woolet/features/presentation/widgets/analytics/category_donut_chart.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/icon_preview.dart';
import 'package:woolet/features/presentation/widgets/transaction_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 3;

  final _pageController = PageController();
  int _page = 0;

  Future<void> _finish() async {
    await sl<SharedPreferences>().setBool(
      AppConstants.onboardingCompletedKey,
      true,
    );
    if (mounted) context.go(AppRoutes.login);
  }

  void _skip() => _finish();

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
      return;
    }
    HapticFeedback.selectionClick();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void _back() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_page > 0)
                    BackButton(onPressed: _back)
                  else
                    const SizedBox(width: 48),
                  TextButton(onPressed: _skip, child: const Text('Skip')),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _page = value);
                },
                children: [
                  const _TransactionsPage(),
                  _InsightsPage(isActive: _page == 1),
                  const _PersonalizePage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Column(
                children: [
                  _PageIndicator(current: _page, count: _pageCount),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Button(
                      key: ValueKey(_page),
                      label: _page == _pageCount - 1
                          ? 'Get started'
                          : 'Continue',
                      icon: _page == _pageCount - 1
                          ? LucideIcons.sparkles
                          : LucideIcons.arrow_right,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsPage extends StatelessWidget {
  const _TransactionsPage();

  static final _account = AccountEntity(
    uuid: 'daily-card',
    name: 'Daily card',
    iconCode: 'credit_card',
    currencyCode: 'KZT',
    balanceMinor: 42850000,
    createdAt: DateTime(2026),
    colorValue: 0xFF7C6CF2,
  );

  static final _items = [
    (
      transaction: TransactionEntity(
        uuid: 'coffee',
        type: TransactionType.expense,
        amountMinor: 245000,
        accountUuid: 'daily-card',
        categoryUuid: 'cafe',
        note: 'Morning coffee',
        occurredAt: DateTime(2026),
        createdAt: DateTime(2026),
      ),
      category: CategoryEntity(
        uuid: 'cafe',
        name: 'Cafe',
        iconCode: 'coffee',
        createdAt: DateTime(2026),
        type: CategoryType.expense,
        colorValue: 0xFFF59E67,
      ),
    ),
    (
      transaction: TransactionEntity(
        uuid: 'salary',
        type: TransactionType.income,
        amountMinor: 54000000,
        accountUuid: 'daily-card',
        categoryUuid: 'salary',
        note: 'August salary',
        occurredAt: DateTime(2026),
        createdAt: DateTime(2026),
      ),
      category: CategoryEntity(
        uuid: 'salary',
        name: 'Salary',
        iconCode: 'banknote',
        createdAt: DateTime(2026),
        type: CategoryType.income,
        colorValue: 0xFF2BBFA4,
      ),
    ),
    (
      transaction: TransactionEntity(
        uuid: 'groceries',
        type: TransactionType.expense,
        amountMinor: 1825000,
        accountUuid: 'daily-card',
        categoryUuid: 'groceries',
        note: 'Weekly groceries',
        occurredAt: DateTime(2026),
        createdAt: DateTime(2026),
      ),
      category: CategoryEntity(
        uuid: 'groceries',
        name: 'Groceries',
        iconCode: 'groceries',
        createdAt: DateTime(2026),
        type: CategoryType.expense,
        colorValue: 0xFFEC6A9E,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      eyebrow: 'EFFORTLESS TRACKING',
      title: 'Every move, clearly recorded',
      description:
          'Income and expenses stay organized the moment you add them.',
      visual: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutBack,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, 34 * (1 - value)),
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        ),
        child: Column(
          children: [
            for (final item in _items) ...[
              TransactionCard(
                transaction: item.transaction,
                account: _account,
                category: item.category,
                currencyController: sl<CurrencyController>(),
              ),
              if (item != _items.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightsPage extends StatefulWidget {
  const _InsightsPage({required this.isActive});

  final bool isActive;

  @override
  State<_InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<_InsightsPage>
    with SingleTickerProviderStateMixin {
  int? _focused;
  late final AnimationController _entranceController;
  late final Animation<double> _entrance;

  static const _segments = [
    CategorySegment(
      id: 'food',
      name: 'Food',
      amountMinor: 8640000,
      color: Color(0xFFF59E67),
      icon: LucideIcons.utensils,
    ),
    CategorySegment(
      id: 'home',
      name: 'Home',
      amountMinor: 6250000,
      color: Color(0xFF7C6CF2),
      icon: LucideIcons.house,
    ),
    CategorySegment(
      id: 'fun',
      name: 'Fun',
      amountMinor: 3940000,
      color: Color(0xFFEC6A9E),
      icon: LucideIcons.party_popper,
    ),
    CategorySegment(
      id: 'ride',
      name: 'Transport',
      amountMinor: 2810000,
      color: Color(0xFF2BBFA4),
      icon: LucideIcons.car,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _entrance = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    if (widget.isActive) _entranceController.forward();
  }

  @override
  void didUpdateWidget(covariant _InsightsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _focused = null;
      _entranceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      eyebrow: 'KNOW YOUR HABITS',
      title: 'Turn spending into insight',
      description: 'Tap the chart to discover where your money goes.',
      visual: AnimatedBuilder(
        animation: _entrance,
        builder: (context, child) {
          final value = _entrance.value.clamp(0.0, 1.0);
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 28 * (1 - value)),
              child: Transform.rotate(
                angle: -.045 * (1 - value),
                child: Transform.scale(
                  scale: .82 + (.18 * value),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: context.c.surfaceContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              CategoryDonutChart(
                segments: _segments,
                totalMinor: 23500000,
                focusedSegment: _focused == null ? null : _segments[_focused!],
                symbol: '₸',
                isFocused: (id) =>
                    _focused == null || _segments[_focused!].id == id,
                onSegmentTap: (index) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _focused =
                        index != null && index >= 0 && index < _segments.length
                        ? index
                        : null;
                  });
                },
              ),
              Text(
                'Interactive analytics',
                style: context.t.labelLarge?.copyWith(color: context.c.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalizePage extends StatelessWidget {
  const _PersonalizePage();

  static const _categories = [
    (label: 'Food', icon: LucideIcons.utensils, color: Color(0xFFF59E67)),
    (label: 'Home', icon: LucideIcons.house, color: Color(0xFF7C6CF2)),
    (label: 'Travel', icon: LucideIcons.plane, color: Color(0xFF2BBFA4)),
    (
      label: 'Shopping',
      icon: LucideIcons.shopping_bag,
      color: Color(0xFFEC6A9E),
    ),
    (label: 'Health', icon: LucideIcons.heart_pulse, color: Color(0xFFEF6464)),
    (label: 'Study', icon: LucideIcons.book_open, color: Color(0xFF5C8FF1)),
  ];

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      eyebrow: 'MADE FOR YOU',
      title: 'Your money, your system',
      description:
          'Personalize categories with colors and icons that feel natural to you.',
      visual: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutBack,
        builder: (context, value, child) => Transform.scale(
          scale: .82 + (.18 * value),
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: context.c.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.c.outlineVariant),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 22,
            children: [
              for (final category in _categories)
                SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      IconPreview.card(
                        icon: category.icon,
                        color: category.color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.label,
                        maxLines: 1,
                        style: context.t.labelMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.visual,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              visual,
              const SizedBox(height: 30),
              Text(
                eyebrow,
                textAlign: TextAlign.center,
                style: context.t.labelMedium?.copyWith(
                  color: context.c.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.t.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: context.t.bodyLarge?.copyWith(
                  color: context.c.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.current, required this.count});
  final int current;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      count,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: current == index ? 26 : 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: current == index
              ? context.c.primary
              : context.c.outlineVariant,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    ),
  );
}
