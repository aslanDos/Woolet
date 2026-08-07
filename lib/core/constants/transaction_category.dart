import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';

enum TransactionCategory {
  salary('Salary', AppIcon.briefcase, TransactionType.income),
  freelance('Freelance', AppIcon.banknote, TransactionType.income),
  investments('Investments', AppIcon.trendingUp, TransactionType.income),
  gifts('Gifts', AppIcon.gift, TransactionType.income),
  interest('Interest', AppIcon.landmark, TransactionType.income),
  otherIncome('Other', AppIcon.circleDollarSign, TransactionType.income),

  groceries('Groceries', AppIcon.groceries, TransactionType.expense),
  cafe('Cafe', AppIcon.cafe, TransactionType.expense),
  entertainment(
    'Entertainment',
    AppIcon.entertainment,
    TransactionType.expense,
  ),
  fuel('Fuel', AppIcon.fuel, TransactionType.expense),
  shopping('Shopping', AppIcon.shopping, TransactionType.expense),
  taxi('Taxi', AppIcon.taxi, TransactionType.expense),
  home('Home', AppIcon.home, TransactionType.expense),
  car('Car', AppIcon.car, TransactionType.expense),
  pharmacy('Pharmacy', AppIcon.pharmacy, TransactionType.expense),
  otherExpense('Other', AppIcon.wallet, TransactionType.expense);

  const TransactionCategory(this.label, this.appIcon, this.transactionType);

  final String label;
  final AppIcon appIcon;
  final TransactionType transactionType;

  static List<TransactionCategory> forType(TransactionType type) {
    return values
        .where((category) => category.transactionType == type)
        .toList(growable: false);
  }
}
