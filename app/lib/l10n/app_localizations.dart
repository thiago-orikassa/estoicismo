import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appVersion.
  ///
  /// In pt, this message translates to:
  /// **'Aethor • Versão {version}'**
  String appVersion(String version);

  /// No description provided for @appTagline.
  ///
  /// In pt, this message translates to:
  /// **'Clareza para agir.'**
  String get appTagline;

  /// No description provided for @actionCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionDone.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get actionDone;

  /// No description provided for @actionSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get actionSignOut;

  /// No description provided for @actionReset.
  ///
  /// In pt, this message translates to:
  /// **'Resetar'**
  String get actionReset;

  /// No description provided for @actionSync.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizar'**
  String get actionSync;

  /// No description provided for @actionContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get actionContinue;

  /// No description provided for @actionSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get actionSkip;

  /// No description provided for @actionBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get actionBack;

  /// No description provided for @actionRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get actionClose;

  /// No description provided for @actionRepeat.
  ///
  /// In pt, this message translates to:
  /// **'Repetir'**
  String get actionRepeat;

  /// No description provided for @actionRegister.
  ///
  /// In pt, this message translates to:
  /// **'Registrar'**
  String get actionRegister;

  /// No description provided for @actionCopyFcm.
  ///
  /// In pt, this message translates to:
  /// **'Copiar FCM'**
  String get actionCopyFcm;

  /// No description provided for @navToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get navToday;

  /// No description provided for @navHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get navHistory;

  /// No description provided for @navFavorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get navFavorites;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @weekdayMonday.
  ///
  /// In pt, this message translates to:
  /// **'Segunda-feira'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In pt, this message translates to:
  /// **'Terça-feira'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In pt, this message translates to:
  /// **'Quarta-feira'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In pt, this message translates to:
  /// **'Quinta-feira'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In pt, this message translates to:
  /// **'Sexta-feira'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In pt, this message translates to:
  /// **'Sábado'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In pt, this message translates to:
  /// **'Domingo'**
  String get weekdaySunday;

  /// No description provided for @weekdayShortMon.
  ///
  /// In pt, this message translates to:
  /// **'seg'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In pt, this message translates to:
  /// **'ter'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In pt, this message translates to:
  /// **'qua'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In pt, this message translates to:
  /// **'qui'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In pt, this message translates to:
  /// **'sex'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In pt, this message translates to:
  /// **'sáb'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In pt, this message translates to:
  /// **'dom'**
  String get weekdayShortSun;

  /// No description provided for @monthJanuary.
  ///
  /// In pt, this message translates to:
  /// **'janeiro'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In pt, this message translates to:
  /// **'fevereiro'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In pt, this message translates to:
  /// **'março'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In pt, this message translates to:
  /// **'abril'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In pt, this message translates to:
  /// **'maio'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In pt, this message translates to:
  /// **'junho'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In pt, this message translates to:
  /// **'julho'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In pt, this message translates to:
  /// **'agosto'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In pt, this message translates to:
  /// **'setembro'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In pt, this message translates to:
  /// **'outubro'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In pt, this message translates to:
  /// **'novembro'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In pt, this message translates to:
  /// **'dezembro'**
  String get monthDecember;

  /// No description provided for @monthShortJan.
  ///
  /// In pt, this message translates to:
  /// **'jan'**
  String get monthShortJan;

  /// No description provided for @monthShortFeb.
  ///
  /// In pt, this message translates to:
  /// **'fev'**
  String get monthShortFeb;

  /// No description provided for @monthShortMar.
  ///
  /// In pt, this message translates to:
  /// **'mar'**
  String get monthShortMar;

  /// No description provided for @monthShortApr.
  ///
  /// In pt, this message translates to:
  /// **'abr'**
  String get monthShortApr;

  /// No description provided for @monthShortMay.
  ///
  /// In pt, this message translates to:
  /// **'mai'**
  String get monthShortMay;

  /// No description provided for @monthShortJun.
  ///
  /// In pt, this message translates to:
  /// **'jun'**
  String get monthShortJun;

  /// No description provided for @monthShortJul.
  ///
  /// In pt, this message translates to:
  /// **'jul'**
  String get monthShortJul;

  /// No description provided for @monthShortAug.
  ///
  /// In pt, this message translates to:
  /// **'ago'**
  String get monthShortAug;

  /// No description provided for @monthShortSep.
  ///
  /// In pt, this message translates to:
  /// **'set'**
  String get monthShortSep;

  /// No description provided for @monthShortOct.
  ///
  /// In pt, this message translates to:
  /// **'out'**
  String get monthShortOct;

  /// No description provided for @monthShortNov.
  ///
  /// In pt, this message translates to:
  /// **'nov'**
  String get monthShortNov;

  /// No description provided for @monthShortDec.
  ///
  /// In pt, this message translates to:
  /// **'dez'**
  String get monthShortDec;

  /// No description provided for @dateFullLabel.
  ///
  /// In pt, this message translates to:
  /// **'{weekday}, {day} de {month}'**
  String dateFullLabel(String weekday, int day, String month);

  /// No description provided for @authorMarcusAurelius.
  ///
  /// In pt, this message translates to:
  /// **'Marco Aurélio'**
  String get authorMarcusAurelius;

  /// No description provided for @authorSeneca.
  ///
  /// In pt, this message translates to:
  /// **'Sêneca'**
  String get authorSeneca;

  /// No description provided for @authorEpictetus.
  ///
  /// In pt, this message translates to:
  /// **'Epicteto'**
  String get authorEpictetus;

  /// No description provided for @authorMusoniusRufus.
  ///
  /// In pt, this message translates to:
  /// **'Musônio Rufo'**
  String get authorMusoniusRufus;

  /// No description provided for @authorMixed.
  ///
  /// In pt, this message translates to:
  /// **'Misto'**
  String get authorMixed;

  /// No description provided for @contextWork.
  ///
  /// In pt, this message translates to:
  /// **'Disciplina'**
  String get contextWork;

  /// No description provided for @contextRelationships.
  ///
  /// In pt, this message translates to:
  /// **'Relacionamentos'**
  String get contextRelationships;

  /// No description provided for @contextAnxiety.
  ///
  /// In pt, this message translates to:
  /// **'Ansiedade'**
  String get contextAnxiety;

  /// No description provided for @contextFocus.
  ///
  /// In pt, this message translates to:
  /// **'Foco'**
  String get contextFocus;

  /// No description provided for @contextHardDecision.
  ///
  /// In pt, this message translates to:
  /// **'Decisão difícil'**
  String get contextHardDecision;

  /// No description provided for @languagePt.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePt;

  /// No description provided for @languageEn.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageEs.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @homeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get homeTitle;

  /// No description provided for @offlineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você está offline.'**
  String get offlineTitle;

  /// No description provided for @offlineDescription.
  ///
  /// In pt, this message translates to:
  /// **'Conecte-se para sincronizar o conteúdo diário.'**
  String get offlineDescription;

  /// No description provided for @errorContentFailed.
  ///
  /// In pt, this message translates to:
  /// **'O conteúdo de hoje não carregou. Tente novamente.'**
  String get errorContentFailed;

  /// No description provided for @emptyNoContent.
  ///
  /// In pt, this message translates to:
  /// **'Sem conteúdo diário disponível.'**
  String get emptyNoContent;

  /// No description provided for @emptySyncLater.
  ///
  /// In pt, this message translates to:
  /// **'Tente sincronizar novamente em instantes.'**
  String get emptySyncLater;

  /// No description provided for @favoriteRemoved.
  ///
  /// In pt, this message translates to:
  /// **'Removido dos favoritos.'**
  String get favoriteRemoved;

  /// No description provided for @favoriteAdded.
  ///
  /// In pt, this message translates to:
  /// **'Adicionado aos favoritos.'**
  String get favoriteAdded;

  /// No description provided for @errorActionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a ação. Tente novamente.'**
  String get errorActionFailed;

  /// No description provided for @checkinAppliedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Prática registrada com sucesso.'**
  String get checkinAppliedSuccess;

  /// No description provided for @checkinNotAppliedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Check-in concluído.'**
  String get checkinNotAppliedSuccess;

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get historyTitle;

  /// No description provided for @historyProUpsellTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico completo é Pro'**
  String get historyProUpsellTitle;

  /// No description provided for @historyProUpsellDesc.
  ///
  /// In pt, this message translates to:
  /// **'Revise todas as suas práticas. Observe os padrões.'**
  String get historyProUpsellDesc;

  /// No description provided for @historyProUpsellButton.
  ///
  /// In pt, this message translates to:
  /// **'Ver planos Pro'**
  String get historyProUpsellButton;

  /// No description provided for @historyEmptyOnline.
  ///
  /// In pt, this message translates to:
  /// **'Seu histórico começa com a primeira prática.'**
  String get historyEmptyOnline;

  /// No description provided for @historyEmptyFirstRecord.
  ///
  /// In pt, this message translates to:
  /// **'A prática de hoje será o primeiro registro.'**
  String get historyEmptyFirstRecord;

  /// No description provided for @historyEmptyOffline.
  ///
  /// In pt, this message translates to:
  /// **'Você está offline.'**
  String get historyEmptyOffline;

  /// No description provided for @historyEmptySync.
  ///
  /// In pt, this message translates to:
  /// **'Conecte-se para sincronizar seu histórico.'**
  String get historyEmptySync;

  /// No description provided for @historyLimitLabel.
  ///
  /// In pt, this message translates to:
  /// **'{count}/{limit} dias'**
  String historyLimitLabel(int count, int limit);

  /// No description provided for @favoritesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyOnline.
  ///
  /// In pt, this message translates to:
  /// **'As citações que ressoam com você aparecerão aqui.'**
  String get favoritesEmptyOnline;

  /// No description provided for @favoritesEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Salve a citação do dia para revisitar quando precisar.'**
  String get favoritesEmptyHint;

  /// No description provided for @favoritesEmptyTodayCta.
  ///
  /// In pt, this message translates to:
  /// **'Ver citação de hoje'**
  String get favoritesEmptyTodayCta;

  /// No description provided for @favoritesSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar citação ou autor...'**
  String get favoritesSearchHint;

  /// No description provided for @favoritesSearchEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado para \"{query}\".'**
  String favoritesSearchEmpty(String query);

  /// No description provided for @favoritesProUpsellTitle.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos ilimitados são Pro'**
  String get favoritesProUpsellTitle;

  /// No description provided for @favoritesProUpsellDesc.
  ///
  /// In pt, this message translates to:
  /// **'Salve cada citação para revisitar quando precisar.'**
  String get favoritesProUpsellDesc;

  /// No description provided for @favoritesProUpsellButton.
  ///
  /// In pt, this message translates to:
  /// **'Ver planos Pro'**
  String get favoritesProUpsellButton;

  /// No description provided for @favoritesRemoveSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Removido dos favoritos.'**
  String get favoritesRemoveSuccess;

  /// No description provided for @favoritesRemoveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível remover o favorito.'**
  String get favoritesRemoveError;

  /// No description provided for @favoritesRemoveTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get favoritesRemoveTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'CONFIGURAÇÕES E PREFERÊNCIAS'**
  String get settingsSubtitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In pt, this message translates to:
  /// **'Geral'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionSubscription.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura'**
  String get settingsSectionSubscription;

  /// No description provided for @settingsSectionContent.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo'**
  String get settingsSectionContent;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguagePickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguagePickerTitle;

  /// No description provided for @settingsTimezone.
  ///
  /// In pt, this message translates to:
  /// **'Fuso Horário'**
  String get settingsTimezone;

  /// No description provided for @settingsTimezoneAuto.
  ///
  /// In pt, this message translates to:
  /// **'{label} (detectado automaticamente)'**
  String settingsTimezoneAuto(String label);

  /// No description provided for @settingsPreferredAuthors.
  ///
  /// In pt, this message translates to:
  /// **'Autores Preferidos'**
  String get settingsPreferredAuthors;

  /// No description provided for @settingsPreferredContext.
  ///
  /// In pt, this message translates to:
  /// **'Contexto Preferencial'**
  String get settingsPreferredContext;

  /// No description provided for @settingsPreferredContextSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Personalize suas práticas'**
  String get settingsPreferredContextSubtitle;

  /// No description provided for @settingsAuthorsAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos (Modo Misto)'**
  String get settingsAuthorsAll;

  /// No description provided for @settingsAuthorsNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum'**
  String get settingsAuthorsNone;

  /// No description provided for @settingsAuthorsCustom.
  ///
  /// In pt, this message translates to:
  /// **'Personalizado'**
  String get settingsAuthorsCustom;

  /// No description provided for @settingsVerifiedSources.
  ///
  /// In pt, this message translates to:
  /// **'Fontes Verificadas'**
  String get settingsVerifiedSources;

  /// No description provided for @settingsAlways.
  ///
  /// In pt, this message translates to:
  /// **'Sempre'**
  String get settingsAlways;

  /// No description provided for @settingsLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta?'**
  String get settingsLogoutDialogTitle;

  /// No description provided for @settingsLogoutDialogMessage.
  ///
  /// In pt, this message translates to:
  /// **'Seus check-ins e favoritos estão salvos na nuvem e serão restaurados ao entrar novamente.'**
  String get settingsLogoutDialogMessage;

  /// No description provided for @settingsManageSubscriptionSnackbar.
  ///
  /// In pt, this message translates to:
  /// **'Gerencie sua assinatura na App Store/Play Store.'**
  String get settingsManageSubscriptionSnackbar;

  /// No description provided for @settingsOpenSystemSettingsHint.
  ///
  /// In pt, this message translates to:
  /// **'Abra as configurações do sistema para permitir notificações.'**
  String get settingsOpenSystemSettingsHint;

  /// No description provided for @settingsResetOnboardingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resetar onboarding?'**
  String get settingsResetOnboardingTitle;

  /// No description provided for @settingsResetOnboardingMessage.
  ///
  /// In pt, this message translates to:
  /// **'Isso reabre o fluxo inicial e limpa as preferências de onboarding.'**
  String get settingsResetOnboardingMessage;

  /// No description provided for @settingsResetOnboardingButton.
  ///
  /// In pt, this message translates to:
  /// **'Resetar onboarding'**
  String get settingsResetOnboardingButton;

  /// No description provided for @settingsResetOnboardingSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Onboarding será exibido ao reabrir o app.'**
  String get settingsResetOnboardingSuccess;

  /// No description provided for @settingsTzBrasilia.
  ///
  /// In pt, this message translates to:
  /// **'Brasília (GMT−3)'**
  String get settingsTzBrasilia;

  /// No description provided for @settingsTzRioBranco.
  ///
  /// In pt, this message translates to:
  /// **'Rio Branco (GMT−5)'**
  String get settingsTzRioBranco;

  /// No description provided for @splashTagline.
  ///
  /// In pt, this message translates to:
  /// **'Clareza para agir.'**
  String get splashTagline;

  /// No description provided for @splashLoadingMessage.
  ///
  /// In pt, this message translates to:
  /// **'Preparando seu insight de hoje...'**
  String get splashLoadingMessage;

  /// No description provided for @onboardingContextQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Qual área você quer fortalecer agora?'**
  String get onboardingContextQuestion;

  /// No description provided for @onboardingContextSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Isso personaliza o insight de hoje.'**
  String get onboardingContextSubtitle;

  /// No description provided for @onboardingContextHelper.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma opção para continuar.'**
  String get onboardingContextHelper;

  /// No description provided for @onboardingContextAnxietyLabel.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar clareza quando a mente acelera'**
  String get onboardingContextAnxietyLabel;

  /// No description provided for @onboardingContextFocusLabel.
  ///
  /// In pt, this message translates to:
  /// **'Separar o essencial do urgente'**
  String get onboardingContextFocusLabel;

  /// No description provided for @onboardingContextWorkLabel.
  ///
  /// In pt, this message translates to:
  /// **'Agir com intenção no ambiente profissional'**
  String get onboardingContextWorkLabel;

  /// No description provided for @onboardingContextRelationshipsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Reagir menos, entender mais'**
  String get onboardingContextRelationshipsLabel;

  /// No description provided for @onboardingContextHardDecisionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Encontrar firmeza na incerteza'**
  String get onboardingContextHardDecisionLabel;

  /// No description provided for @onboardingContextSkip.
  ///
  /// In pt, this message translates to:
  /// **'Escolher depois'**
  String get onboardingContextSkip;

  /// No description provided for @onboardingVoiceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o autor que guia sua prática'**
  String get onboardingVoiceTitle;

  /// No description provided for @onboardingVoiceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você pode trocar a qualquer momento nos ajustes.'**
  String get onboardingVoiceSubtitle;

  /// No description provided for @onboardingVoiceSenecaSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'direto ao ponto, sem rodeios'**
  String get onboardingVoiceSenecaSubtitle;

  /// No description provided for @onboardingVoiceEpictetusSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'foco no que você pode controlar'**
  String get onboardingVoiceEpictetusSubtitle;

  /// No description provided for @onboardingVoiceMarcusSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'reflexão e autoconsciência'**
  String get onboardingVoiceMarcusSubtitle;

  /// No description provided for @onboardingVoiceMixedSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'variedade de perspectivas'**
  String get onboardingVoiceMixedSubtitle;

  /// No description provided for @onboardingVoiceSkip.
  ///
  /// In pt, this message translates to:
  /// **'Escolher depois'**
  String get onboardingVoiceSkip;

  /// No description provided for @onboardingTimeMorning.
  ///
  /// In pt, this message translates to:
  /// **'Manhã'**
  String get onboardingTimeMorning;

  /// No description provided for @onboardingTimeLunch.
  ///
  /// In pt, this message translates to:
  /// **'Almoço'**
  String get onboardingTimeLunch;

  /// No description provided for @onboardingTimeEvening.
  ///
  /// In pt, this message translates to:
  /// **'Noite'**
  String get onboardingTimeEvening;

  /// No description provided for @onboardingTimeCustom.
  ///
  /// In pt, this message translates to:
  /// **'Outro horário'**
  String get onboardingTimeCustom;

  /// No description provided for @onboardingReminderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mantenha o ritmo.'**
  String get onboardingReminderTitle;

  /// No description provided for @onboardingReminderSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Um lembrete diário no horário que você escolher — nada além disso.'**
  String get onboardingReminderSubtitle;

  /// No description provided for @onboardingReminderToggleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ativar lembrete diário'**
  String get onboardingReminderToggleLabel;

  /// No description provided for @onboardingReminderTimeSelected.
  ///
  /// In pt, this message translates to:
  /// **'Selecionado: {time}'**
  String onboardingReminderTimeSelected(String time);

  /// No description provided for @onboardingReminderTimezoneLabel.
  ///
  /// In pt, this message translates to:
  /// **'Fuso horário: {timezone}'**
  String onboardingReminderTimezoneLabel(String timezone);

  /// No description provided for @onboardingHowItWorksTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como funciona'**
  String get onboardingHowItWorksTitle;

  /// No description provided for @onboardingHowItWorksSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Simples. Direto. Todo dia.'**
  String get onboardingHowItWorksSubtitle;

  /// No description provided for @onboardingHowItWorksBullet1.
  ///
  /// In pt, this message translates to:
  /// **'Uma citação verificada de Sêneca, Epicteto ou Marco Aurélio — não frases de internet.'**
  String get onboardingHowItWorksBullet1;

  /// No description provided for @onboardingHowItWorksBullet2.
  ///
  /// In pt, this message translates to:
  /// **'Uma ação prática para aplicar hoje, no contexto que você escolher.'**
  String get onboardingHowItWorksBullet2;

  /// No description provided for @onboardingHowItWorksBullet3.
  ///
  /// In pt, this message translates to:
  /// **'Sem quiz infinito. Sem gamificação. Só prática real, todo dia.'**
  String get onboardingHowItWorksBullet3;

  /// No description provided for @onboardingHowItWorksQuote.
  ///
  /// In pt, this message translates to:
  /// **'\"A filosofia não está nas palavras, mas nos atos.\"\n— Sêneca'**
  String get onboardingHowItWorksQuote;

  /// No description provided for @onboardingDoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pronto. Seu primeiro dia está preparado.'**
  String get onboardingDoneTitle;

  /// No description provided for @onboardingDoneSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem pressa. Um passo de cada vez.'**
  String get onboardingDoneSubtitle;

  /// No description provided for @onboardingDonePersonalizeHint.
  ///
  /// In pt, this message translates to:
  /// **'Você pode personalizar sua experiência a qualquer momento nos ajustes.'**
  String get onboardingDonePersonalizeHint;

  /// No description provided for @onboardingDoneButton.
  ///
  /// In pt, this message translates to:
  /// **'Ver meu primeiro insight'**
  String get onboardingDoneButton;

  /// No description provided for @onboardingDoneContextChip.
  ///
  /// In pt, this message translates to:
  /// **'Área: {context}'**
  String onboardingDoneContextChip(String context);

  /// No description provided for @onboardingDoneVoiceChip.
  ///
  /// In pt, this message translates to:
  /// **'Voz: {voice}'**
  String onboardingDoneVoiceChip(String voice);

  /// No description provided for @onboardingDoneTimeChip.
  ///
  /// In pt, this message translates to:
  /// **'Horário: {time}'**
  String onboardingDoneTimeChip(String time);

  /// No description provided for @onboardingDoneReminderChip.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete: ativo'**
  String get onboardingDoneReminderChip;

  /// No description provided for @onboardingIntroTitle.
  ///
  /// In pt, this message translates to:
  /// **'Menos reação.\nMais intenção.'**
  String get onboardingIntroTitle;

  /// No description provided for @onboardingIntroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'1 citação verificada. 1 ação para hoje.'**
  String get onboardingIntroSubtitle;

  /// No description provided for @onboardingIntroTodayLabel.
  ///
  /// In pt, this message translates to:
  /// **'Hoje, para começar'**
  String get onboardingIntroTodayLabel;

  /// No description provided for @onboardingIntroActionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ação de hoje'**
  String get onboardingIntroActionLabel;

  /// No description provided for @onboardingIntroHowItWorks.
  ///
  /// In pt, this message translates to:
  /// **'Ver como funciona'**
  String get onboardingIntroHowItWorks;

  /// No description provided for @onboardingIntroCta.
  ///
  /// In pt, this message translates to:
  /// **'Personalizar minha prática'**
  String get onboardingIntroCta;

  /// No description provided for @onboardingIntroExampleQuote.
  ///
  /// In pt, this message translates to:
  /// **'\"Não são os acontecimentos que nos perturbam, mas a interpretação que fazemos deles.\"'**
  String get onboardingIntroExampleQuote;

  /// No description provided for @onboardingIntroExampleAuthor.
  ///
  /// In pt, this message translates to:
  /// **'Epicteto'**
  String get onboardingIntroExampleAuthor;

  /// No description provided for @onboardingIntroExampleAction.
  ///
  /// In pt, this message translates to:
  /// **'Reescreva um fato recente sem usar adjetivos — uma prática de 2 minutos.'**
  String get onboardingIntroExampleAction;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onboardingSkipButton;

  /// No description provided for @onboardingBackTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get onboardingBackTooltip;

  /// No description provided for @onboardingProgressLabel.
  ///
  /// In pt, this message translates to:
  /// **'Passo {current} de {total}'**
  String onboardingProgressLabel(int current, int total);

  /// No description provided for @onboardingBrandTitle.
  ///
  /// In pt, this message translates to:
  /// **'AETHOR'**
  String get onboardingBrandTitle;

  /// No description provided for @paywallMainTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pratique com profundidade. Sem limites.'**
  String get paywallMainTitle;

  /// No description provided for @paywallMainDescription.
  ///
  /// In pt, this message translates to:
  /// **'Ritual diário completo. Histórico, favoritos e trilhas sem restrição.'**
  String get paywallMainDescription;

  /// No description provided for @paywallBullet1.
  ///
  /// In pt, this message translates to:
  /// **'Histórico completo e ilimitado.'**
  String get paywallBullet1;

  /// No description provided for @paywallBullet2.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos sem limite e revisita rápida.'**
  String get paywallBullet2;

  /// No description provided for @paywallBullet3.
  ///
  /// In pt, this message translates to:
  /// **'Trilhas guiadas de aprofundamento.'**
  String get paywallBullet3;

  /// No description provided for @paywallPlanAnnualTitle.
  ///
  /// In pt, this message translates to:
  /// **'Plano Anual'**
  String get paywallPlanAnnualTitle;

  /// No description provided for @paywallPlanAnnualSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'7 dias grátis'**
  String get paywallPlanAnnualSubtitle;

  /// No description provided for @paywallPlanAnnualHighlight.
  ///
  /// In pt, this message translates to:
  /// **'Mais vantajoso'**
  String get paywallPlanAnnualHighlight;

  /// No description provided for @paywallPlanMonthlyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Plano Mensal'**
  String get paywallPlanMonthlyTitle;

  /// No description provided for @paywallPlanMonthlySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento mensal'**
  String get paywallPlanMonthlySubtitle;

  /// No description provided for @paywallButtonAnnual.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar 7 dias grátis'**
  String get paywallButtonAnnual;

  /// No description provided for @paywallButtonMonthly.
  ///
  /// In pt, this message translates to:
  /// **'Assinar agora'**
  String get paywallButtonMonthly;

  /// No description provided for @paywallContinueFree.
  ///
  /// In pt, this message translates to:
  /// **'Continuar no gratuito'**
  String get paywallContinueFree;

  /// No description provided for @paywallRestorePurchase.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compra'**
  String get paywallRestorePurchase;

  /// No description provided for @paywallCancelNotice.
  ///
  /// In pt, this message translates to:
  /// **'Cancele quando quiser. Sem compromisso.'**
  String get paywallCancelNotice;

  /// No description provided for @paywallComparisonHeaderFeatures.
  ///
  /// In pt, this message translates to:
  /// **'Recursos'**
  String get paywallComparisonHeaderFeatures;

  /// No description provided for @paywallComparisonHeaderFree.
  ///
  /// In pt, this message translates to:
  /// **'Gratuito'**
  String get paywallComparisonHeaderFree;

  /// No description provided for @paywallComparisonHeaderPro.
  ///
  /// In pt, this message translates to:
  /// **'Pro'**
  String get paywallComparisonHeaderPro;

  /// No description provided for @paywallComparisonFeature1.
  ///
  /// In pt, this message translates to:
  /// **'Citação + prática diária'**
  String get paywallComparisonFeature1;

  /// No description provided for @paywallComparisonFeature2.
  ///
  /// In pt, this message translates to:
  /// **'Histórico completo'**
  String get paywallComparisonFeature2;

  /// No description provided for @paywallComparisonFeature3.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos ilimitados'**
  String get paywallComparisonFeature3;

  /// No description provided for @paywallComparisonFeature4.
  ///
  /// In pt, this message translates to:
  /// **'Áudios práticos'**
  String get paywallComparisonFeature4;

  /// No description provided for @paywallComparisonFeature5.
  ///
  /// In pt, this message translates to:
  /// **'Trilhas guiadas'**
  String get paywallComparisonFeature5;

  /// No description provided for @paywallComparisonFeature6.
  ///
  /// In pt, this message translates to:
  /// **'Personalização avançada'**
  String get paywallComparisonFeature6;

  /// No description provided for @paywallComparisonFeature7.
  ///
  /// In pt, this message translates to:
  /// **'Suporte prioritário'**
  String get paywallComparisonFeature7;

  /// No description provided for @subscriptionProTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aethor Pro'**
  String get subscriptionProTitle;

  /// No description provided for @subscriptionProDescription.
  ///
  /// In pt, this message translates to:
  /// **'Histórico completo, favoritos ilimitados e trilhas guiadas.'**
  String get subscriptionProDescription;

  /// No description provided for @subscriptionViewPlansBtn.
  ///
  /// In pt, this message translates to:
  /// **'Ver planos Pro'**
  String get subscriptionViewPlansBtn;

  /// No description provided for @subscriptionRestoreBtn.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compra'**
  String get subscriptionRestoreBtn;

  /// No description provided for @subscriptionBadgeTrialActive.
  ///
  /// In pt, this message translates to:
  /// **'Teste ativo'**
  String get subscriptionBadgeTrialActive;

  /// No description provided for @subscriptionBadgeSubscriptionActive.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura ativa'**
  String get subscriptionBadgeSubscriptionActive;

  /// No description provided for @subscriptionPlanAnnual.
  ///
  /// In pt, this message translates to:
  /// **'Plano anual'**
  String get subscriptionPlanAnnual;

  /// No description provided for @subscriptionPlanMonthly.
  ///
  /// In pt, this message translates to:
  /// **'Plano mensal'**
  String get subscriptionPlanMonthly;

  /// No description provided for @subscriptionTrialRenewal.
  ///
  /// In pt, this message translates to:
  /// **'Renova em'**
  String get subscriptionTrialRenewal;

  /// No description provided for @subscriptionNextBilling.
  ///
  /// In pt, this message translates to:
  /// **'Próxima cobrança:'**
  String get subscriptionNextBilling;

  /// No description provided for @subscriptionManageBtn.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar assinatura'**
  String get subscriptionManageBtn;

  /// No description provided for @subscriptionRestoreTextBtn.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar'**
  String get subscriptionRestoreTextBtn;

  /// No description provided for @subscriptionSuccessTrialTitle.
  ///
  /// In pt, this message translates to:
  /// **'Teste iniciado com sucesso'**
  String get subscriptionSuccessTrialTitle;

  /// No description provided for @subscriptionSuccessProTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pro ativado com sucesso'**
  String get subscriptionSuccessProTitle;

  /// No description provided for @subscriptionSuccessTrialMessage.
  ///
  /// In pt, this message translates to:
  /// **'7 dias para praticar com todos os recursos.'**
  String get subscriptionSuccessTrialMessage;

  /// No description provided for @subscriptionSuccessProMessage.
  ///
  /// In pt, this message translates to:
  /// **'Sua assinatura está ativa. Aproveite os recursos Pro.'**
  String get subscriptionSuccessProMessage;

  /// No description provided for @subscriptionSuccessFeature1.
  ///
  /// In pt, this message translates to:
  /// **'Histórico completo'**
  String get subscriptionSuccessFeature1;

  /// No description provided for @subscriptionSuccessFeature2.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos ilimitados'**
  String get subscriptionSuccessFeature2;

  /// No description provided for @subscriptionSuccessFeature3.
  ///
  /// In pt, this message translates to:
  /// **'Trilhas guiadas'**
  String get subscriptionSuccessFeature3;

  /// No description provided for @subscriptionSuccessFeature4.
  ///
  /// In pt, this message translates to:
  /// **'Áudios práticos'**
  String get subscriptionSuccessFeature4;

  /// No description provided for @subscriptionSuccessContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get subscriptionSuccessContinue;

  /// No description provided for @subscriptionSuccessBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get subscriptionSuccessBack;

  /// No description provided for @restorePurchaseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compra'**
  String get restorePurchaseTitle;

  /// No description provided for @restorePurchaseLoading.
  ///
  /// In pt, this message translates to:
  /// **'Restaurando compra...'**
  String get restorePurchaseLoading;

  /// No description provided for @restorePurchaseSuccessTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compra restaurada'**
  String get restorePurchaseSuccessTitle;

  /// No description provided for @restorePurchaseSuccessMessage.
  ///
  /// In pt, this message translates to:
  /// **'Seu acesso Pro está ativo novamente.'**
  String get restorePurchaseSuccessMessage;

  /// No description provided for @restorePurchaseContinueBtn.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get restorePurchaseContinueBtn;

  /// No description provided for @restorePurchaseErrorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível restaurar'**
  String get restorePurchaseErrorTitle;

  /// No description provided for @restorePurchaseErrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tente novamente ou fale com o suporte.'**
  String get restorePurchaseErrorMessage;

  /// No description provided for @restorePurchaseRetryBtn.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get restorePurchaseRetryBtn;

  /// No description provided for @restorePurchaseSupportBtn.
  ///
  /// In pt, this message translates to:
  /// **'Falar com suporte'**
  String get restorePurchaseSupportBtn;

  /// No description provided for @processingPurchaseMessage.
  ///
  /// In pt, this message translates to:
  /// **'Confirmando sua assinatura...'**
  String get processingPurchaseMessage;

  /// No description provided for @premiumFullhistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico completo é um recurso Pro'**
  String get premiumFullhistoryTitle;

  /// No description provided for @premiumFullhistoryDescription.
  ///
  /// In pt, this message translates to:
  /// **'Revise cada prática registrada, sem limite de tempo.'**
  String get premiumFullhistoryDescription;

  /// No description provided for @premiumFavoriteslimitTitle.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos ilimitados são Pro'**
  String get premiumFavoriteslimitTitle;

  /// No description provided for @premiumFavoriteslimitDescription.
  ///
  /// In pt, this message translates to:
  /// **'Salve quantas citações quiser para revisitar depois.'**
  String get premiumFavoriteslimitDescription;

  /// No description provided for @premiumAudioTitle.
  ///
  /// In pt, this message translates to:
  /// **'Áudios guiados são Pro'**
  String get premiumAudioTitle;

  /// No description provided for @premiumAudioDescription.
  ///
  /// In pt, this message translates to:
  /// **'Ouça práticas guiadas com foco e clareza.'**
  String get premiumAudioDescription;

  /// No description provided for @premiumTrailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Trilhas guiadas são Pro'**
  String get premiumTrailTitle;

  /// No description provided for @premiumTrailDescription.
  ///
  /// In pt, this message translates to:
  /// **'Siga trilhas estruturadas para aprofundar sua prática.'**
  String get premiumTrailDescription;

  /// No description provided for @premiumViewPlans.
  ///
  /// In pt, this message translates to:
  /// **'Ver planos'**
  String get premiumViewPlans;

  /// No description provided for @premiumContinueFree.
  ///
  /// In pt, this message translates to:
  /// **'Continuar no gratuito'**
  String get premiumContinueFree;

  /// No description provided for @premiumRestorePurchase.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compra'**
  String get premiumRestorePurchase;

  /// No description provided for @checkinTitle.
  ///
  /// In pt, this message translates to:
  /// **'Check-in Diário'**
  String get checkinTitle;

  /// No description provided for @checkinAppliedBtn.
  ///
  /// In pt, this message translates to:
  /// **'Apliquei hoje'**
  String get checkinAppliedBtn;

  /// No description provided for @checkinNotAppliedBtn.
  ///
  /// In pt, this message translates to:
  /// **'Não apliquei'**
  String get checkinNotAppliedBtn;

  /// No description provided for @checkinSaving.
  ///
  /// In pt, this message translates to:
  /// **'Salvando...'**
  String get checkinSaving;

  /// No description provided for @checkinRegisteredTitle.
  ///
  /// In pt, this message translates to:
  /// **'Check-in registrado'**
  String get checkinRegisteredTitle;

  /// No description provided for @checkinAppliedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você aplicou a prática de hoje.'**
  String get checkinAppliedMessage;

  /// No description provided for @checkinNotAppliedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Registrado. Amanhã há nova prática.'**
  String get checkinNotAppliedMessage;

  /// No description provided for @checkinReflectionLabel.
  ///
  /// In pt, this message translates to:
  /// **'SUA REFLEXÃO'**
  String get checkinReflectionLabel;

  /// No description provided for @checkinFooterMessage.
  ///
  /// In pt, this message translates to:
  /// **'Retorne amanhã para nova prática.'**
  String get checkinFooterMessage;

  /// No description provided for @quoteCardLabel.
  ///
  /// In pt, this message translates to:
  /// **'CITAÇÃO DO DIA'**
  String get quoteCardLabel;

  /// No description provided for @quoteCardFavoriteSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar nos favoritos'**
  String get quoteCardFavoriteSave;

  /// No description provided for @quoteCardFavoriteRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get quoteCardFavoriteRemove;

  /// No description provided for @quoteCardIntentionLabel.
  ///
  /// In pt, this message translates to:
  /// **'INTENÇÃO:'**
  String get quoteCardIntentionLabel;

  /// No description provided for @practiceCardContextLabel.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get practiceCardContextLabel;

  /// No description provided for @practiceCardTimeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tempo previsto'**
  String get practiceCardTimeLabel;

  /// No description provided for @practiceCardHowApply.
  ///
  /// In pt, this message translates to:
  /// **'Como aplicar hoje'**
  String get practiceCardHowApply;

  /// No description provided for @practiceCardExpectedImpactLabel.
  ///
  /// In pt, this message translates to:
  /// **'Impacto esperado:'**
  String get practiceCardExpectedImpactLabel;

  /// No description provided for @practiceCardCompletionSignalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Sinal de conclusão:'**
  String get practiceCardCompletionSignalLabel;

  /// No description provided for @practiceCardReflectionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Reflexão do dia:'**
  String get practiceCardReflectionLabel;

  /// No description provided for @dayDetailPracticeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Prática do dia'**
  String get dayDetailPracticeLabel;

  /// No description provided for @dayDetailQuoteLabel.
  ///
  /// In pt, this message translates to:
  /// **'CITAÇÃO'**
  String get dayDetailQuoteLabel;

  /// No description provided for @dayDetailPracticeAppliedLabel.
  ///
  /// In pt, this message translates to:
  /// **'PRÁTICA APLICADA'**
  String get dayDetailPracticeAppliedLabel;

  /// No description provided for @dayDetailReflectionLabel.
  ///
  /// In pt, this message translates to:
  /// **'SUA REFLEXÃO'**
  String get dayDetailReflectionLabel;

  /// No description provided for @dayDetailStatusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Prática concluída'**
  String get dayDetailStatusCompleted;

  /// No description provided for @dayDetailStatusNotApplied.
  ///
  /// In pt, this message translates to:
  /// **'Não aplicada'**
  String get dayDetailStatusNotApplied;

  /// No description provided for @historyStatusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Feito'**
  String get historyStatusCompleted;

  /// No description provided for @historyStatusSkipped.
  ///
  /// In pt, this message translates to:
  /// **'Pulado'**
  String get historyStatusSkipped;

  /// No description provided for @notificationPromptIosTitle.
  ///
  /// In pt, this message translates to:
  /// **'\"Aethor\" quer enviar notificações'**
  String get notificationPromptIosTitle;

  /// No description provided for @notificationPromptIosDescription.
  ///
  /// In pt, this message translates to:
  /// **'Notificações podem incluir alertas, sons e emblemas de ícone. Isso pode ser configurado em Ajustes.'**
  String get notificationPromptIosDescription;

  /// No description provided for @notificationPromptIosDeny.
  ///
  /// In pt, this message translates to:
  /// **'Não Permitir'**
  String get notificationPromptIosDeny;

  /// No description provided for @notificationPromptIosAllow.
  ///
  /// In pt, this message translates to:
  /// **'Permitir'**
  String get notificationPromptIosAllow;

  /// No description provided for @notificationPromptAndroidTitle.
  ///
  /// In pt, this message translates to:
  /// **'Permitir que Aethor envie notificações?'**
  String get notificationPromptAndroidTitle;

  /// No description provided for @notificationPromptAndroidDescription.
  ///
  /// In pt, this message translates to:
  /// **'As notificações podem incluir alertas, sons e emblemas de ícone.'**
  String get notificationPromptAndroidDescription;

  /// No description provided for @notificationPromptAndroidDeny.
  ///
  /// In pt, this message translates to:
  /// **'NÃO PERMITIR'**
  String get notificationPromptAndroidDeny;

  /// No description provided for @notificationPromptAndroidAllow.
  ///
  /// In pt, this message translates to:
  /// **'PERMITIR'**
  String get notificationPromptAndroidAllow;

  /// No description provided for @notificationNudgeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Um lembrete diário para sua prática.'**
  String get notificationNudgeTitle;

  /// No description provided for @notificationNudgeDescription.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o horário. O lembrete será breve.'**
  String get notificationNudgeDescription;

  /// No description provided for @notificationNudgeEnable.
  ///
  /// In pt, this message translates to:
  /// **'Ativar lembretes'**
  String get notificationNudgeEnable;

  /// No description provided for @notificationNudgeLater.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get notificationNudgeLater;

  /// No description provided for @notificationResultGrantedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete diário ativado'**
  String get notificationResultGrantedTitle;

  /// No description provided for @notificationResultGrantedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você receberá um lembrete todos os dias.'**
  String get notificationResultGrantedMessage;

  /// No description provided for @notificationResultAdjustTime.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar horário'**
  String get notificationResultAdjustTime;

  /// No description provided for @notificationResultDeniedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem problema'**
  String get notificationResultDeniedTitle;

  /// No description provided for @notificationResultDeniedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você pode ativar lembretes depois em Ajustes.'**
  String get notificationResultDeniedMessage;

  /// No description provided for @notificationResultGoToSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ir para Ajustes'**
  String get notificationResultGoToSettings;

  /// No description provided for @notificationSettingDailyReminder.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete Diário'**
  String get notificationSettingDailyReminder;

  /// No description provided for @notificationSettingDailySchedule.
  ///
  /// In pt, this message translates to:
  /// **'Todos os dias às'**
  String get notificationSettingDailySchedule;

  /// No description provided for @notificationSettingPermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permissão negada'**
  String get notificationSettingPermissionDenied;

  /// No description provided for @notificationSettingEnableSystem.
  ///
  /// In pt, this message translates to:
  /// **'Ative notificações nas configurações do sistema para receber lembretes.'**
  String get notificationSettingEnableSystem;

  /// No description provided for @notificationSettingOpenSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir Configurações'**
  String get notificationSettingOpenSettings;

  /// No description provided for @notificationSettingTimeLabel.
  ///
  /// In pt, this message translates to:
  /// **'HORÁRIO DO LEMBRETE'**
  String get notificationSettingTimeLabel;

  /// No description provided for @notificationSettingTimezoneLabel.
  ///
  /// In pt, this message translates to:
  /// **'FUSO HORÁRIO'**
  String get notificationSettingTimezoneLabel;

  /// No description provided for @notificationSettingReminderInfo.
  ///
  /// In pt, this message translates to:
  /// **'Você receberá um lembrete todos os dias no horário escolhido.'**
  String get notificationSettingReminderInfo;

  /// No description provided for @loadingStateDefaultMessage.
  ///
  /// In pt, this message translates to:
  /// **'Preparando sua prática...'**
  String get loadingStateDefaultMessage;

  /// No description provided for @loadingStateDefaultSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O conteúdo de hoje está a caminho.'**
  String get loadingStateDefaultSubtitle;

  /// No description provided for @errorStateDefaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Falha na conexão.'**
  String get errorStateDefaultTitle;

  /// No description provided for @errorStateDefaultMessage.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua rede e tente novamente.'**
  String get errorStateDefaultMessage;

  /// No description provided for @errorStateRetryButton.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get errorStateRetryButton;

  /// No description provided for @offlineBannerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Modo offline'**
  String get offlineBannerTitle;

  /// No description provided for @offlineBannerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Mostrando conteúdo em cache'**
  String get offlineBannerSubtitle;

  /// No description provided for @offlineBannerSync.
  ///
  /// In pt, this message translates to:
  /// **'SINCRONIZAR'**
  String get offlineBannerSync;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
