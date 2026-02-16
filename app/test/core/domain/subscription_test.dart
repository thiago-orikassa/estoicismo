import 'package:flutter_test/flutter_test.dart';

import 'package:aethor_app/core/domain/subscription.dart';

void main() {
  group('SubscriptionProducts', () {
    test('planFromProductId returns annual for annual ID', () {
      expect(
        SubscriptionProducts.planFromProductId('aethor_pro_annual'),
        SubscriptionPlan.annual,
      );
    });

    test('planFromProductId returns monthly for monthly ID', () {
      expect(
        SubscriptionProducts.planFromProductId('aethor_pro_monthly'),
        SubscriptionPlan.monthly,
      );
    });

    test('planFromProductId returns null for unknown ID', () {
      expect(
        SubscriptionProducts.planFromProductId('unknown_product'),
        isNull,
      );
    });

    test('productIdFromPlan returns correct ID for annual', () {
      expect(
        SubscriptionProducts.productIdFromPlan(SubscriptionPlan.annual),
        'aethor_pro_annual',
      );
    });

    test('productIdFromPlan returns correct ID for monthly', () {
      expect(
        SubscriptionProducts.productIdFromPlan(SubscriptionPlan.monthly),
        'aethor_pro_monthly',
      );
    });

    test('allIds contains both product IDs', () {
      expect(SubscriptionProducts.allIds, containsAll([
        'aethor_pro_annual',
        'aethor_pro_monthly',
      ]));
      expect(SubscriptionProducts.allIds.length, 2);
    });

    test('round-trip: plan -> productId -> plan', () {
      for (final plan in SubscriptionPlan.values) {
        final productId = SubscriptionProducts.productIdFromPlan(plan);
        final roundTripped = SubscriptionProducts.planFromProductId(productId);
        expect(roundTripped, plan);
      }
    });
  });
}
