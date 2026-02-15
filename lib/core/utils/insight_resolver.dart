import 'package:flutter/widgets.dart';
import 'package:finguard_app/l10n/app_localizations.dart';

class InsightResolver {
  static String resolveInsight(
    BuildContext context,
    String? key, {
    String? riskLevel,
  }) {
    final loc = AppLocalizations.of(context)!;

    switch (key) {
      case "NEGATIVE_CASH_FLOW":
      case "negative_cash_flow":
        return loc.insightNegativeCashFlow;
      case "EXPENSE_SPIKE":
      case "expense_spike":
        return loc.insightExpenseSpike;
      case "BUDGET_EXCEEDED":
      case "budget_exceeded":
        return loc.insightBudgetExceeded;
      case "SPENDING_SPIKE":
      case "spending_spike":
        return loc.insightSpendingSpike;
      case "STABLE":
      case "stable":
        return loc.insightStable;
      default:
        // Fallback based on risk level
        if (riskLevel != null) {
          switch (riskLevel) {
            case "LOW":
              return loc.insightLowRisk;
            case "MEDIUM":
              return loc.insightMediumRisk;
            case "HIGH":
              return loc.insightHighRisk;
          }
        }
        return loc.insightStable;
    }
  }

  static String resolveRecommendation(BuildContext context, String? key) {
    final loc = AppLocalizations.of(context)!;

    switch (key) {
      case "REC_NEGATIVE_CASH_FLOW":
      case "rec_negative_cash_flow":
      case "reduce_spending":
        return loc.recNegativeCashflow;
      case "REC_EXPENSE_SPIKE":
      case "rec_expense_spike":
        return loc.recExpenseSpike;
      case "REC_BUDGET_EXCEEDED":
      case "rec_budget_exceeded":
        return loc.recBudgetExceeded;
      case "REC_STABLE":
      case "rec_stable":
      case "maintain_pattern":
        return loc.recStable;
      default:
        return "";
    }
  }
}
