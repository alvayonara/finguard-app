import 'package:flutter/widgets.dart';
import 'package:finguard_app/l10n/app_localizations.dart';

class InsightResolver {
  static String resolveInsight(
      BuildContext context, String? key) {
    final loc = AppLocalizations.of(context)!;

    switch (key) {
      case "NEGATIVE_CASH_FLOW":
        return loc.insightNegativeCashFlow;
      case "EXPENSE_SPIKE":
        return loc.insightExpenseSpike;
      case "STABLE":
        return loc.insightStable;
      default:
        return loc.insightGeneric;
    }
  }

  static String resolveRecommendation(
      BuildContext context, String? key) {
    final loc = AppLocalizations.of(context)!;

    switch (key) {
      case "REC_NEGATIVE_CASH_FLOW":
        return loc.recNegativeCashflow;
      case "REC_EXPENSE_SPIKE":
        return loc.recExpenseSpike;
      case "REC_STABLE":
        return loc.recStable;
      default:
        return "";
    }
  }
}