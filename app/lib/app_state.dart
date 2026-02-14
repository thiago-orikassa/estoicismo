import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/auth/session_service.dart';
import 'features/daily_quote/data/daily_repository.dart';
import 'features/daily_quote/domain/models.dart';
import 'core/domain/authors.dart';
import 'core/domain/subscription.dart';

enum NotificationPermissionStatus {
  unknown,
  granted,
  denied,
}

class AppState extends ChangeNotifier {
  AppState(this._repo, this._sessionService);

  final DailyRepository _repo;
  final SessionService _sessionService;
  SharedPreferences? _prefs;

  static const _onboardingKey = 'onboarding_complete';
  static const _timezoneKey = 'timezone';
  static const _preferredContextKey = 'preferred_context';
  static const _preferredAuthorsKey = 'preferred_authors';
  static const _reminderTimeKey = 'reminder_time';
  static const _remindersEnabledKey = 'reminders_enabled';
  static const _notificationPermissionKey = 'notification_permission';
  static const _checkinsKey = 'checkins';
  static const _hasCompletedFirstCheckinKey = 'has_completed_first_checkin';
  static const _hasShownFavoritePromptKey = 'has_shown_favorite_prompt';
  static const _authLoggedInKey = 'auth_logged_in';
  static const _subscriptionStatusKey = 'subscription_status';
  static const _subscriptionPlanKey = 'subscription_plan';
  static const _trialEndsAtKey = 'trial_ends_at';
  static const _nextBillingKey = 'next_billing_at';
  static const _lastPaywallViewKey = 'last_paywall_view';
  static const _lastPaywallDismissKey = 'last_paywall_dismiss';

  String userId = '';
  String timezone = 'America/Sao_Paulo';
  String preferredContext = 'trabalho';
  Set<String> preferredAuthors = kStoicAuthors.toSet();
  String? reminderTime;
  bool remindersEnabled = false;
  NotificationPermissionStatus notificationPermission =
      NotificationPermissionStatus.unknown;
  bool onboardingComplete = false;
  bool offline = false;
  bool sessionReady = false;
  bool isAuthenticated = false;
  bool hasCompletedFirstCheckin = false;
  bool hasShownFavoritePrompt = false;
  bool hasShownLoginPromptThisSession = false;

  SubscriptionStatus subscriptionStatus = SubscriptionStatus.free;
  SubscriptionPlan subscriptionPlan = SubscriptionPlan.annual;
  DateTime? trialEndsAt;
  DateTime? nextBillingDate;
  DateTime? lastPaywallView;
  DateTime? lastPaywallDismissed;

  bool loadingDaily = false;
  bool loadingHistory = false;
  bool loadingFavorites = false;

  String? error;
  DailyPackage? daily;
  List<DailyPackage> history = const [];
  List<Favorite> favorites = const [];
  final Map<String, CheckinRecord> _checkinsByDate = {};

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();

