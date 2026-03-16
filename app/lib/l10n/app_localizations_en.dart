// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String appVersion(String version) {
    return 'Aethor • Version $version';
  }

  @override
  String get appTagline => 'Clarity to act.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSignOut => 'Sign Out';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionSync => 'Sync';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionBack => 'Back';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionClose => 'Close';

  @override
  String get actionRepeat => 'Retry';

  @override
  String get actionRegister => 'Register';

  @override
  String get actionCopyFcm => 'Copy FCM';

  @override
  String get navToday => 'Today';

  @override
  String get navHistory => 'History';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Settings';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayShortMon => 'Mon';

  @override
  String get weekdayShortTue => 'Tue';

  @override
  String get weekdayShortWed => 'Wed';

  @override
  String get weekdayShortThu => 'Thu';

  @override
  String get weekdayShortFri => 'Fri';

  @override
  String get weekdayShortSat => 'Sat';

  @override
  String get weekdayShortSun => 'Sun';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get monthShortJan => 'Jan';

  @override
  String get monthShortFeb => 'Feb';

  @override
  String get monthShortMar => 'Mar';

  @override
  String get monthShortApr => 'Apr';

  @override
  String get monthShortMay => 'May';

  @override
  String get monthShortJun => 'Jun';

  @override
  String get monthShortJul => 'Jul';

  @override
  String get monthShortAug => 'Aug';

  @override
  String get monthShortSep => 'Sep';

  @override
  String get monthShortOct => 'Oct';

  @override
  String get monthShortNov => 'Nov';

  @override
  String get monthShortDec => 'Dec';

  @override
  String dateFullLabel(String weekday, int day, String month) {
    return '$weekday, $month $day';
  }

  @override
  String get authorMarcusAurelius => 'Marcus Aurelius';

  @override
  String get authorSeneca => 'Seneca';

  @override
  String get authorEpictetus => 'Epictetus';

  @override
  String get authorMusoniusRufus => 'Musonius Rufus';

  @override
  String get authorMixed => 'Mixed';

  @override
  String get contextWork => 'Discipline';

  @override
  String get contextRelationships => 'Relationships';

  @override
  String get contextAnxiety => 'Anxiety';

  @override
  String get contextFocus => 'Focus';

  @override
  String get contextHardDecision => 'Difficult decision';

  @override
  String get languagePt => 'Português';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get homeTitle => 'Today';

  @override
  String get offlineTitle => 'You\'re offline.';

  @override
  String get offlineDescription => 'Connect to sync today\'s content.';

  @override
  String get errorContentFailed =>
      'Today\'s content failed to load. Try again.';

  @override
  String get emptyNoContent => 'No daily content available.';

  @override
  String get emptySyncLater => 'Try syncing again in a moment.';

  @override
  String get favoriteRemoved => 'Removed from favorites.';

  @override
  String get favoriteAdded => 'Added to favorites.';

  @override
  String get errorActionFailed => 'Could not complete the action. Try again.';

  @override
  String get checkinAppliedSuccess => 'Practice recorded successfully.';

  @override
  String get checkinNotAppliedSuccess => 'Check-in completed.';

  @override
  String get historyTitle => 'History';

  @override
  String get historyProUpsellTitle => 'Full history is Pro';

  @override
  String get historyProUpsellDesc =>
      'Review all your practices. Observe the patterns.';

  @override
  String get historyProUpsellButton => 'See Pro plans';

  @override
  String get historyEmptyOnline =>
      'Your history begins with your first practice.';

  @override
  String get historyEmptyFirstRecord =>
      'Today\'s practice will be your first record.';

  @override
  String get historyEmptyOffline => 'You\'re offline.';

  @override
  String get historyEmptySync => 'Connect to sync your history.';

  @override
  String historyLimitLabel(int count, int limit) {
    return '$count/$limit days';
  }

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmptyOnline =>
      'Quotes that resonate with you will appear here.';

  @override
  String get favoritesEmptyHint =>
      'Save today\'s quote to revisit when you need it.';

  @override
  String get favoritesEmptyTodayCta => 'See today\'s quote';

  @override
  String get favoritesSearchHint => 'Search quote or author...';

  @override
  String favoritesSearchEmpty(String query) {
    return 'No results for \"$query\".';
  }

  @override
  String get favoritesProUpsellTitle => 'Unlimited favorites are Pro';

  @override
  String get favoritesProUpsellDesc =>
      'Save every quote to revisit when you need it.';

  @override
  String get favoritesProUpsellButton => 'See Pro plans';

  @override
  String get favoritesRemoveSuccess => 'Removed from favorites.';

  @override
  String get favoritesRemoveError => 'Could not remove favorite.';

  @override
  String get favoritesRemoveTooltip => 'Remove from favorites';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'SETTINGS & PREFERENCES';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionSubscription => 'Subscription';

  @override
  String get settingsSectionContent => 'Content';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguagePickerTitle => 'Language';

  @override
  String get settingsTimezone => 'Timezone';

  @override
  String settingsTimezoneAuto(String label) {
    return '$label (auto-detected)';
  }

  @override
  String get settingsPreferredAuthors => 'Preferred Authors';

  @override
  String get settingsPreferredContext => 'Preferred Context';

  @override
  String get settingsPreferredContextSubtitle => 'Personalize your practice';

  @override
  String get settingsAuthorsAll => 'All (Mixed Mode)';

  @override
  String get settingsAuthorsNone => 'None';

  @override
  String get settingsAuthorsCustom => 'Custom';

  @override
  String get settingsVerifiedSources => 'Verified Sources';

  @override
  String get settingsAlways => 'Always';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get settingsLogoutDialogTitle => 'Sign out?';

  @override
  String get settingsLogoutDialogMessage =>
      'Your check-ins and favorites are saved in the cloud and will be restored when you sign in again.';

  @override
  String get settingsManageSubscriptionSnackbar =>
      'Manage your subscription in the App Store/Play Store.';

  @override
  String get settingsOpenSystemSettingsHint =>
      'Open system settings to allow notifications.';

  @override
  String get settingsResetOnboardingTitle => 'Reset onboarding?';

  @override
  String get settingsResetOnboardingMessage =>
      'This reopens the initial flow and clears onboarding preferences.';

  @override
  String get settingsResetOnboardingButton => 'Reset onboarding';

  @override
  String get settingsResetOnboardingSuccess =>
      'Onboarding will be shown when you reopen the app.';

  @override
  String get settingsTzBrasilia => 'Brasília (GMT−3)';

  @override
  String get settingsTzRioBranco => 'Rio Branco (GMT−5)';

  @override
  String get splashTagline => 'Clarity to act.';

  @override
  String get splashLoadingMessage => 'Preparing your insight for today...';

  @override
  String get onboardingContextQuestion =>
      'Which area do you want to strengthen now?';

  @override
  String get onboardingContextSubtitle => 'This personalizes today\'s insight.';

  @override
  String get onboardingContextHelper => 'Choose an option to continue.';

  @override
  String get onboardingContextAnxietyLabel =>
      'Regain clarity when the mind races';

  @override
  String get onboardingContextFocusLabel =>
      'Separate the essential from the urgent';

  @override
  String get onboardingContextWorkLabel =>
      'Act with intention in professional life';

  @override
  String get onboardingContextRelationshipsLabel =>
      'React less, understand more';

  @override
  String get onboardingContextHardDecisionLabel =>
      'Find steadiness in uncertainty';

  @override
  String get onboardingContextSkip => 'Choose later';

  @override
  String get onboardingVoiceTitle =>
      'Choose the author that guides your practice';

  @override
  String get onboardingVoiceSubtitle =>
      'You can change this anytime in settings.';

  @override
  String get onboardingVoiceSenecaSubtitle => 'direct, no detours';

  @override
  String get onboardingVoiceEpictetusSubtitle =>
      'focus on what you can control';

  @override
  String get onboardingVoiceMarcusSubtitle => 'reflection and self-awareness';

  @override
  String get onboardingVoiceMixedSubtitle => 'variety of perspectives';

  @override
  String get onboardingVoiceSkip => 'Choose later';

  @override
  String get onboardingTimeMorning => 'Morning';

  @override
  String get onboardingTimeLunch => 'Lunch';

  @override
  String get onboardingTimeEvening => 'Evening';

  @override
  String get onboardingTimeCustom => 'Custom time';

  @override
  String get onboardingReminderTitle => 'Keep the rhythm.';

  @override
  String get onboardingReminderSubtitle =>
      'A daily reminder at the time you choose — nothing more.';

  @override
  String get onboardingReminderToggleLabel => 'Enable daily reminder';

  @override
  String onboardingReminderTimeSelected(String time) {
    return 'Selected: $time';
  }

  @override
  String onboardingReminderTimezoneLabel(String timezone) {
    return 'Timezone: $timezone';
  }

  @override
  String get onboardingHowItWorksTitle => 'How it works';

  @override
  String get onboardingHowItWorksSubtitle => 'Simple. Direct. Every day.';

  @override
  String get onboardingHowItWorksBullet1 =>
      'A verified quote from Seneca, Epictetus, or Marcus Aurelius — not internet phrases.';

  @override
  String get onboardingHowItWorksBullet2 =>
      'A practical action to apply today, in the context you choose.';

  @override
  String get onboardingHowItWorksBullet3 =>
      'No endless quizzes. No gamification. Just real practice, every day.';

  @override
  String get onboardingHowItWorksQuote =>
      '\"Philosophy is not found in words, but in deeds.\"\n— Seneca';

  @override
  String get onboardingDoneTitle => 'Done. Your first day is ready.';

  @override
  String get onboardingDoneSubtitle => 'No rush. One step at a time.';

  @override
  String get onboardingDonePersonalizeHint =>
      'You can personalize your experience anytime in settings.';

  @override
  String get onboardingDoneButton => 'See my first insight';

  @override
  String onboardingDoneContextChip(String context) {
    return 'Area: $context';
  }

  @override
  String onboardingDoneVoiceChip(String voice) {
    return 'Voice: $voice';
  }

  @override
  String onboardingDoneTimeChip(String time) {
    return 'Time: $time';
  }

  @override
  String get onboardingDoneReminderChip => 'Reminder: active';

  @override
  String get onboardingIntroTitle => 'Less reaction.\nMore intention.';

  @override
  String get onboardingIntroSubtitle => '1 verified quote. 1 action for today.';

  @override
  String get onboardingIntroTodayLabel => 'Today, to begin';

  @override
  String get onboardingIntroActionLabel => 'Today\'s action';

  @override
  String get onboardingIntroHowItWorks => 'See how it works';

  @override
  String get onboardingIntroCta => 'Customize my practice';

  @override
  String get onboardingIntroExampleQuote =>
      '\"It is not events that disturb us, but our interpretation of them.\"';

  @override
  String get onboardingIntroExampleAuthor => 'Epictetus';

  @override
  String get onboardingIntroExampleAction =>
      'Rewrite a recent event without using adjectives — a 2-minute practice.';

  @override
  String get onboardingSkipButton => 'Skip';

  @override
  String get onboardingBackTooltip => 'Back';

  @override
  String onboardingProgressLabel(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingBrandTitle => 'AETHOR';

  @override
  String get paywallMainTitle => 'Practice with depth. No limits.';

  @override
  String get paywallMainDescription =>
      'Full daily ritual. History, favorites, and tracks without restriction.';

  @override
  String get paywallBullet1 => 'Complete and unlimited history.';

  @override
  String get paywallBullet2 => 'Unlimited favorites and quick revisit.';

  @override
  String get paywallBullet3 => 'Guided in-depth tracks.';

  @override
  String get paywallPlanAnnualTitle => 'Annual Plan';

  @override
  String get paywallPlanAnnualSubtitle => '7 days free';

  @override
  String get paywallPlanAnnualHighlight => 'Best value';

  @override
  String get paywallPlanMonthlyTitle => 'Monthly Plan';

  @override
  String get paywallPlanMonthlySubtitle => 'Monthly payment';

  @override
  String get paywallButtonAnnual => 'Start 7 days free';

  @override
  String get paywallButtonMonthly => 'Subscribe now';

  @override
  String get paywallContinueFree => 'Continue for free';

  @override
  String get paywallRestorePurchase => 'Restore purchase';

  @override
  String get paywallCancelNotice => 'Cancel anytime. No commitment.';

  @override
  String get paywallComparisonHeaderFeatures => 'Features';

  @override
  String get paywallComparisonHeaderFree => 'Free';

  @override
  String get paywallComparisonHeaderPro => 'Pro';

  @override
  String get paywallComparisonFeature1 => 'Daily quote + practice';

  @override
  String get paywallComparisonFeature2 => 'Full history';

  @override
  String get paywallComparisonFeature3 => 'Unlimited favorites';

  @override
  String get paywallComparisonFeature4 => 'Practical audio';

  @override
  String get paywallComparisonFeature5 => 'Guided tracks';

  @override
  String get paywallComparisonFeature6 => 'Advanced customization';

  @override
  String get paywallComparisonFeature7 => 'Priority support';

  @override
  String get subscriptionProTitle => 'Aethor Pro';

  @override
  String get subscriptionProDescription =>
      'Full history, unlimited favorites, and guided tracks.';

  @override
  String get subscriptionViewPlansBtn => 'See Pro plans';

  @override
  String get subscriptionRestoreBtn => 'Restore purchase';

  @override
  String get subscriptionBadgeTrialActive => 'Trial active';

  @override
  String get subscriptionBadgeSubscriptionActive => 'Subscription active';

  @override
  String get subscriptionPlanAnnual => 'Annual plan';

  @override
  String get subscriptionPlanMonthly => 'Monthly plan';

  @override
  String get subscriptionTrialRenewal => 'Renews on';

  @override
  String get subscriptionNextBilling => 'Next billing:';

  @override
  String get subscriptionManageBtn => 'Manage subscription';

  @override
  String get subscriptionRestoreTextBtn => 'Restore';

  @override
  String get subscriptionSuccessTrialTitle => 'Trial started successfully';

  @override
  String get subscriptionSuccessProTitle => 'Pro activated successfully';

  @override
  String get subscriptionSuccessTrialMessage =>
      '7 days to practice with all features.';

  @override
  String get subscriptionSuccessProMessage =>
      'Your subscription is active. Enjoy Pro features.';

  @override
  String get subscriptionSuccessFeature1 => 'Full history';

  @override
  String get subscriptionSuccessFeature2 => 'Unlimited favorites';

  @override
  String get subscriptionSuccessFeature3 => 'Guided tracks';

  @override
  String get subscriptionSuccessFeature4 => 'Practical audio';

  @override
  String get subscriptionSuccessContinue => 'Continue';

  @override
  String get subscriptionSuccessBack => 'Back to start';

  @override
  String get restorePurchaseTitle => 'Restore purchase';

  @override
  String get restorePurchaseLoading => 'Restoring purchase...';

  @override
  String get restorePurchaseSuccessTitle => 'Purchase restored';

  @override
  String get restorePurchaseSuccessMessage =>
      'Your Pro access is active again.';

  @override
  String get restorePurchaseContinueBtn => 'Continue';

  @override
  String get restorePurchaseErrorTitle => 'Could not restore';

  @override
  String get restorePurchaseErrorMessage => 'Try again or contact support.';

  @override
  String get restorePurchaseRetryBtn => 'Try again';

  @override
  String get restorePurchaseSupportBtn => 'Contact support';

  @override
  String get processingPurchaseMessage => 'Confirming your subscription...';

  @override
  String get premiumFullhistoryTitle => 'Full history is a Pro feature';

  @override
  String get premiumFullhistoryDescription =>
      'Review every recorded practice, with no time limit.';

  @override
  String get premiumFavoriteslimitTitle => 'Unlimited favorites are Pro';

  @override
  String get premiumFavoriteslimitDescription =>
      'Save as many quotes as you want to revisit later.';

  @override
  String get premiumAudioTitle => 'Guided audio is Pro';

  @override
  String get premiumAudioDescription =>
      'Listen to guided practices with focus and clarity.';

  @override
  String get premiumTrailTitle => 'Guided tracks are Pro';

  @override
  String get premiumTrailDescription =>
      'Follow structured tracks to deepen your practice.';

  @override
  String get premiumViewPlans => 'See plans';

  @override
  String get premiumContinueFree => 'Continue for free';

  @override
  String get premiumRestorePurchase => 'Restore purchase';

  @override
  String get checkinTitle => 'Daily Check-in';

  @override
  String get checkinAppliedBtn => 'I applied it today';

  @override
  String get checkinNotAppliedBtn => 'I didn\'t apply it';

  @override
  String get checkinSaving => 'Saving...';

  @override
  String get checkinRegisteredTitle => 'Check-in recorded';

  @override
  String get checkinAppliedMessage => 'You applied today\'s practice.';

  @override
  String get checkinNotAppliedMessage => 'Recorded. New practice tomorrow.';

  @override
  String get checkinReflectionLabel => 'YOUR REFLECTION';

  @override
  String get checkinFooterMessage => 'Return tomorrow for a new practice.';

  @override
  String get quoteCardLabel => 'QUOTE OF THE DAY';

  @override
  String get quoteCardFavoriteSave => 'Save to favorites';

  @override
  String get quoteCardFavoriteRemove => 'Remove from favorites';

  @override
  String get quoteCardIntentionLabel => 'INTENTION:';

  @override
  String get practiceCardContextLabel => 'Context';

  @override
  String get practiceCardTimeLabel => 'Estimated time';

  @override
  String get practiceCardHowApply => 'How to apply today';

  @override
  String get practiceCardExpectedImpactLabel => 'Expected impact:';

  @override
  String get practiceCardCompletionSignalLabel => 'Completion signal:';

  @override
  String get practiceCardReflectionLabel => 'Daily reflection:';

  @override
  String get dayDetailPracticeLabel => 'Day\'s practice';

  @override
  String get dayDetailQuoteLabel => 'QUOTE';

  @override
  String get dayDetailPracticeAppliedLabel => 'PRACTICE APPLIED';

  @override
  String get dayDetailReflectionLabel => 'YOUR REFLECTION';

  @override
  String get dayDetailStatusCompleted => 'Practice completed';

  @override
  String get dayDetailStatusNotApplied => 'Not applied';

  @override
  String get historyStatusCompleted => 'Done';

  @override
  String get historyStatusSkipped => 'Skipped';

  @override
  String get notificationPromptIosTitle =>
      '\"Aethor\" wants to send notifications';

  @override
  String get notificationPromptIosDescription =>
      'Notifications may include alerts, sounds, and icon badges. This can be configured in Settings.';

  @override
  String get notificationPromptIosDeny => 'Don\'t Allow';

  @override
  String get notificationPromptIosAllow => 'Allow';

  @override
  String get notificationPromptAndroidTitle =>
      'Allow Aethor to send notifications?';

  @override
  String get notificationPromptAndroidDescription =>
      'Notifications may include alerts, sounds, and icon badges.';

  @override
  String get notificationPromptAndroidDeny => 'DON\'T ALLOW';

  @override
  String get notificationPromptAndroidAllow => 'ALLOW';

  @override
  String get notificationNudgeTitle => 'A daily reminder for your practice.';

  @override
  String get notificationNudgeDescription =>
      'Choose the time. The reminder will be brief.';

  @override
  String get notificationNudgeEnable => 'Enable reminders';

  @override
  String get notificationNudgeLater => 'Not now';

  @override
  String get notificationResultGrantedTitle => 'Daily reminder enabled';

  @override
  String get notificationResultGrantedMessage =>
      'You\'ll receive a reminder every day.';

  @override
  String get notificationResultAdjustTime => 'Adjust time';

  @override
  String get notificationResultDeniedTitle => 'No problem';

  @override
  String get notificationResultDeniedMessage =>
      'You can enable reminders later in Settings.';

  @override
  String get notificationResultGoToSettings => 'Go to Settings';

  @override
  String get notificationSettingDailyReminder => 'Daily Reminder';

  @override
  String get notificationSettingDailySchedule => 'Every day at';

  @override
  String get notificationSettingPermissionDenied => 'Permission denied';

  @override
  String get notificationSettingEnableSystem =>
      'Enable notifications in system settings to receive reminders.';

  @override
  String get notificationSettingOpenSettings => 'Open Settings';

  @override
  String get notificationSettingTimeLabel => 'REMINDER TIME';

  @override
  String get notificationSettingTimezoneLabel => 'TIMEZONE';

  @override
  String get notificationSettingReminderInfo =>
      'You\'ll receive a reminder every day at the chosen time.';

  @override
  String get loadingStateDefaultMessage => 'Preparing your practice...';

  @override
  String get loadingStateDefaultSubtitle => 'Today\'s content is on its way.';

  @override
  String get errorStateDefaultTitle => 'Connection failed.';

  @override
  String get errorStateDefaultMessage => 'Check your network and try again.';

  @override
  String get errorStateRetryButton => 'Try again';

  @override
  String get offlineBannerTitle => 'Offline mode';

  @override
  String get offlineBannerSubtitle => 'Showing cached content';

  @override
  String get offlineBannerSync => 'SYNC';
}
