enum SubscriptionStatus {
  free,
  trial,
  active,
}

enum SubscriptionPlan {
  monthly,
  annual,
}

class SubscriptionProducts {
  SubscriptionProducts._();

  static const annualId = 'aethor_pro_annual';
  static const monthlyId = 'aethor_pro_monthly';

  static const allIds = <String>{annualId, monthlyId};

  static SubscriptionPlan? planFromProductId(String productId) {
    return switch (productId) {
      annualId => SubscriptionPlan.annual,
      monthlyId => SubscriptionPlan.monthly,
      _ => null,
    };
  }

  static String productIdFromPlan(SubscriptionPlan plan) {
    return switch (plan) {
      SubscriptionPlan.annual => annualId,
      SubscriptionPlan.monthly => monthlyId,
    };
  }
}
