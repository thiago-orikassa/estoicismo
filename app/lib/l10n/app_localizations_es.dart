// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String appVersion(String version) {
    return 'Aethor • Versión $version';
  }

  @override
  String get appTagline => 'Claridad para actuar.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionSignOut => 'Cerrar sesión';

  @override
  String get actionReset => 'Reiniciar';

  @override
  String get actionSync => 'Sincronizar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionSkip => 'Omitir';

  @override
  String get actionBack => 'Volver';

  @override
  String get actionRetry => 'Intentar de nuevo';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionRepeat => 'Reintentar';

  @override
  String get actionRegister => 'Registrar';

  @override
  String get actionCopyFcm => 'Copiar FCM';

  @override
  String get navToday => 'Hoy';

  @override
  String get navHistory => 'Historial';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get weekdayMonday => 'Lunes';

  @override
  String get weekdayTuesday => 'Martes';

  @override
  String get weekdayWednesday => 'Miércoles';

  @override
  String get weekdayThursday => 'Jueves';

  @override
  String get weekdayFriday => 'Viernes';

  @override
  String get weekdaySaturday => 'Sábado';

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get weekdayShortMon => 'lun';

  @override
  String get weekdayShortTue => 'mar';

  @override
  String get weekdayShortWed => 'mié';

  @override
  String get weekdayShortThu => 'jue';

  @override
  String get weekdayShortFri => 'vie';

  @override
  String get weekdayShortSat => 'sáb';

  @override
  String get weekdayShortSun => 'dom';

  @override
  String get monthJanuary => 'enero';

  @override
  String get monthFebruary => 'febrero';

  @override
  String get monthMarch => 'marzo';

  @override
  String get monthApril => 'abril';

  @override
  String get monthMay => 'mayo';

  @override
  String get monthJune => 'junio';

  @override
  String get monthJuly => 'julio';

  @override
  String get monthAugust => 'agosto';

  @override
  String get monthSeptember => 'septiembre';

  @override
  String get monthOctober => 'octubre';

  @override
  String get monthNovember => 'noviembre';

  @override
  String get monthDecember => 'diciembre';

  @override
  String get monthShortJan => 'ene';

  @override
  String get monthShortFeb => 'feb';

  @override
  String get monthShortMar => 'mar';

  @override
  String get monthShortApr => 'abr';

  @override
  String get monthShortMay => 'may';

  @override
  String get monthShortJun => 'jun';

  @override
  String get monthShortJul => 'jul';

  @override
  String get monthShortAug => 'ago';

  @override
  String get monthShortSep => 'sep';

  @override
  String get monthShortOct => 'oct';

  @override
  String get monthShortNov => 'nov';

  @override
  String get monthShortDec => 'dic';

  @override
  String dateFullLabel(String weekday, int day, String month) {
    return '$weekday, $day de $month';
  }

  @override
  String get authorMarcusAurelius => 'Marco Aurelio';

  @override
  String get authorSeneca => 'Séneca';

  @override
  String get authorEpictetus => 'Epicteto';

  @override
  String get authorMusoniusRufus => 'Musonio Rufo';

  @override
  String get authorMixed => 'Mixto';

  @override
  String get contextWork => 'Disciplina';

  @override
  String get contextRelationships => 'Relaciones';

  @override
  String get contextAnxiety => 'Ansiedad';

  @override
  String get contextFocus => 'Enfoque';

  @override
  String get contextHardDecision => 'Decisión difícil';

  @override
  String get languagePt => 'Português';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get homeTitle => 'Hoy';

  @override
  String get offlineTitle => 'Estás sin conexión.';

  @override
  String get offlineDescription =>
      'Conéctate para sincronizar el contenido diario.';

  @override
  String get errorContentFailed =>
      'El contenido de hoy no cargó. Inténtalo de nuevo.';

  @override
  String get emptyNoContent => 'No hay contenido diario disponible.';

  @override
  String get emptySyncLater => 'Intenta sincronizar en un momento.';

  @override
  String get favoriteRemoved => 'Eliminado de favoritos.';

  @override
  String get favoriteAdded => 'Añadido a favoritos.';

  @override
  String get errorActionFailed =>
      'No se pudo completar la acción. Inténtalo de nuevo.';

  @override
  String get checkinAppliedSuccess => 'Práctica registrada con éxito.';

  @override
  String get checkinNotAppliedSuccess => 'Check-in completado.';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyProUpsellTitle => 'El historial completo es Pro';

  @override
  String get historyProUpsellDesc =>
      'Revisa todas tus prácticas. Observa los patrones.';

  @override
  String get historyProUpsellButton => 'Ver planes Pro';

  @override
  String get historyEmptyOnline =>
      'Tu historial comienza con la primera práctica.';

  @override
  String get historyEmptyFirstRecord =>
      'La práctica de hoy será tu primer registro.';

  @override
  String get historyEmptyOffline => 'Estás sin conexión.';

  @override
  String get historyEmptySync => 'Conéctate para sincronizar tu historial.';

  @override
  String historyLimitLabel(int count, int limit) {
    return '$count/$limit días';
  }

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesEmptyOnline =>
      'Las citas que resuenen contigo aparecerán aquí.';

  @override
  String get favoritesEmptyHint =>
      'Guarda la cita del día para revisitarla cuando lo necesites.';

  @override
  String get favoritesEmptyTodayCta => 'Ver la cita de hoy';

  @override
  String get favoritesSearchHint => 'Buscar cita o autor...';

  @override
  String favoritesSearchEmpty(String query) {
    return 'Sin resultados para \"$query\".';
  }

  @override
  String get favoritesProUpsellTitle => 'Los favoritos ilimitados son Pro';

  @override
  String get favoritesProUpsellDesc =>
      'Guarda cada cita para revisitarla cuando lo necesites.';

  @override
  String get favoritesProUpsellButton => 'Ver planes Pro';

  @override
  String get favoritesRemoveSuccess => 'Eliminado de favoritos.';

  @override
  String get favoritesRemoveError => 'No se pudo eliminar el favorito.';

  @override
  String get favoritesRemoveTooltip => 'Eliminar de favoritos';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubtitle => 'CONFIGURACIÓN Y PREFERENCIAS';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionSubscription => 'Suscripción';

  @override
  String get settingsSectionContent => 'Contenido';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguagePickerTitle => 'Idioma';

  @override
  String get settingsTimezone => 'Zona Horaria';

  @override
  String settingsTimezoneAuto(String label) {
    return '$label (detectado automáticamente)';
  }

  @override
  String get settingsPreferredAuthors => 'Autores Preferidos';

  @override
  String get settingsPreferredContext => 'Contexto Preferencial';

  @override
  String get settingsPreferredContextSubtitle => 'Personaliza tu práctica';

  @override
  String get settingsAuthorsAll => 'Todos (Modo Mixto)';

  @override
  String get settingsAuthorsNone => 'Ninguno';

  @override
  String get settingsAuthorsCustom => 'Personalizado';

  @override
  String get settingsVerifiedSources => 'Fuentes Verificadas';

  @override
  String get settingsAlways => 'Siempre';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutDialogTitle => '¿Cerrar sesión?';

  @override
  String get settingsLogoutDialogMessage =>
      'Tus check-ins y favoritos están guardados en la nube y se restaurarán al iniciar sesión nuevamente.';

  @override
  String get settingsManageSubscriptionSnackbar =>
      'Administra tu suscripción en la App Store/Play Store.';

  @override
  String get settingsOpenSystemSettingsHint =>
      'Abre la configuración del sistema para permitir notificaciones.';

  @override
  String get settingsResetOnboardingTitle => '¿Reiniciar onboarding?';

  @override
  String get settingsResetOnboardingMessage =>
      'Esto reabre el flujo inicial y borra las preferencias de onboarding.';

  @override
  String get settingsResetOnboardingButton => 'Reiniciar onboarding';

  @override
  String get settingsResetOnboardingSuccess =>
      'El onboarding se mostrará al reabrir la app.';

  @override
  String get settingsTzBrasilia => 'Brasília (GMT−3)';

  @override
  String get settingsTzRioBranco => 'Rio Branco (GMT−5)';

  @override
  String get splashTagline => 'Claridad para actuar.';

  @override
  String get splashLoadingMessage => 'Preparando tu insight de hoy...';

  @override
  String get onboardingContextQuestion => '¿Qué área quieres fortalecer ahora?';

  @override
  String get onboardingContextSubtitle => 'Esto personaliza el insight de hoy.';

  @override
  String get onboardingContextHelper => 'Elige una opción para continuar.';

  @override
  String get onboardingContextAnxietyLabel =>
      'Recuperar claridad cuando la mente acelera';

  @override
  String get onboardingContextFocusLabel => 'Separar lo esencial de lo urgente';

  @override
  String get onboardingContextWorkLabel =>
      'Actuar con intención en el entorno profesional';

  @override
  String get onboardingContextRelationshipsLabel =>
      'Reaccionar menos, entender más';

  @override
  String get onboardingContextHardDecisionLabel =>
      'Encontrar firmeza en la incertidumbre';

  @override
  String get onboardingContextSkip => 'Elegir después';

  @override
  String get onboardingVoiceTitle => 'Elige el autor que guía tu práctica';

  @override
  String get onboardingVoiceSubtitle =>
      'Puedes cambiarlo en cualquier momento en los ajustes.';

  @override
  String get onboardingVoiceSenecaSubtitle => 'directo al punto, sin rodeos';

  @override
  String get onboardingVoiceEpictetusSubtitle =>
      'enfoque en lo que puedes controlar';

  @override
  String get onboardingVoiceMarcusSubtitle => 'reflexión y autoconciencia';

  @override
  String get onboardingVoiceMixedSubtitle => 'variedad de perspectivas';

  @override
  String get onboardingVoiceSkip => 'Elegir después';

  @override
  String get onboardingTimeMorning => 'Mañana';

  @override
  String get onboardingTimeLunch => 'Almuerzo';

  @override
  String get onboardingTimeEvening => 'Noche';

  @override
  String get onboardingTimeCustom => 'Otro horario';

  @override
  String get onboardingReminderTitle => 'Mantén el ritmo.';

  @override
  String get onboardingReminderSubtitle =>
      'Un recordatorio diario a la hora que elijas — nada más.';

  @override
  String get onboardingReminderToggleLabel => 'Activar recordatorio diario';

  @override
  String onboardingReminderTimeSelected(String time) {
    return 'Seleccionado: $time';
  }

  @override
  String onboardingReminderTimezoneLabel(String timezone) {
    return 'Zona horaria: $timezone';
  }

  @override
  String get onboardingHowItWorksTitle => 'Cómo funciona';

  @override
  String get onboardingHowItWorksSubtitle => 'Simple. Directo. Cada día.';

  @override
  String get onboardingHowItWorksBullet1 =>
      'Una cita verificada de Séneca, Epicteto o Marco Aurelio — no frases de internet.';

  @override
  String get onboardingHowItWorksBullet2 =>
      'Una acción práctica para aplicar hoy, en el contexto que elijas.';

  @override
  String get onboardingHowItWorksBullet3 =>
      'Sin cuestionarios infinitos. Sin gamificación. Solo práctica real, cada día.';

  @override
  String get onboardingHowItWorksQuote =>
      '\"La filosofía no está en las palabras, sino en los actos.\"\n— Séneca';

  @override
  String get onboardingDoneTitle => 'Listo. Tu primer día está preparado.';

  @override
  String get onboardingDoneSubtitle => 'Sin prisa. Un paso a la vez.';

  @override
  String get onboardingDonePersonalizeHint =>
      'Puedes personalizar tu experiencia en cualquier momento en los ajustes.';

  @override
  String get onboardingDoneButton => 'Ver mi primer insight';

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
    return 'Horario: $time';
  }

  @override
  String get onboardingDoneReminderChip => 'Recordatorio: activo';

  @override
  String get onboardingIntroTitle => 'Menos reacción.\nMás intención.';

  @override
  String get onboardingIntroSubtitle => '1 cita verificada. 1 acción para hoy.';

  @override
  String get onboardingIntroTodayLabel => 'Hoy, para empezar';

  @override
  String get onboardingIntroActionLabel => 'Acción de hoy';

  @override
  String get onboardingIntroHowItWorks => 'Ver cómo funciona';

  @override
  String get onboardingIntroCta => 'Personalizar mi práctica';

  @override
  String get onboardingIntroExampleQuote =>
      '\"No son los acontecimientos los que nos perturban, sino la interpretación que hacemos de ellos.\"';

  @override
  String get onboardingIntroExampleAuthor => 'Epicteto';

  @override
  String get onboardingIntroExampleAction =>
      'Reescribe un hecho reciente sin usar adjetivos — una práctica de 2 minutos.';

  @override
  String get onboardingSkipButton => 'Omitir';

  @override
  String get onboardingBackTooltip => 'Volver';

  @override
  String onboardingProgressLabel(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get onboardingBrandTitle => 'AETHOR';

  @override
  String get paywallMainTitle => 'Practica con profundidad. Sin límites.';

  @override
  String get paywallMainDescription =>
      'Ritual diario completo. Historial, favoritos y pistas sin restricción.';

  @override
  String get paywallBullet1 => 'Historial completo e ilimitado.';

  @override
  String get paywallBullet2 => 'Favoritos sin límite y revisita rápida.';

  @override
  String get paywallBullet3 => 'Pistas guiadas de profundización.';

  @override
  String get paywallPlanAnnualTitle => 'Plan Anual';

  @override
  String get paywallPlanAnnualSubtitle => '7 días gratis';

  @override
  String get paywallPlanAnnualHighlight => 'Mejor valor';

  @override
  String get paywallPlanMonthlyTitle => 'Plan Mensual';

  @override
  String get paywallPlanMonthlySubtitle => 'Pago mensual';

  @override
  String get paywallButtonAnnual => 'Iniciar 7 días gratis';

  @override
  String get paywallButtonMonthly => 'Suscribirse ahora';

  @override
  String get paywallContinueFree => 'Continuar de forma gratuita';

  @override
  String get paywallRestorePurchase => 'Restaurar compra';

  @override
  String get paywallCancelNotice => 'Cancela cuando quieras. Sin compromiso.';

  @override
  String get paywallComparisonHeaderFeatures => 'Recursos';

  @override
  String get paywallComparisonHeaderFree => 'Gratuito';

  @override
  String get paywallComparisonHeaderPro => 'Pro';

  @override
  String get paywallComparisonFeature1 => 'Cita + práctica diaria';

  @override
  String get paywallComparisonFeature2 => 'Historial completo';

  @override
  String get paywallComparisonFeature3 => 'Favoritos ilimitados';

  @override
  String get paywallComparisonFeature4 => 'Audios prácticos';

  @override
  String get paywallComparisonFeature5 => 'Pistas guiadas';

  @override
  String get paywallComparisonFeature6 => 'Personalización avanzada';

  @override
  String get paywallComparisonFeature7 => 'Soporte prioritario';

  @override
  String get subscriptionProTitle => 'Aethor Pro';

  @override
  String get subscriptionProDescription =>
      'Historial completo, favoritos ilimitados y pistas guiadas.';

  @override
  String get subscriptionViewPlansBtn => 'Ver planes Pro';

  @override
  String get subscriptionRestoreBtn => 'Restaurar compra';

  @override
  String get subscriptionBadgeTrialActive => 'Prueba activa';

  @override
  String get subscriptionBadgeSubscriptionActive => 'Suscripción activa';

  @override
  String get subscriptionPlanAnnual => 'Plan anual';

  @override
  String get subscriptionPlanMonthly => 'Plan mensual';

  @override
  String get subscriptionTrialRenewal => 'Se renueva el';

  @override
  String get subscriptionNextBilling => 'Próximo cobro:';

  @override
  String get subscriptionManageBtn => 'Administrar suscripción';

  @override
  String get subscriptionRestoreTextBtn => 'Restaurar';

  @override
  String get subscriptionSuccessTrialTitle => 'Prueba iniciada con éxito';

  @override
  String get subscriptionSuccessProTitle => 'Pro activado con éxito';

  @override
  String get subscriptionSuccessTrialMessage =>
      '7 días para practicar con todas las funciones.';

  @override
  String get subscriptionSuccessProMessage =>
      'Tu suscripción está activa. Disfruta las funciones Pro.';

  @override
  String get subscriptionSuccessFeature1 => 'Historial completo';

  @override
  String get subscriptionSuccessFeature2 => 'Favoritos ilimitados';

  @override
  String get subscriptionSuccessFeature3 => 'Pistas guiadas';

  @override
  String get subscriptionSuccessFeature4 => 'Audios prácticos';

  @override
  String get subscriptionSuccessContinue => 'Continuar';

  @override
  String get subscriptionSuccessBack => 'Volver al inicio';

  @override
  String get restorePurchaseTitle => 'Restaurar compra';

  @override
  String get restorePurchaseLoading => 'Restaurando compra...';

  @override
  String get restorePurchaseSuccessTitle => 'Compra restaurada';

  @override
  String get restorePurchaseSuccessMessage =>
      'Tu acceso Pro está activo nuevamente.';

  @override
  String get restorePurchaseContinueBtn => 'Continuar';

  @override
  String get restorePurchaseErrorTitle => 'No se pudo restaurar';

  @override
  String get restorePurchaseErrorMessage =>
      'Inténtalo de nuevo o contacta soporte.';

  @override
  String get restorePurchaseRetryBtn => 'Intentar de nuevo';

  @override
  String get restorePurchaseSupportBtn => 'Contactar soporte';

  @override
  String get processingPurchaseMessage => 'Confirmando tu suscripción...';

  @override
  String get premiumFullhistoryTitle =>
      'El historial completo es una función Pro';

  @override
  String get premiumFullhistoryDescription =>
      'Revisa cada práctica registrada, sin límite de tiempo.';

  @override
  String get premiumFavoriteslimitTitle => 'Los favoritos ilimitados son Pro';

  @override
  String get premiumFavoriteslimitDescription =>
      'Guarda todas las citas que quieras para revisitar después.';

  @override
  String get premiumAudioTitle => 'Los audios guiados son Pro';

  @override
  String get premiumAudioDescription =>
      'Escucha prácticas guiadas con enfoque y claridad.';

  @override
  String get premiumTrailTitle => 'Las pistas guiadas son Pro';

  @override
  String get premiumTrailDescription =>
      'Sigue pistas estructuradas para profundizar tu práctica.';

  @override
  String get premiumViewPlans => 'Ver planes';

  @override
  String get premiumContinueFree => 'Continuar de forma gratuita';

  @override
  String get premiumRestorePurchase => 'Restaurar compra';

  @override
  String get checkinTitle => 'Check-in Diario';

  @override
  String get checkinAppliedBtn => 'Lo apliqué hoy';

  @override
  String get checkinNotAppliedBtn => 'No lo apliqué';

  @override
  String get checkinSaving => 'Guardando...';

  @override
  String get checkinRegisteredTitle => 'Check-in registrado';

  @override
  String get checkinAppliedMessage => 'Aplicaste la práctica de hoy.';

  @override
  String get checkinNotAppliedMessage =>
      'Registrado. Mañana hay nueva práctica.';

  @override
  String get checkinReflectionLabel => 'TU REFLEXIÓN';

  @override
  String get checkinFooterMessage => 'Vuelve mañana para una nueva práctica.';

  @override
  String get quoteCardLabel => 'CITA DEL DÍA';

  @override
  String get quoteCardFavoriteSave => 'Guardar en favoritos';

  @override
  String get quoteCardFavoriteRemove => 'Eliminar de favoritos';

  @override
  String get quoteCardIntentionLabel => 'INTENCIÓN:';

  @override
  String get practiceCardContextLabel => 'Situación';

  @override
  String get practiceCardTimeLabel => 'Tiempo estimado';

  @override
  String get practiceCardHowApply => 'Cómo aplicar hoy';

  @override
  String get practiceCardExpectedImpactLabel => 'Impacto esperado:';

  @override
  String get practiceCardCompletionSignalLabel => 'Señal de finalización:';

  @override
  String get practiceCardReflectionLabel => 'Reflexión del día:';

  @override
  String get dayDetailPracticeLabel => 'Práctica del día';

  @override
  String get dayDetailQuoteLabel => 'CITA';

  @override
  String get dayDetailPracticeAppliedLabel => 'PRÁCTICA APLICADA';

  @override
  String get dayDetailReflectionLabel => 'TU REFLEXIÓN';

  @override
  String get dayDetailStatusCompleted => 'Práctica completada';

  @override
  String get dayDetailStatusNotApplied => 'No aplicada';

  @override
  String get historyStatusCompleted => 'Hecho';

  @override
  String get historyStatusSkipped => 'Omitido';

  @override
  String get notificationPromptIosTitle =>
      '\"Aethor\" quiere enviarte notificaciones';

  @override
  String get notificationPromptIosDescription =>
      'Las notificaciones pueden incluir alertas, sonidos e insignias. Se puede configurar en Ajustes.';

  @override
  String get notificationPromptIosDeny => 'No Permitir';

  @override
  String get notificationPromptIosAllow => 'Permitir';

  @override
  String get notificationPromptAndroidTitle =>
      '¿Permitir que Aethor envíe notificaciones?';

  @override
  String get notificationPromptAndroidDescription =>
      'Las notificaciones pueden incluir alertas, sonidos e insignias.';

  @override
  String get notificationPromptAndroidDeny => 'NO PERMITIR';

  @override
  String get notificationPromptAndroidAllow => 'PERMITIR';

  @override
  String get notificationNudgeTitle =>
      'Un recordatorio diario para tu práctica.';

  @override
  String get notificationNudgeDescription =>
      'Elige la hora. El recordatorio será breve.';

  @override
  String get notificationNudgeEnable => 'Activar recordatorios';

  @override
  String get notificationNudgeLater => 'Ahora no';

  @override
  String get notificationResultGrantedTitle => 'Recordatorio diario activado';

  @override
  String get notificationResultGrantedMessage =>
      'Recibirás un recordatorio todos los días.';

  @override
  String get notificationResultAdjustTime => 'Ajustar horario';

  @override
  String get notificationResultDeniedTitle => 'Sin problema';

  @override
  String get notificationResultDeniedMessage =>
      'Puedes activar recordatorios después en Ajustes.';

  @override
  String get notificationResultGoToSettings => 'Ir a Ajustes';

  @override
  String get notificationSettingDailyReminder => 'Recordatorio Diario';

  @override
  String get notificationSettingDailySchedule => 'Todos los días a las';

  @override
  String get notificationSettingPermissionDenied => 'Permiso denegado';

  @override
  String get notificationSettingEnableSystem =>
      'Activa las notificaciones en la configuración del sistema para recibir recordatorios.';

  @override
  String get notificationSettingOpenSettings => 'Abrir Configuración';

  @override
  String get notificationSettingTimeLabel => 'HORARIO DEL RECORDATORIO';

  @override
  String get notificationSettingTimezoneLabel => 'ZONA HORARIA';

  @override
  String get notificationSettingReminderInfo =>
      'Recibirás un recordatorio todos los días a la hora elegida.';

  @override
  String get loadingStateDefaultMessage => 'Preparando tu práctica...';

  @override
  String get loadingStateDefaultSubtitle =>
      'El contenido de hoy está en camino.';

  @override
  String get errorStateDefaultTitle => 'Fallo de conexión.';

  @override
  String get errorStateDefaultMessage =>
      'Verifica tu red e inténtalo de nuevo.';

  @override
  String get errorStateRetryButton => 'Intentar de nuevo';

  @override
  String get offlineBannerTitle => 'Modo sin conexión';

  @override
  String get offlineBannerSubtitle => 'Mostrando contenido en caché';

  @override
  String get offlineBannerSync => 'SINCRONIZAR';
}
