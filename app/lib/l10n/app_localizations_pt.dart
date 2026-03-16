// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String appVersion(String version) {
    return 'Aethor • Versão $version';
  }

  @override
  String get appTagline => 'Clareza para agir.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDone => 'Concluir';

  @override
  String get actionSignOut => 'Sair';

  @override
  String get actionReset => 'Resetar';

  @override
  String get actionSync => 'Sincronizar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionSkip => 'Pular';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionRepeat => 'Repetir';

  @override
  String get actionRegister => 'Registrar';

  @override
  String get actionCopyFcm => 'Copiar FCM';

  @override
  String get navToday => 'Hoje';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get weekdayMonday => 'Segunda-feira';

  @override
  String get weekdayTuesday => 'Terça-feira';

  @override
  String get weekdayWednesday => 'Quarta-feira';

  @override
  String get weekdayThursday => 'Quinta-feira';

  @override
  String get weekdayFriday => 'Sexta-feira';

  @override
  String get weekdaySaturday => 'Sábado';

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get weekdayShortMon => 'seg';

  @override
  String get weekdayShortTue => 'ter';

  @override
  String get weekdayShortWed => 'qua';

  @override
  String get weekdayShortThu => 'qui';

  @override
  String get weekdayShortFri => 'sex';

  @override
  String get weekdayShortSat => 'sáb';

  @override
  String get weekdayShortSun => 'dom';

  @override
  String get monthJanuary => 'janeiro';

  @override
  String get monthFebruary => 'fevereiro';

  @override
  String get monthMarch => 'março';

  @override
  String get monthApril => 'abril';

  @override
  String get monthMay => 'maio';

  @override
  String get monthJune => 'junho';

  @override
  String get monthJuly => 'julho';

  @override
  String get monthAugust => 'agosto';

  @override
  String get monthSeptember => 'setembro';

  @override
  String get monthOctober => 'outubro';

  @override
  String get monthNovember => 'novembro';

  @override
  String get monthDecember => 'dezembro';

  @override
  String get monthShortJan => 'jan';

  @override
  String get monthShortFeb => 'fev';

  @override
  String get monthShortMar => 'mar';

  @override
  String get monthShortApr => 'abr';

  @override
  String get monthShortMay => 'mai';

  @override
  String get monthShortJun => 'jun';

  @override
  String get monthShortJul => 'jul';

  @override
  String get monthShortAug => 'ago';

  @override
  String get monthShortSep => 'set';

  @override
  String get monthShortOct => 'out';

  @override
  String get monthShortNov => 'nov';

  @override
  String get monthShortDec => 'dez';

  @override
  String dateFullLabel(String weekday, int day, String month) {
    return '$weekday, $day de $month';
  }

  @override
  String get authorMarcusAurelius => 'Marco Aurélio';

  @override
  String get authorSeneca => 'Sêneca';

  @override
  String get authorEpictetus => 'Epicteto';

  @override
  String get authorMusoniusRufus => 'Musônio Rufo';

  @override
  String get authorMixed => 'Misto';

  @override
  String get contextWork => 'Disciplina';

  @override
  String get contextRelationships => 'Relacionamentos';

  @override
  String get contextAnxiety => 'Ansiedade';

  @override
  String get contextFocus => 'Foco';

  @override
  String get contextHardDecision => 'Decisão difícil';

  @override
  String get languagePt => 'Português';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get homeTitle => 'Hoje';

  @override
  String get offlineTitle => 'Você está offline.';

  @override
  String get offlineDescription =>
      'Conecte-se para sincronizar o conteúdo diário.';

  @override
  String get errorContentFailed =>
      'O conteúdo de hoje não carregou. Tente novamente.';

  @override
  String get emptyNoContent => 'Sem conteúdo diário disponível.';

  @override
  String get emptySyncLater => 'Tente sincronizar novamente em instantes.';

  @override
  String get favoriteRemoved => 'Removido dos favoritos.';

  @override
  String get favoriteAdded => 'Adicionado aos favoritos.';

  @override
  String get errorActionFailed =>
      'Não foi possível concluir a ação. Tente novamente.';

  @override
  String get checkinAppliedSuccess => 'Prática registrada com sucesso.';

  @override
  String get checkinNotAppliedSuccess => 'Check-in concluído.';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historyProUpsellTitle => 'Histórico completo é Pro';

  @override
  String get historyProUpsellDesc =>
      'Revise todas as suas práticas. Observe os padrões.';

  @override
  String get historyProUpsellButton => 'Ver planos Pro';

  @override
  String get historyEmptyOnline =>
      'Seu histórico começa com a primeira prática.';

  @override
  String get historyEmptyFirstRecord =>
      'A prática de hoje será o primeiro registro.';

  @override
  String get historyEmptyOffline => 'Você está offline.';

  @override
  String get historyEmptySync => 'Conecte-se para sincronizar seu histórico.';

  @override
  String historyLimitLabel(int count, int limit) {
    return '$count/$limit dias';
  }

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesEmptyOnline =>
      'As citações que ressoam com você aparecerão aqui.';

  @override
  String get favoritesEmptyHint =>
      'Salve a citação do dia para revisitar quando precisar.';

  @override
  String get favoritesEmptyTodayCta => 'Ver citação de hoje';

  @override
  String get favoritesSearchHint => 'Buscar citação ou autor...';

  @override
  String favoritesSearchEmpty(String query) {
    return 'Nenhum resultado para \"$query\".';
  }

  @override
  String get favoritesProUpsellTitle => 'Favoritos ilimitados são Pro';

  @override
  String get favoritesProUpsellDesc =>
      'Salve cada citação para revisitar quando precisar.';

  @override
  String get favoritesProUpsellButton => 'Ver planos Pro';

  @override
  String get favoritesRemoveSuccess => 'Removido dos favoritos.';

  @override
  String get favoritesRemoveError => 'Não foi possível remover o favorito.';

  @override
  String get favoritesRemoveTooltip => 'Remover dos favoritos';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubtitle => 'CONFIGURAÇÕES E PREFERÊNCIAS';

  @override
  String get settingsSectionGeneral => 'Geral';

  @override
  String get settingsSectionSubscription => 'Assinatura';

  @override
  String get settingsSectionContent => 'Conteúdo';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguagePickerTitle => 'Idioma';

  @override
  String get settingsTimezone => 'Fuso Horário';

  @override
  String settingsTimezoneAuto(String label) {
    return '$label (detectado automaticamente)';
  }

  @override
  String get settingsPreferredAuthors => 'Autores Preferidos';

  @override
  String get settingsPreferredContext => 'Contexto Preferencial';

  @override
  String get settingsPreferredContextSubtitle => 'Personalize suas práticas';

  @override
  String get settingsAuthorsAll => 'Todos (Modo Misto)';

  @override
  String get settingsAuthorsNone => 'Nenhum';

  @override
  String get settingsAuthorsCustom => 'Personalizado';

  @override
  String get settingsVerifiedSources => 'Fontes Verificadas';

  @override
  String get settingsAlways => 'Sempre';

  @override
  String get settingsLogout => 'Sair da conta';

  @override
  String get settingsLogoutDialogTitle => 'Sair da conta?';

  @override
  String get settingsLogoutDialogMessage =>
      'Seus check-ins e favoritos estão salvos na nuvem e serão restaurados ao entrar novamente.';

  @override
  String get settingsManageSubscriptionSnackbar =>
      'Gerencie sua assinatura na App Store/Play Store.';

  @override
  String get settingsOpenSystemSettingsHint =>
      'Abra as configurações do sistema para permitir notificações.';

  @override
  String get settingsResetOnboardingTitle => 'Resetar onboarding?';

  @override
  String get settingsResetOnboardingMessage =>
      'Isso reabre o fluxo inicial e limpa as preferências de onboarding.';

  @override
  String get settingsResetOnboardingButton => 'Resetar onboarding';

  @override
  String get settingsResetOnboardingSuccess =>
      'Onboarding será exibido ao reabrir o app.';

  @override
  String get settingsTzBrasilia => 'Brasília (GMT−3)';

  @override
  String get settingsTzRioBranco => 'Rio Branco (GMT−5)';

  @override
  String get splashTagline => 'Clareza para agir.';

  @override
  String get splashLoadingMessage => 'Preparando seu insight de hoje...';

  @override
  String get onboardingContextQuestion =>
      'Qual área você quer fortalecer agora?';

  @override
  String get onboardingContextSubtitle => 'Isso personaliza o insight de hoje.';

  @override
  String get onboardingContextHelper => 'Escolha uma opção para continuar.';

  @override
  String get onboardingContextAnxietyLabel =>
      'Recuperar clareza quando a mente acelera';

  @override
  String get onboardingContextFocusLabel => 'Separar o essencial do urgente';

  @override
  String get onboardingContextWorkLabel =>
      'Agir com intenção no ambiente profissional';

  @override
  String get onboardingContextRelationshipsLabel =>
      'Reagir menos, entender mais';

  @override
  String get onboardingContextHardDecisionLabel =>
      'Encontrar firmeza na incerteza';

  @override
  String get onboardingContextSkip => 'Escolher depois';

  @override
  String get onboardingVoiceTitle => 'Escolha o autor que guia sua prática';

  @override
  String get onboardingVoiceSubtitle =>
      'Você pode trocar a qualquer momento nos ajustes.';

  @override
  String get onboardingVoiceSenecaSubtitle => 'direto ao ponto, sem rodeios';

  @override
  String get onboardingVoiceEpictetusSubtitle =>
      'foco no que você pode controlar';

  @override
  String get onboardingVoiceMarcusSubtitle => 'reflexão e autoconsciência';

  @override
  String get onboardingVoiceMixedSubtitle => 'variedade de perspectivas';

  @override
  String get onboardingVoiceSkip => 'Escolher depois';

  @override
  String get onboardingTimeMorning => 'Manhã';

  @override
  String get onboardingTimeLunch => 'Almoço';

  @override
  String get onboardingTimeEvening => 'Noite';

  @override
  String get onboardingTimeCustom => 'Outro horário';

  @override
  String get onboardingReminderTitle => 'Mantenha o ritmo.';

  @override
  String get onboardingReminderSubtitle =>
      'Um lembrete diário no horário que você escolher — nada além disso.';

  @override
  String get onboardingReminderToggleLabel => 'Ativar lembrete diário';

  @override
  String onboardingReminderTimeSelected(String time) {
    return 'Selecionado: $time';
  }

  @override
  String onboardingReminderTimezoneLabel(String timezone) {
    return 'Fuso horário: $timezone';
  }

  @override
  String get onboardingHowItWorksTitle => 'Como funciona';

  @override
  String get onboardingHowItWorksSubtitle => 'Simples. Direto. Todo dia.';

  @override
  String get onboardingHowItWorksBullet1 =>
      'Uma citação verificada de Sêneca, Epicteto ou Marco Aurélio — não frases de internet.';

  @override
  String get onboardingHowItWorksBullet2 =>
      'Uma ação prática para aplicar hoje, no contexto que você escolher.';

  @override
  String get onboardingHowItWorksBullet3 =>
      'Sem quiz infinito. Sem gamificação. Só prática real, todo dia.';

  @override
  String get onboardingHowItWorksQuote =>
      '\"A filosofia não está nas palavras, mas nos atos.\"\n— Sêneca';

  @override
  String get onboardingDoneTitle => 'Pronto. Seu primeiro dia está preparado.';

  @override
  String get onboardingDoneSubtitle => 'Sem pressa. Um passo de cada vez.';

  @override
  String get onboardingDonePersonalizeHint =>
      'Você pode personalizar sua experiência a qualquer momento nos ajustes.';

  @override
  String get onboardingDoneButton => 'Ver meu primeiro insight';

  @override
  String onboardingDoneContextChip(String context) {
    return 'Área: $context';
  }

  @override
  String onboardingDoneVoiceChip(String voice) {
    return 'Voz: $voice';
  }

  @override
  String onboardingDoneTimeChip(String time) {
    return 'Horário: $time';
  }

  @override
  String get onboardingDoneReminderChip => 'Lembrete: ativo';

  @override
  String get onboardingIntroTitle => 'Menos reação.\nMais intenção.';

  @override
  String get onboardingIntroSubtitle =>
      '1 citação verificada. 1 ação para hoje.';

  @override
  String get onboardingIntroTodayLabel => 'Hoje, para começar';

  @override
  String get onboardingIntroActionLabel => 'Ação de hoje';

  @override
  String get onboardingIntroHowItWorks => 'Ver como funciona';

  @override
  String get onboardingIntroCta => 'Personalizar minha prática';

  @override
  String get onboardingIntroExampleQuote =>
      '\"Não são os acontecimentos que nos perturbam, mas a interpretação que fazemos deles.\"';

  @override
  String get onboardingIntroExampleAuthor => 'Epicteto';

  @override
  String get onboardingIntroExampleAction =>
      'Reescreva um fato recente sem usar adjetivos — uma prática de 2 minutos.';

  @override
  String get onboardingSkipButton => 'Pular';

  @override
  String get onboardingBackTooltip => 'Voltar';

  @override
  String onboardingProgressLabel(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get onboardingBrandTitle => 'AETHOR';

  @override
  String get paywallMainTitle => 'Pratique com profundidade. Sem limites.';

  @override
  String get paywallMainDescription =>
      'Ritual diário completo. Histórico, favoritos e trilhas sem restrição.';

  @override
  String get paywallBullet1 => 'Histórico completo e ilimitado.';

  @override
  String get paywallBullet2 => 'Favoritos sem limite e revisita rápida.';

  @override
  String get paywallBullet3 => 'Trilhas guiadas de aprofundamento.';

  @override
  String get paywallPlanAnnualTitle => 'Plano Anual';

  @override
  String get paywallPlanAnnualSubtitle => '7 dias grátis';

  @override
  String get paywallPlanAnnualHighlight => 'Mais vantajoso';

  @override
  String get paywallPlanMonthlyTitle => 'Plano Mensal';

  @override
  String get paywallPlanMonthlySubtitle => 'Pagamento mensal';

  @override
  String get paywallButtonAnnual => 'Iniciar 7 dias grátis';

  @override
  String get paywallButtonMonthly => 'Assinar agora';

  @override
  String get paywallContinueFree => 'Continuar no gratuito';

  @override
  String get paywallRestorePurchase => 'Restaurar compra';

  @override
  String get paywallCancelNotice => 'Cancele quando quiser. Sem compromisso.';

  @override
  String get paywallComparisonHeaderFeatures => 'Recursos';

  @override
  String get paywallComparisonHeaderFree => 'Gratuito';

  @override
  String get paywallComparisonHeaderPro => 'Pro';

  @override
  String get paywallComparisonFeature1 => 'Citação + prática diária';

  @override
  String get paywallComparisonFeature2 => 'Histórico completo';

  @override
  String get paywallComparisonFeature3 => 'Favoritos ilimitados';

  @override
  String get paywallComparisonFeature4 => 'Áudios práticos';

  @override
  String get paywallComparisonFeature5 => 'Trilhas guiadas';

  @override
  String get paywallComparisonFeature6 => 'Personalização avançada';

  @override
  String get paywallComparisonFeature7 => 'Suporte prioritário';

  @override
  String get subscriptionProTitle => 'Aethor Pro';

  @override
  String get subscriptionProDescription =>
      'Histórico completo, favoritos ilimitados e trilhas guiadas.';

  @override
  String get subscriptionViewPlansBtn => 'Ver planos Pro';

  @override
  String get subscriptionRestoreBtn => 'Restaurar compra';

  @override
  String get subscriptionBadgeTrialActive => 'Teste ativo';

  @override
  String get subscriptionBadgeSubscriptionActive => 'Assinatura ativa';

  @override
  String get subscriptionPlanAnnual => 'Plano anual';

  @override
  String get subscriptionPlanMonthly => 'Plano mensal';

  @override
  String get subscriptionTrialRenewal => 'Renova em';

  @override
  String get subscriptionNextBilling => 'Próxima cobrança:';

  @override
  String get subscriptionManageBtn => 'Gerenciar assinatura';

  @override
  String get subscriptionRestoreTextBtn => 'Restaurar';

  @override
  String get subscriptionSuccessTrialTitle => 'Teste iniciado com sucesso';

  @override
  String get subscriptionSuccessProTitle => 'Pro ativado com sucesso';

  @override
  String get subscriptionSuccessTrialMessage =>
      '7 dias para praticar com todos os recursos.';

  @override
  String get subscriptionSuccessProMessage =>
      'Sua assinatura está ativa. Aproveite os recursos Pro.';

  @override
  String get subscriptionSuccessFeature1 => 'Histórico completo';

  @override
  String get subscriptionSuccessFeature2 => 'Favoritos ilimitados';

  @override
  String get subscriptionSuccessFeature3 => 'Trilhas guiadas';

  @override
  String get subscriptionSuccessFeature4 => 'Áudios práticos';

  @override
  String get subscriptionSuccessContinue => 'Continuar';

  @override
  String get subscriptionSuccessBack => 'Voltar ao início';

  @override
  String get restorePurchaseTitle => 'Restaurar compra';

  @override
  String get restorePurchaseLoading => 'Restaurando compra...';

  @override
  String get restorePurchaseSuccessTitle => 'Compra restaurada';

  @override
  String get restorePurchaseSuccessMessage =>
      'Seu acesso Pro está ativo novamente.';

  @override
  String get restorePurchaseContinueBtn => 'Continuar';

  @override
  String get restorePurchaseErrorTitle => 'Não foi possível restaurar';

  @override
  String get restorePurchaseErrorMessage =>
      'Tente novamente ou fale com o suporte.';

  @override
  String get restorePurchaseRetryBtn => 'Tentar novamente';

  @override
  String get restorePurchaseSupportBtn => 'Falar com suporte';

  @override
  String get processingPurchaseMessage => 'Confirmando sua assinatura...';

  @override
  String get premiumFullhistoryTitle => 'Histórico completo é um recurso Pro';

  @override
  String get premiumFullhistoryDescription =>
      'Revise cada prática registrada, sem limite de tempo.';

  @override
  String get premiumFavoriteslimitTitle => 'Favoritos ilimitados são Pro';

  @override
  String get premiumFavoriteslimitDescription =>
      'Salve quantas citações quiser para revisitar depois.';

  @override
  String get premiumAudioTitle => 'Áudios guiados são Pro';

  @override
  String get premiumAudioDescription =>
      'Ouça práticas guiadas com foco e clareza.';

  @override
  String get premiumTrailTitle => 'Trilhas guiadas são Pro';

  @override
  String get premiumTrailDescription =>
      'Siga trilhas estruturadas para aprofundar sua prática.';

  @override
  String get premiumViewPlans => 'Ver planos';

  @override
  String get premiumContinueFree => 'Continuar no gratuito';

  @override
  String get premiumRestorePurchase => 'Restaurar compra';

  @override
  String get checkinTitle => 'Check-in Diário';

  @override
  String get checkinAppliedBtn => 'Apliquei hoje';

  @override
  String get checkinNotAppliedBtn => 'Não apliquei';

  @override
  String get checkinSaving => 'Salvando...';

  @override
  String get checkinRegisteredTitle => 'Check-in registrado';

  @override
  String get checkinAppliedMessage => 'Você aplicou a prática de hoje.';

  @override
  String get checkinNotAppliedMessage => 'Registrado. Amanhã há nova prática.';

  @override
  String get checkinReflectionLabel => 'SUA REFLEXÃO';

  @override
  String get checkinFooterMessage => 'Retorne amanhã para nova prática.';

  @override
  String get quoteCardLabel => 'CITAÇÃO DO DIA';

  @override
  String get quoteCardFavoriteSave => 'Salvar nos favoritos';

  @override
  String get quoteCardFavoriteRemove => 'Remover dos favoritos';

  @override
  String get quoteCardIntentionLabel => 'INTENÇÃO:';

  @override
  String get practiceCardContextLabel => 'Situação';

  @override
  String get practiceCardTimeLabel => 'Tempo previsto';

  @override
  String get practiceCardHowApply => 'Como aplicar hoje';

  @override
  String get practiceCardExpectedImpactLabel => 'Impacto esperado:';

  @override
  String get practiceCardCompletionSignalLabel => 'Sinal de conclusão:';

  @override
  String get practiceCardReflectionLabel => 'Reflexão do dia:';

  @override
  String get dayDetailPracticeLabel => 'Prática do dia';

  @override
  String get dayDetailQuoteLabel => 'CITAÇÃO';

  @override
  String get dayDetailPracticeAppliedLabel => 'PRÁTICA APLICADA';

  @override
  String get dayDetailReflectionLabel => 'SUA REFLEXÃO';

  @override
  String get dayDetailStatusCompleted => 'Prática concluída';

  @override
  String get dayDetailStatusNotApplied => 'Não aplicada';

  @override
  String get historyStatusCompleted => 'Feito';

  @override
  String get historyStatusSkipped => 'Pulado';

  @override
  String get notificationPromptIosTitle =>
      '\"Aethor\" quer enviar notificações';

  @override
  String get notificationPromptIosDescription =>
      'Notificações podem incluir alertas, sons e emblemas de ícone. Isso pode ser configurado em Ajustes.';

  @override
  String get notificationPromptIosDeny => 'Não Permitir';

  @override
  String get notificationPromptIosAllow => 'Permitir';

  @override
  String get notificationPromptAndroidTitle =>
      'Permitir que Aethor envie notificações?';

  @override
  String get notificationPromptAndroidDescription =>
      'As notificações podem incluir alertas, sons e emblemas de ícone.';

  @override
  String get notificationPromptAndroidDeny => 'NÃO PERMITIR';

  @override
  String get notificationPromptAndroidAllow => 'PERMITIR';

  @override
  String get notificationNudgeTitle => 'Um lembrete diário para sua prática.';

  @override
  String get notificationNudgeDescription =>
      'Escolha o horário. O lembrete será breve.';

  @override
  String get notificationNudgeEnable => 'Ativar lembretes';

  @override
  String get notificationNudgeLater => 'Agora não';

  @override
  String get notificationResultGrantedTitle => 'Lembrete diário ativado';

  @override
  String get notificationResultGrantedMessage =>
      'Você receberá um lembrete todos os dias.';

  @override
  String get notificationResultAdjustTime => 'Ajustar horário';

  @override
  String get notificationResultDeniedTitle => 'Sem problema';

  @override
  String get notificationResultDeniedMessage =>
      'Você pode ativar lembretes depois em Ajustes.';

  @override
  String get notificationResultGoToSettings => 'Ir para Ajustes';

  @override
  String get notificationSettingDailyReminder => 'Lembrete Diário';

  @override
  String get notificationSettingDailySchedule => 'Todos os dias às';

  @override
  String get notificationSettingPermissionDenied => 'Permissão negada';

  @override
  String get notificationSettingEnableSystem =>
      'Ative notificações nas configurações do sistema para receber lembretes.';

  @override
  String get notificationSettingOpenSettings => 'Abrir Configurações';

  @override
  String get notificationSettingTimeLabel => 'HORÁRIO DO LEMBRETE';

  @override
  String get notificationSettingTimezoneLabel => 'FUSO HORÁRIO';

  @override
  String get notificationSettingReminderInfo =>
      'Você receberá um lembrete todos os dias no horário escolhido.';

  @override
  String get loadingStateDefaultMessage => 'Preparando sua prática...';

  @override
  String get loadingStateDefaultSubtitle =>
      'O conteúdo de hoje está a caminho.';

  @override
  String get errorStateDefaultTitle => 'Falha na conexão.';

  @override
  String get errorStateDefaultMessage =>
      'Verifique sua rede e tente novamente.';

  @override
  String get errorStateRetryButton => 'Tentar novamente';

  @override
  String get offlineBannerTitle => 'Modo offline';

  @override
  String get offlineBannerSubtitle => 'Mostrando conteúdo em cache';

  @override
  String get offlineBannerSync => 'SINCRONIZAR';
}
