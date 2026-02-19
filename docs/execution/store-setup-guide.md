# Store Setup Guide — Aethor Billing

## Google Play Console

### 1. Create App
1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app → name: **Aethor**
3. Set up store listing (screenshots, description, etc.)

### 2. Create Subscription Group
1. Go to **Monetize** → **Products** → **Subscriptions**
2. Create subscription group: **Aethor Pro**

### 3. Create Products
1. **Annual plan:**
   - Product ID: `aethor_pro_annual`
   - Price: R$ 149,00/year
   - Free trial: 7 days
   - Grace period: 3 days (recommended)

2. **Monthly plan:**
   - Product ID: `aethor_pro_monthly`
   - Price: R$ 19,90/month
   - No free trial

### 4. License Testers
1. Go to **Settings** → **License testing**
2. Add your test Google accounts
3. License testers can make purchases without being charged

### 5. Internal Testing Track
1. Create an internal testing track
2. Upload a signed AAB
3. Add testers to the internal track
4. Testers can install via the test link provided

---

## App Store Connect

### 1. Create App
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in: name (**Aethor**), bundle ID, SKU

### 2. Create Subscription Group
1. Go to **Subscriptions** → **Subscription Groups**
2. Create group: **Aethor Pro**

### 3. Create Products
1. **Annual plan:**
   - Product ID: `aethor_pro_annual`
   - Reference Name: Pro Anual
   - Duration: 1 Year
   - Price: Tier matching R$ 149,00
   - Introductory Offer: Free Trial, 1 Week

2. **Monthly plan:**
   - Product ID: `aethor_pro_monthly`
   - Reference Name: Pro Mensal
   - Duration: 1 Month
   - Price: Tier matching R$ 19,90
   - No introductory offer

### 4. Sandbox Testers
1. Go to **Users and Access** → **Sandbox** → **Testers**
2. Create sandbox test accounts
3. On device: Settings → App Store → Sandbox Account → sign in with test account

### 5. StoreKit Testing (Simulator)
The file `app/ios/Runner/Aethor.storekit` is configured for local testing:
1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
2. Under **Run** → **Options** → **StoreKit Configuration**
3. Select `Aethor.storekit`
4. Purchases in the simulator will use this local configuration

---

## Product IDs Reference

| Plan    | Product ID                | Price       | Trial   |
|---------|--------------------------|-------------|---------|
| Annual  | `aethor_pro_annual`  | R$ 149/ano  | 7 dias  |
| Monthly | `aethor_pro_monthly` | R$ 19,90/mês| —       |

These IDs must match exactly in:
- `app/lib/core/domain/subscription.dart` (Flutter)
- Google Play Console subscriptions
- App Store Connect subscriptions
- `app/ios/Runner/Aethor.storekit` (local testing)