    onboardingComplete = _prefs?.getBool(_onboardingKey) ?? false;
    timezone = _prefs?.getString(_timezoneKey) ?? timezone;
    preferredContext =
        _prefs?.getString(_preferredContextKey) ?? preferredContext;
    preferredAuthors = _prefs?.getStringList(_preferredAuthorsKey)?.toSet() ??
        preferredAuthors;
    reminderTime = _prefs?.getString(_reminderTimeKey);
    remindersEnabled = _prefs?.getBool(_remindersEnabledKey) ?? false;
    isAuthenticated = _prefs?.getBool(_authLoggedInKey) ?? false;
    hasCompletedFirstCheckin =
        _prefs?.getBool(_hasCompletedFirstCheckinKey) ?? false;
    hasShownFavoritePrompt =
        _prefs?.getBool(_hasShownFavoritePromptKey) ?? false;
    final permissionRaw = _prefs?.getString(_notificationPermissionKey);
    if (permissionRaw != null) {
      notificationPermission = NotificationPermissionStatus.values.firstWhere(
        (value) => value.name == permissionRaw,
        orElse: () => NotificationPermissionStatus.unknown,
      );
    }
    final statusRaw = _prefs?.getString(_subscriptionStatusKey);
    if (statusRaw != null) {
      subscriptionStatus = SubscriptionStatus.values.firstWhere(
        (value) => value.name == statusRaw,
        orElse: () => SubscriptionStatus.free,
      );
    }
    final planRaw = _prefs?.getString(_subscriptionPlanKey);
    if (planRaw != null) {
      subscriptionPlan = SubscriptionPlan.values.firstWhere(
        (value) => value.name == planRaw,
        orElse: () => SubscriptionPlan.annual,
      );
    }
    final trialRaw = _prefs?.getString(_trialEndsAtKey);
    if (trialRaw != null) {
      trialEndsAt = DateTime.tryParse(trialRaw);
    }
    final billingRaw = _prefs?.getString(_nextBillingKey);
    if (billingRaw != null) {
      nextBillingDate = DateTime.tryParse(billingRaw);
    }
    final lastViewRaw = _prefs?.getString(_lastPaywallViewKey);
    if (lastViewRaw != null) {
      lastPaywallView = DateTime.tryParse(lastViewRaw);
    }
    final lastDismissRaw = _prefs?.getString(_lastPaywallDismissKey);
    if (lastDismissRaw != null) {
      lastPaywallDismissed = DateTime.tryParse(lastDismissRaw);
    }
    await _initializeSession();
    _loadCheckins();
  }

  Future<void> _initializeSession() async {
    try {
      final session = await _sessionService.ensureSession();
      userId = session.userId;
      sessionReady = true;
    } catch (e) {
      error = e.toString();
      if (e is SocketException) {
        offline = true;
      }
      sessionReady = false;
    }
  }

  void setTimezone(String value) {
    timezone = value;
    _prefs?.setString(_timezoneKey, value);
    notifyListeners();
  }

  Future<void> setPreferredContext(String value) async {
    if (preferredContext == value) return;
    preferredContext = value;
    await _prefs?.setString(_preferredContextKey, value);
    notifyListeners();
    await bootstrap();
  }

  void setPreferredAuthors(Set<String> value) {
    preferredAuthors = value;
    _prefs?.setStringList(_preferredAuthorsKey, value.toList());
    notifyListeners();
  }

  void setReminderTime(String? value) {
    reminderTime = value;
    if (value == null) {
      _prefs?.remove(_reminderTimeKey);
    } else {
      _prefs?.setString(_reminderTimeKey, value);
    }
    notifyListeners();
  }

  void setRemindersEnabled(bool value) {
    remindersEnabled = value;
    _prefs?.setBool(_remindersEnabledKey, value);
    notifyListeners();
  }

  void setNotificationPermission(NotificationPermissionStatus value) {
    notificationPermission = value;
    if (value == NotificationPermissionStatus.denied) {
      remindersEnabled = false;
      _prefs?.setBool(_remindersEnabledKey, false);
    }
    _prefs?.setString(_notificationPermissionKey, value.name);
    notifyListeners();
  }

  bool get canShowLoginPrompt =>
      !isAuthenticated && !hasShownLoginPromptThisSession;

  bool get shouldPromptAfterCheckin =>
      canShowLoginPrompt && !hasCompletedFirstCheckin;

  bool get shouldPromptAfterFavorite =>
      canShowLoginPrompt && !hasShownFavoritePrompt;

  void markAuthenticated(bool value) {
    isAuthenticated = value;
    _prefs?.setBool(_authLoggedInKey, value);
    notifyListeners();
  }

  void markLoginPromptShown() {
    hasShownLoginPromptThisSession = true;
  }

  void markLoginPromptDismissed() {
    hasShownLoginPromptThisSession = true;
  }

  void markFirstCheckinCompleted() {
    if (hasCompletedFirstCheckin) return;
    hasCompletedFirstCheckin = true;
    _prefs?.setBool(_hasCompletedFirstCheckinKey, true);
  }

  void markFavoritePromptShown() {
    if (hasShownFavoritePrompt) return;
    hasShownFavoritePrompt = true;
    _prefs?.setBool(_hasShownFavoritePromptKey, true);
  }

  bool get isPro => subscriptionStatus != SubscriptionStatus.free;

  bool get isTrial => subscriptionStatus == SubscriptionStatus.trial;

  bool get canShowPaywall {
    final now = DateTime.now();
    if (lastPaywallView != null &&
        now.difference(lastPaywallView!) < const Duration(hours: 24)) {
      return false;
    }
    if (lastPaywallDismissed != null &&
        now.difference(lastPaywallDismissed!) < const Duration(hours: 48)) {
      return false;
    }
    return true;
  }

  void markPaywallViewed() {
    lastPaywallView = DateTime.now();
    _prefs?.setString(_lastPaywallViewKey, lastPaywallView!.toIso8601String());
  }

  void markPaywallDismissed() {
    lastPaywallDismissed = DateTime.now();
    _prefs?.setString(
      _lastPaywallDismissKey,
      lastPaywallDismissed!.toIso8601String(),
    );
  }

  void startTrial(SubscriptionPlan plan) {
    subscriptionStatus = SubscriptionStatus.trial;
    subscriptionPlan = plan;
    trialEndsAt = DateTime.now().add(const Duration(days: 7));
    nextBillingDate = null;
    _persistSubscription();
    notifyListeners();
  }

  void activateSubscription(SubscriptionPlan plan) {
    subscriptionStatus = SubscriptionStatus.active;
    subscriptionPlan = plan;
    trialEndsAt = null;
    nextBillingDate = DateTime.now().add(
      plan == SubscriptionPlan.monthly
          ? const Duration(days: 30)
          : const Duration(days: 365),
    );
    _persistSubscription();
    notifyListeners();
  }

  void restoreSubscription() {
    subscriptionStatus = SubscriptionStatus.active;
    if (nextBillingDate == null) {
      nextBillingDate = DateTime.now().add(
        subscriptionPlan == SubscriptionPlan.monthly
            ? const Duration(days: 30)
            : const Duration(days: 365),
      );
    }
    _persistSubscription();
    notifyListeners();
  }

  CheckinRecord? checkinForDate(String dateLocal) {
    return _checkinsByDate[dateLocal];
  }

  void completeOnboarding() {
    onboardingComplete = true;
    _prefs?.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    onboardingComplete = false;
    preferredContext = 'trabalho';
    preferredAuthors = kStoicAuthors.toSet();
    reminderTime = null;
    remindersEnabled = false;
    notificationPermission = NotificationPermissionStatus.unknown;
    isAuthenticated = false;
    hasCompletedFirstCheckin = false;
    hasShownFavoritePrompt = false;
    hasShownLoginPromptThisSession = false;
    subscriptionStatus = SubscriptionStatus.free;
    subscriptionPlan = SubscriptionPlan.annual;
    trialEndsAt = null;
    nextBillingDate = null;
    lastPaywallView = null;
    lastPaywallDismissed = null;

    await _prefs?.remove(_onboardingKey);
    await _prefs?.remove(_preferredContextKey);
    await _prefs?.remove(_preferredAuthorsKey);
    await _prefs?.remove(_reminderTimeKey);
    await _prefs?.remove(_remindersEnabledKey);
    await _prefs?.remove(_notificationPermissionKey);
    await _prefs?.remove(_authLoggedInKey);
    await _prefs?.remove(_hasCompletedFirstCheckinKey);
    await _prefs?.remove(_hasShownFavoritePromptKey);
    await _prefs?.remove(_subscriptionStatusKey);
    await _prefs?.remove(_subscriptionPlanKey);
    await _prefs?.remove(_trialEndsAtKey);
    await _prefs?.remove(_nextBillingKey);
    await _prefs?.remove(_lastPaywallViewKey);
    await _prefs?.remove(_lastPaywallDismissKey);

    notifyListeners();
  }

  void _loadCheckins() {
    final raw = _prefs?.getString(_checkinsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _checkinsByDate
        ..clear()
        ..addEntries(
          decoded.map((item) {
            final record = CheckinRecord.fromJson(
              item as Map<String, dynamic>,
            );
            return MapEntry(record.dateLocal, record);
          }),
        );
    } catch (_) {
      _checkinsByDate.clear();
    }
  }

  Future<void> _saveCheckins() async {
    final values = _checkinsByDate.values.map((e) => e.toJson()).toList();
    await _prefs?.setString(_checkinsKey, jsonEncode(values));
  }

  void _persistSubscription() {
    _prefs?.setString(_subscriptionStatusKey, subscriptionStatus.name);
    _prefs?.setString(_subscriptionPlanKey, subscriptionPlan.name);
    if (trialEndsAt != null) {
      _prefs?.setString(_trialEndsAtKey, trialEndsAt!.toIso8601String());
    } else {
      _prefs?.remove(_trialEndsAtKey);
    }
    if (nextBillingDate != null) {
      _prefs?.setString(_nextBillingKey, nextBillingDate!.toIso8601String());
    } else {
      _prefs?.remove(_nextBillingKey);
    }
  }

  Future<void> bootstrap() async {
    error = null;
    await Future.wait([loadDaily(), loadHistory(), loadFavorites()]);
  }

  Future<void> loadDaily({String? dateLocal}) async {
    loadingDaily = true;
    notifyListeners();
    try {
      daily = await _repo.fetchDailyPackage(
        timezone: timezone,
        dateLocal: dateLocal,
        userContext: preferredContext,
      );
      offline = false;
    } catch (e) {
      error = e.toString();
      if (e is SocketException) {
        offline = true;
      }
    } finally {
      loadingDaily = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    loadingHistory = true;
    notifyListeners();
    try {
      history = await _repo.fetchHistory(
        timezone: timezone,
        days: 30,
        userContext: preferredContext,
      );
      offline = false;
    } catch (e) {
      error = e.toString();
      if (e is SocketException) {
        offline = true;
      }
    } finally {
      loadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    if (userId.isEmpty) return;
    loadingFavorites = true;
    notifyListeners();
    try {
      favorites = await _repo.listFavorites(userId: userId);
      offline = false;
    } catch (e) {
      error = e.toString();
      if (e is SocketException) {
        offline = true;
      }
    } finally {
      loadingFavorites = false;
      notifyListeners();
    }
  }

  bool isFavorited(String quoteId) {
    return favorites.any((f) => f.quoteId == quoteId);
  }

  Future<void> toggleFavorite(String quoteId) async {
    if (userId.isEmpty) return;
    if (isFavorited(quoteId)) {
      await _repo.removeFavorite(userId: userId, quoteId: quoteId);
    } else {
      await _repo.addFavorite(userId: userId, quoteId: quoteId);
    }
    await loadFavorites();
  }

  Quote? findQuoteById(String quoteId) {
    if (daily?.quote.id == quoteId) {
      return daily?.quote;
    }

    for (final item in history) {
      if (item.quote.id == quoteId) {
        return item.quote;
      }
    }
    return null;
  }

  Future<void> submitCheckin({required bool applied, String? note}) async {
    if (userId.isEmpty) return;
    final dateLocal =
        daily?.dateLocal ?? DateTime.now().toIso8601String().split('T').first;
    await _repo.submitCheckin(
      userId: userId,
      dateLocal: dateLocal,
      applied: applied,
      timezone: timezone,
      note: note,
    );
    final record = CheckinRecord(
      dateLocal: dateLocal,
      applied: applied,
      note: note?.trim(),
      createdAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    _checkinsByDate[dateLocal] = record;
    await _saveCheckins();
    notifyListeners();
  }
}

class CheckinRecord {
  CheckinRecord({
    required this.dateLocal,
    required this.applied,
    required this.createdAtUtc,
    this.note,
  });

  final String dateLocal;
  final bool applied;
  final String? note;
  final String createdAtUtc;

  factory CheckinRecord.fromJson(Map<String, dynamic> json) {
    return CheckinRecord(
      dateLocal: json['date_local'] as String,
      applied: json['applied'] as bool? ?? false,
      note: json['note'] as String?,
      createdAtUtc: json['created_at_utc'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_local': dateLocal,
      'applied': applied,
      if (note != null && note!.isNotEmpty) 'note': note,
      'created_at_utc': createdAtUtc,
    };
  }
}
