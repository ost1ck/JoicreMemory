import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('uk'),
  ];

  /// No description provided for @reports.
  ///
  /// In uk, this message translates to:
  /// **'Звіти'**
  String get reports;

  /// No description provided for @couldNotGenerateTheReport.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося сформувати звіт.'**
  String get couldNotGenerateTheReport;

  /// No description provided for @createdEvents.
  ///
  /// In uk, this message translates to:
  /// **'Створені події'**
  String get createdEvents;

  /// No description provided for @youHavenTCreatedAnyEventsYet.
  ///
  /// In uk, this message translates to:
  /// **'Ти ще не створював подій.'**
  String get youHavenTCreatedAnyEventsYet;

  /// No description provided for @myParticipation.
  ///
  /// In uk, this message translates to:
  /// **'Моя участь'**
  String get myParticipation;

  /// No description provided for @youHavenTJoinedAnyEventsYet.
  ///
  /// In uk, this message translates to:
  /// **'Ти ще не долучався до подій.'**
  String get youHavenTJoinedAnyEventsYet;

  /// No description provided for @personalReport.
  ///
  /// In uk, this message translates to:
  /// **'Персональний звіт'**
  String get personalReport;

  /// No description provided for @updated.
  ///
  /// In uk, this message translates to:
  /// **'Оновлено {arg0}'**
  String updated(String arg0);

  /// No description provided for @preparingPdf.
  ///
  /// In uk, this message translates to:
  /// **'Підготовка PDF...'**
  String get preparingPdf;

  /// No description provided for @generateAndPrintPdf.
  ///
  /// In uk, this message translates to:
  /// **'Сформувати і друкувати PDF'**
  String get generateAndPrintPdf;

  /// No description provided for @created.
  ///
  /// In uk, this message translates to:
  /// **'Створено'**
  String get created;

  /// No description provided for @joined.
  ///
  /// In uk, this message translates to:
  /// **'Участь'**
  String get joined;

  /// No description provided for @participants.
  ///
  /// In uk, this message translates to:
  /// **'Учасників'**
  String get participants;

  /// No description provided for @fillRate.
  ///
  /// In uk, this message translates to:
  /// **'Заповненість'**
  String get fillRate;

  /// No description provided for @plannedHrs.
  ///
  /// In uk, this message translates to:
  /// **'Планові год.'**
  String get plannedHrs;

  /// No description provided for @upcoming.
  ///
  /// In uk, this message translates to:
  /// **'Майбутні'**
  String get upcoming;

  /// No description provided for @myContribution.
  ///
  /// In uk, this message translates to:
  /// **'Мій внесок'**
  String get myContribution;

  /// No description provided for @eventsByCategory.
  ///
  /// In uk, this message translates to:
  /// **'Події за категоріями'**
  String get eventsByCategory;

  /// No description provided for @noChartDataYet.
  ///
  /// In uk, this message translates to:
  /// **'Ще немає даних для діаграми.'**
  String get noChartDataYet;

  /// No description provided for @activity.
  ///
  /// In uk, this message translates to:
  /// **'Активність'**
  String get activity;

  /// No description provided for @created20.
  ///
  /// In uk, this message translates to:
  /// **'Створ.'**
  String get created20;

  /// No description provided for @upcoming21.
  ///
  /// In uk, this message translates to:
  /// **'Майб.'**
  String get upcoming21;

  /// No description provided for @ended.
  ///
  /// In uk, this message translates to:
  /// **'Зав.'**
  String get ended;

  /// No description provided for @thePdfWillIncludeMoreEvents.
  ///
  /// In uk, this message translates to:
  /// **'У PDF буде ще {arg0} подій.'**
  String thePdfWillIncludeMoreEvents(String arg0);

  /// No description provided for @hrs.
  ///
  /// In uk, this message translates to:
  /// **'{arg0} год'**
  String hrs(String arg0);

  /// No description provided for @noEndTime.
  ///
  /// In uk, this message translates to:
  /// **'без кінця'**
  String get noEndTime;

  /// No description provided for @tryAgain.
  ///
  /// In uk, this message translates to:
  /// **'Спробувати ще раз'**
  String get tryAgain;

  /// No description provided for @eventsTheUserHasJoined.
  ///
  /// In uk, this message translates to:
  /// **'Події, де користувач є учасником'**
  String get eventsTheUserHasJoined;

  /// No description provided for @joicrememoryReport.
  ///
  /// In uk, this message translates to:
  /// **'Звіт JoicreMemory'**
  String get joicrememoryReport;

  /// No description provided for @user.
  ///
  /// In uk, this message translates to:
  /// **'Користувач: {arg0}'**
  String user(String arg0);

  /// No description provided for @email.
  ///
  /// In uk, this message translates to:
  /// **'Пошта: {arg0}'**
  String email(String arg0);

  /// No description provided for @generated.
  ///
  /// In uk, this message translates to:
  /// **'Сформовано: {arg0}'**
  String generated(String arg0);

  /// No description provided for @summary.
  ///
  /// In uk, this message translates to:
  /// **'Коротка аналітика'**
  String get summary;

  /// No description provided for @metric.
  ///
  /// In uk, this message translates to:
  /// **'Показник'**
  String get metric;

  /// No description provided for @value.
  ///
  /// In uk, this message translates to:
  /// **'Значення'**
  String get value;

  /// No description provided for @eventsCreated.
  ///
  /// In uk, this message translates to:
  /// **'Створено подій'**
  String get eventsCreated;

  /// No description provided for @eventsJoined.
  ///
  /// In uk, this message translates to:
  /// **'Участь у подіях'**
  String get eventsJoined;

  /// No description provided for @participantsInMyEvents.
  ///
  /// In uk, this message translates to:
  /// **'Учасників у моїх подіях'**
  String get participantsInMyEvents;

  /// No description provided for @averageFillRate.
  ///
  /// In uk, this message translates to:
  /// **'Середня заповненість'**
  String get averageFillRate;

  /// No description provided for @plannedHoursEventsWithAnEndTime.
  ///
  /// In uk, this message translates to:
  /// **'Планові години (де вказано завершення)'**
  String get plannedHoursEventsWithAnEndTime;

  /// No description provided for @upcomingEvents.
  ///
  /// In uk, this message translates to:
  /// **'Майбутні події'**
  String get upcomingEvents;

  /// No description provided for @completedEvents.
  ///
  /// In uk, this message translates to:
  /// **'Завершені події'**
  String get completedEvents;

  /// No description provided for @categories.
  ///
  /// In uk, this message translates to:
  /// **'Категорії'**
  String get categories;

  /// No description provided for @noCategoryDataYet.
  ///
  /// In uk, this message translates to:
  /// **'Даних за категоріями ще немає.'**
  String get noCategoryDataYet;

  /// No description provided for @category.
  ///
  /// In uk, this message translates to:
  /// **'Категорія'**
  String get category;

  /// No description provided for @participants45.
  ///
  /// In uk, this message translates to:
  /// **'Учасники'**
  String get participants45;

  /// No description provided for @noEventsInThisSection.
  ///
  /// In uk, this message translates to:
  /// **'Немає подій для цього розділу.'**
  String get noEventsInThisSection;

  /// No description provided for @title.
  ///
  /// In uk, this message translates to:
  /// **'Назва'**
  String get title;

  /// No description provided for @date.
  ///
  /// In uk, this message translates to:
  /// **'Дата'**
  String get date;

  /// No description provided for @place.
  ///
  /// In uk, this message translates to:
  /// **'Місце'**
  String get place;

  /// No description provided for @participants50.
  ///
  /// In uk, this message translates to:
  /// **'Учасники: {arg0}'**
  String participants50(String arg0);

  /// No description provided for @noParticipantsYet.
  ///
  /// In uk, this message translates to:
  /// **'Учасників ще немає.'**
  String get noParticipantsYet;

  /// No description provided for @name.
  ///
  /// In uk, this message translates to:
  /// **'Імʼя'**
  String get name;

  /// No description provided for @email53.
  ///
  /// In uk, this message translates to:
  /// **'Пошта'**
  String get email53;

  /// No description provided for @role.
  ///
  /// In uk, this message translates to:
  /// **'Роль'**
  String get role;

  /// No description provided for @dateJoined.
  ///
  /// In uk, this message translates to:
  /// **'Дата долучення'**
  String get dateJoined;

  /// No description provided for @organizer.
  ///
  /// In uk, this message translates to:
  /// **'Організатор'**
  String get organizer;

  /// No description provided for @participant.
  ///
  /// In uk, this message translates to:
  /// **'Учасник'**
  String get participant;

  /// No description provided for @noEndTime58.
  ///
  /// In uk, this message translates to:
  /// **'{arg0} (без завершення)'**
  String noEndTime58(String arg0);

  /// No description provided for @addressFoundCheckItAndClarifyTheMeetingPointIf.
  ///
  /// In uk, this message translates to:
  /// **'Адресу визначено. Перевір її та за потреби уточни місце зустрічі.'**
  String get addressFoundCheckItAndClarifyTheMeetingPointIf;

  /// No description provided for @pinSavedNoAddressFoundYouCanAddALandmark.
  ///
  /// In uk, this message translates to:
  /// **'Точку збережено. Адресу не знайдено — можеш додати орієнтир вручну.'**
  String get pinSavedNoAddressFoundYouCanAddALandmark;

  /// No description provided for @pinSavedCouldNotFindTheAddressYouCanEnter.
  ///
  /// In uk, this message translates to:
  /// **'Точку збережено. Не вдалося визначити адресу — її можна уточнити вручну.'**
  String get pinSavedCouldNotFindTheAddressYouCanEnter;

  /// No description provided for @mapPin.
  ///
  /// In uk, this message translates to:
  /// **'Точка на мапі'**
  String get mapPin;

  /// No description provided for @draftSavedToYourProfile.
  ///
  /// In uk, this message translates to:
  /// **'Чернетку збережено у профілі'**
  String get draftSavedToYourProfile;

  /// No description provided for @eventPublished.
  ///
  /// In uk, this message translates to:
  /// **'Подію опубліковано'**
  String get eventPublished;

  /// No description provided for @changesSaved.
  ///
  /// In uk, this message translates to:
  /// **'Зміни збережено'**
  String get changesSaved;

  /// No description provided for @couldNotSaveTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося створити подію: {arg0}'**
  String couldNotSaveTheEvent(String arg0);

  /// No description provided for @newEvent.
  ///
  /// In uk, this message translates to:
  /// **'Нова подія'**
  String get newEvent;

  /// No description provided for @editEvent.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати подію'**
  String get editEvent;

  /// No description provided for @draft.
  ///
  /// In uk, this message translates to:
  /// **'Чернетка'**
  String get draft;

  /// No description provided for @saving.
  ///
  /// In uk, this message translates to:
  /// **'Зберігаємо…'**
  String get saving;

  /// No description provided for @publishEvent.
  ///
  /// In uk, this message translates to:
  /// **'Опублікувати подію'**
  String get publishEvent;

  /// No description provided for @saveDraft.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти чернетку'**
  String get saveDraft;

  /// No description provided for @saveChanges.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти зміни'**
  String get saveChanges;

  /// No description provided for @aGoodCauseStartsWithYou.
  ///
  /// In uk, this message translates to:
  /// **'Хороша справа починається з тебе.'**
  String get aGoodCauseStartsWithYou;

  /// No description provided for @shareYourIdeaChooseAPlaceAndInvitePeopleTo.
  ///
  /// In uk, this message translates to:
  /// **'Розкажи про ідею, обери місце та запроси людей долучитися.'**
  String get shareYourIdeaChooseAPlaceAndInvitePeopleTo;

  /// No description provided for @onlyYouCanSeeThisDraftInYourProfileIt.
  ///
  /// In uk, this message translates to:
  /// **'Чернетка видима лише тобі у профілі. Вона не з’явиться на мапі чи у стрічці, а чат буде створено після публікації. Заповни основні поля, щоб зберегти її.'**
  String get onlyYouCanSeeThisDraftInYourProfileIt;

  /// No description provided for @aboutTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Про подію'**
  String get aboutTheEvent;

  /// No description provided for @whatWillYouDoTogetherAndWhoIsItFor.
  ///
  /// In uk, this message translates to:
  /// **'Що ви робитимете разом і кому буде цікаво?'**
  String get whatWillYouDoTogetherAndWhoIsItFor;

  /// No description provided for @eventTitle.
  ///
  /// In uk, this message translates to:
  /// **'Назва події'**
  String get eventTitle;

  /// No description provided for @characters.
  ///
  /// In uk, this message translates to:
  /// **'Від 3 до 140 символів'**
  String get characters;

  /// No description provided for @forExampleAParkCleanup.
  ///
  /// In uk, this message translates to:
  /// **'Наприклад, толока у парку'**
  String get forExampleAParkCleanup;

  /// No description provided for @atLeastCharacters.
  ///
  /// In uk, this message translates to:
  /// **'Мінімум 3 символи'**
  String get atLeastCharacters;

  /// No description provided for @whatToKnow.
  ///
  /// In uk, this message translates to:
  /// **'Що варто знати'**
  String get whatToKnow;

  /// No description provided for @characters84.
  ///
  /// In uk, this message translates to:
  /// **'Від 10 до 5000 символів'**
  String get characters84;

  /// No description provided for @thePlanWhatToBringAndWhoCanJoin.
  ///
  /// In uk, this message translates to:
  /// **'План, що взяти із собою, кому підходить подія'**
  String get thePlanWhatToBringAndWhoCanJoin;

  /// No description provided for @atLeastCharacters86.
  ///
  /// In uk, this message translates to:
  /// **'Мінімум 10 символів'**
  String get atLeastCharacters86;

  /// No description provided for @whereWeLlMeet.
  ///
  /// In uk, this message translates to:
  /// **'Де зустрічаємось'**
  String get whereWeLlMeet;

  /// No description provided for @dropAPinWeLlTryToFindTheAddress.
  ///
  /// In uk, this message translates to:
  /// **'Постав точку — адресу спробуємо визначити автоматично.'**
  String get dropAPinWeLlTryToFindTheAddress;

  /// No description provided for @chooseAPlaceOnTheMap.
  ///
  /// In uk, this message translates to:
  /// **'Обери місце на мапі'**
  String get chooseAPlaceOnTheMap;

  /// No description provided for @chooseAPlaceOnTheMap90.
  ///
  /// In uk, this message translates to:
  /// **'Обрати місце на мапі'**
  String get chooseAPlaceOnTheMap90;

  /// No description provided for @moveTheMapPin.
  ///
  /// In uk, this message translates to:
  /// **'Змінити точку на мапі'**
  String get moveTheMapPin;

  /// No description provided for @atLeastCharacters92.
  ///
  /// In uk, this message translates to:
  /// **'Мінімум 2 символи'**
  String get atLeastCharacters92;

  /// No description provided for @placeNameOrLandmark.
  ///
  /// In uk, this message translates to:
  /// **'Назва місця або орієнтир'**
  String get placeNameOrLandmark;

  /// No description provided for @forExampleByTheMainEntrance.
  ///
  /// In uk, this message translates to:
  /// **'Наприклад, біля головного входу'**
  String get forExampleByTheMainEntrance;

  /// No description provided for @optionalTheMapPinDefinesTheLocation.
  ///
  /// In uk, this message translates to:
  /// **'Необов’язково: місце визначає точка на мапі'**
  String get optionalTheMapPinDefinesTheLocation;

  /// No description provided for @address.
  ///
  /// In uk, this message translates to:
  /// **'Адреса'**
  String get address;

  /// No description provided for @filledInAfterYouChooseAPin.
  ///
  /// In uk, this message translates to:
  /// **'Заповниться після вибору точки'**
  String get filledInAfterYouChooseAPin;

  /// No description provided for @youCanEditThisOrLeaveItBlank.
  ///
  /// In uk, this message translates to:
  /// **'Можна виправити або залишити порожньою'**
  String get youCanEditThisOrLeaveItBlank;

  /// No description provided for @timeAndParticipants.
  ///
  /// In uk, this message translates to:
  /// **'Час та учасники'**
  String get timeAndParticipants;

  /// No description provided for @helpPeoplePlanTheirVisit.
  ///
  /// In uk, this message translates to:
  /// **'Допоможи людям спланувати участь.'**
  String get helpPeoplePlanTheirVisit;

  /// No description provided for @start.
  ///
  /// In uk, this message translates to:
  /// **'Початок'**
  String get start;

  /// No description provided for @theEndMustBeAfterTheEventStarts.
  ///
  /// In uk, this message translates to:
  /// **'Завершення має бути пізніше за початок події.'**
  String get theEndMustBeAfterTheEventStarts;

  /// No description provided for @end.
  ///
  /// In uk, this message translates to:
  /// **'Завершення'**
  String get end;

  /// No description provided for @notSpecified.
  ///
  /// In uk, this message translates to:
  /// **'Не вказано'**
  String get notSpecified;

  /// No description provided for @withoutAnEndTimeTheChatCannotBeDeletedAutomatically.
  ///
  /// In uk, this message translates to:
  /// **'Без часу завершення чат не можна видалити автоматично за розкладом.'**
  String get withoutAnEndTimeTheChatCannotBeDeletedAutomatically;

  /// No description provided for @theEventChatWillBeDeletedAfterTheEventEnds.
  ///
  /// In uk, this message translates to:
  /// **'Після завершення події її чат буде видалено.'**
  String get theEventChatWillBeDeletedAfterTheEventEnds;

  /// No description provided for @leaveTheEndTimeOpen.
  ///
  /// In uk, this message translates to:
  /// **'Не вказувати завершення'**
  String get leaveTheEndTimeOpen;

  /// No description provided for @participantLimit.
  ///
  /// In uk, this message translates to:
  /// **'Ліміт учасників'**
  String get participantLimit;

  /// No description provided for @forExample.
  ///
  /// In uk, this message translates to:
  /// **'Наприклад, 30'**
  String get forExample;

  /// No description provided for @leaveBlankForUnlimitedParticipation.
  ///
  /// In uk, this message translates to:
  /// **'Залиш порожнім, якщо обмежень немає'**
  String get leaveBlankForUnlimitedParticipation;

  /// No description provided for @enterAWholeNumberFromTo.
  ///
  /// In uk, this message translates to:
  /// **'Вкажи ціле число від 1 до 10000'**
  String get enterAWholeNumberFromTo;

  /// No description provided for @mapLocationSelected.
  ///
  /// In uk, this message translates to:
  /// **'Місце на мапі обрано'**
  String get mapLocationSelected;

  /// No description provided for @volunteering.
  ///
  /// In uk, this message translates to:
  /// **'Волонтерство'**
  String get volunteering;

  /// No description provided for @charity.
  ///
  /// In uk, this message translates to:
  /// **'Благодійність'**
  String get charity;

  /// No description provided for @cleanup.
  ///
  /// In uk, this message translates to:
  /// **'Прибирання'**
  String get cleanup;

  /// No description provided for @education.
  ///
  /// In uk, this message translates to:
  /// **'Освіта'**
  String get education;

  /// No description provided for @community.
  ///
  /// In uk, this message translates to:
  /// **'Громада'**
  String get community;

  /// No description provided for @urgent.
  ///
  /// In uk, this message translates to:
  /// **'Терміново'**
  String get urgent;

  /// No description provided for @other.
  ///
  /// In uk, this message translates to:
  /// **'Інше'**
  String get other;

  /// No description provided for @youVeJoinedTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Ти долучився до події!'**
  String get youVeJoinedTheEvent;

  /// No description provided for @leaveTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Вийти з події?'**
  String get leaveTheEvent;

  /// No description provided for @youWillBeRemovedFromTheParticipantList.
  ///
  /// In uk, this message translates to:
  /// **'Ти більше не будеш у списку учасників.'**
  String get youWillBeRemovedFromTheParticipantList;

  /// No description provided for @leave.
  ///
  /// In uk, this message translates to:
  /// **'Вийти'**
  String get leave;

  /// No description provided for @youVeLeftTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Ти вийшов із події.'**
  String get youVeLeftTheEvent;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @deleteTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Видалити подію?'**
  String get deleteTheEvent;

  /// No description provided for @theEventAndItsChatWillBeDeletedThisCannot.
  ///
  /// In uk, this message translates to:
  /// **'Подію та її чат буде видалено. Цю дію не можна скасувати.'**
  String get theEventAndItsChatWillBeDeletedThisCannot;

  /// No description provided for @delete.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get delete;

  /// No description provided for @yourEvent.
  ///
  /// In uk, this message translates to:
  /// **'Твоя подія'**
  String get yourEvent;

  /// No description provided for @publish.
  ///
  /// In uk, this message translates to:
  /// **'Опублікувати'**
  String get publish;

  /// No description provided for @completeEvent.
  ///
  /// In uk, this message translates to:
  /// **'Завершити подію'**
  String get completeEvent;

  /// No description provided for @cancelEvent.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати подію'**
  String get cancelEvent;

  /// No description provided for @viewParticipants.
  ///
  /// In uk, this message translates to:
  /// **'Переглянути учасників'**
  String get viewParticipants;

  /// No description provided for @deleteEvent.
  ///
  /// In uk, this message translates to:
  /// **'Видалити подію'**
  String get deleteEvent;

  /// No description provided for @publishTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Опублікувати подію?'**
  String get publishTheEvent;

  /// No description provided for @completeTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Завершити подію?'**
  String get completeTheEvent;

  /// No description provided for @cancelTheEvent.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати подію?'**
  String get cancelTheEvent;

  /// No description provided for @theEventWillBecomeVisibleToOtherUsers.
  ///
  /// In uk, this message translates to:
  /// **'Подія стане видимою іншим користувачам.'**
  String get theEventWillBecomeVisibleToOtherUsers;

  /// No description provided for @newParticipantsWillNoLongerBeAbleToJoinThe.
  ///
  /// In uk, this message translates to:
  /// **'Нові учасники не зможуть долучитися. Чат та його історію буде видалено. Повернути попередній статус неможливо.'**
  String get newParticipantsWillNoLongerBeAbleToJoinThe;

  /// No description provided for @confirm.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердити'**
  String get confirm;

  /// No description provided for @eventStatusUpdated.
  ///
  /// In uk, this message translates to:
  /// **'Статус події оновлено'**
  String get eventStatusUpdated;

  /// No description provided for @eventParticipants.
  ///
  /// In uk, this message translates to:
  /// **'Учасники події'**
  String get eventParticipants;

  /// No description provided for @couldNotLoadParticipants.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося завантажити учасників.'**
  String get couldNotLoadParticipants;

  /// No description provided for @retry.
  ///
  /// In uk, this message translates to:
  /// **'Повторити'**
  String get retry;

  /// No description provided for @noParticipantsYet145.
  ///
  /// In uk, this message translates to:
  /// **'Учасників поки немає.'**
  String get noParticipantsYet145;

  /// No description provided for @comingSoon.
  ///
  /// In uk, this message translates to:
  /// **'Незабаром'**
  String get comingSoon;

  /// No description provided for @happeningNow.
  ///
  /// In uk, this message translates to:
  /// **'Триває зараз'**
  String get happeningNow;

  /// No description provided for @today.
  ///
  /// In uk, this message translates to:
  /// **'Сьогодні'**
  String get today;

  /// No description provided for @cancelled.
  ///
  /// In uk, this message translates to:
  /// **'Скасовано'**
  String get cancelled;

  /// No description provided for @completed.
  ///
  /// In uk, this message translates to:
  /// **'Завершено'**
  String get completed;

  /// No description provided for @eventDetails.
  ///
  /// In uk, this message translates to:
  /// **'Деталі події'**
  String get eventDetails;

  /// No description provided for @youReTheOrganizer.
  ///
  /// In uk, this message translates to:
  /// **'Ти організатор'**
  String get youReTheOrganizer;

  /// No description provided for @youReAttending.
  ///
  /// In uk, this message translates to:
  /// **'Ти береш участь'**
  String get youReAttending;

  /// No description provided for @couldNotRefreshTheEventDetails.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося оновити дані події.'**
  String get couldNotRefreshTheEventDetails;

  /// No description provided for @when.
  ///
  /// In uk, this message translates to:
  /// **'КОЛИ'**
  String get when;

  /// No description provided for @noEndTimeSpecified.
  ///
  /// In uk, this message translates to:
  /// **'Час завершення не вказано'**
  String get noEndTimeSpecified;

  /// No description provided for @until.
  ///
  /// In uk, this message translates to:
  /// **'До {arg0}'**
  String until(String arg0);

  /// No description provided for @where.
  ///
  /// In uk, this message translates to:
  /// **'ДЕ'**
  String get where;

  /// No description provided for @theMeetingPointIsMarkedOnTheEventMap.
  ///
  /// In uk, this message translates to:
  /// **'Точку зустрічі позначено на мапі подій'**
  String get theMeetingPointIsMarkedOnTheEventMap;

  /// No description provided for @meetingPointCopied.
  ///
  /// In uk, this message translates to:
  /// **'Місце зустрічі скопійовано'**
  String get meetingPointCopied;

  /// No description provided for @copyLocation.
  ///
  /// In uk, this message translates to:
  /// **'Скопіювати місце'**
  String get copyLocation;

  /// No description provided for @whoSOrganizing.
  ///
  /// In uk, this message translates to:
  /// **'Хто організовує'**
  String get whoSOrganizing;

  /// No description provided for @organizerNameUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Ім’я організатора недоступне'**
  String get organizerNameUnavailable;

  /// No description provided for @eventOrganizer.
  ///
  /// In uk, this message translates to:
  /// **'Організатор події'**
  String get eventOrganizer;

  /// No description provided for @joiningYou.
  ///
  /// In uk, this message translates to:
  /// **'Разом із тобою'**
  String get joiningYou;

  /// No description provided for @noParticipantLimit.
  ///
  /// In uk, this message translates to:
  /// **'Кількість місць не обмежена.'**
  String get noParticipantLimit;

  /// No description provided for @participantLimit167.
  ///
  /// In uk, this message translates to:
  /// **'Ліміт учасників: {arg0}'**
  String participantLimit167(String arg0);

  /// No description provided for @youCanJoinAfterTheEventIsPublished.
  ///
  /// In uk, this message translates to:
  /// **'Участь відкриється після публікації.'**
  String get youCanJoinAfterTheEventIsPublished;

  /// No description provided for @registrationIsClosed.
  ///
  /// In uk, this message translates to:
  /// **'Реєстрацію на подію закрито.'**
  String get registrationIsClosed;

  /// No description provided for @theParticipantListWillBeAvailableAfterYouJoin.
  ///
  /// In uk, this message translates to:
  /// **'Список учасників буде доступний після приєднання.'**
  String get theParticipantListWillBeAvailableAfterYouJoin;

  /// No description provided for @pleaseWait.
  ///
  /// In uk, this message translates to:
  /// **'Зачекай…'**
  String get pleaseWait;

  /// No description provided for @refreshingEventDetails.
  ///
  /// In uk, this message translates to:
  /// **'Оновлюємо дані події'**
  String get refreshingEventDetails;

  /// No description provided for @couldNotCheckEventDetailsAndParticipation.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося перевірити дані та участь'**
  String get couldNotCheckEventDetailsAndParticipation;

  /// No description provided for @manageEvent.
  ///
  /// In uk, this message translates to:
  /// **'Керувати подією'**
  String get manageEvent;

  /// No description provided for @youReOrganizingThisEvent.
  ///
  /// In uk, this message translates to:
  /// **'Ти організатор цієї події'**
  String get youReOrganizingThisEvent;

  /// No description provided for @youAttended.
  ///
  /// In uk, this message translates to:
  /// **'Ти був учасником'**
  String get youAttended;

  /// No description provided for @leaveEvent.
  ///
  /// In uk, this message translates to:
  /// **'Вийти з події'**
  String get leaveEvent;

  /// No description provided for @thisEventIsNoLongerOpenToJoin.
  ///
  /// In uk, this message translates to:
  /// **'Подія вже недоступна для участі'**
  String get thisEventIsNoLongerOpenToJoin;

  /// No description provided for @youReOnTheParticipantList.
  ///
  /// In uk, this message translates to:
  /// **'Ти у списку учасників'**
  String get youReOnTheParticipantList;

  /// No description provided for @eventCancelled.
  ///
  /// In uk, this message translates to:
  /// **'Подію скасовано'**
  String get eventCancelled;

  /// No description provided for @thisEventHasnTBeenPublishedYet.
  ///
  /// In uk, this message translates to:
  /// **'Подію ще не опубліковано'**
  String get thisEventHasnTBeenPublishedYet;

  /// No description provided for @eventCompleted.
  ///
  /// In uk, this message translates to:
  /// **'Подія завершена'**
  String get eventCompleted;

  /// No description provided for @participationUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Участь недоступна'**
  String get participationUnavailable;

  /// No description provided for @noPlacesLeft.
  ///
  /// In uk, this message translates to:
  /// **'Усі місця зайняті'**
  String get noPlacesLeft;

  /// No description provided for @youCanCheckForPlacesLater.
  ///
  /// In uk, this message translates to:
  /// **'Можеш перевірити наявність місць пізніше'**
  String get youCanCheckForPlacesLater;

  /// No description provided for @joinEvent.
  ///
  /// In uk, this message translates to:
  /// **'Долучитися'**
  String get joinEvent;

  /// No description provided for @bePartOfAGoodCause.
  ///
  /// In uk, this message translates to:
  /// **'Долучайся до спільної справи'**
  String get bePartOfAGoodCause;

  /// No description provided for @placesAvailable.
  ///
  /// In uk, this message translates to:
  /// **'Вільних місць: {arg0}'**
  String placesAvailable(String arg0);

  /// No description provided for @all.
  ///
  /// In uk, this message translates to:
  /// **'Усі'**
  String get all;

  /// No description provided for @eventLocation.
  ///
  /// In uk, this message translates to:
  /// **'Місце події'**
  String get eventLocation;

  /// No description provided for @myLocation.
  ///
  /// In uk, this message translates to:
  /// **'Моя позиція'**
  String get myLocation;

  /// No description provided for @noPinSelectedYet.
  ///
  /// In uk, this message translates to:
  /// **'Точку ще не обрано'**
  String get noPinSelectedYet;

  /// No description provided for @useThisLocation.
  ///
  /// In uk, this message translates to:
  /// **'Використати місце'**
  String get useThisLocation;

  /// No description provided for @events.
  ///
  /// In uk, this message translates to:
  /// **'Події'**
  String get events;

  /// No description provided for @refresh.
  ///
  /// In uk, this message translates to:
  /// **'Оновити'**
  String get refresh;

  /// No description provided for @filters.
  ///
  /// In uk, this message translates to:
  /// **'Фільтри •'**
  String get filters;

  /// No description provided for @filters197.
  ///
  /// In uk, this message translates to:
  /// **'Фільтри'**
  String get filters197;

  /// No description provided for @noEventsNearbyYet.
  ///
  /// In uk, this message translates to:
  /// **'Поки немає подій поруч'**
  String get noEventsNearbyYet;

  /// No description provided for @createAnEventAndInvitePeopleToJoin.
  ///
  /// In uk, this message translates to:
  /// **'Створи подію та запроси людей долучитися.'**
  String get createAnEventAndInvitePeopleToJoin;

  /// No description provided for @tryBrowsingAllCategories.
  ///
  /// In uk, this message translates to:
  /// **'Спробуй переглянути всі категорії.'**
  String get tryBrowsingAllCategories;

  /// No description provided for @createEvent.
  ///
  /// In uk, this message translates to:
  /// **'Створити подію'**
  String get createEvent;

  /// No description provided for @resetFilters.
  ///
  /// In uk, this message translates to:
  /// **'Скинути фільтри'**
  String get resetFilters;

  /// No description provided for @locationServicesAreOffShowingEventsWithoutADistanceLimit.
  ///
  /// In uk, this message translates to:
  /// **'Геолокація вимкнена. Показуємо події без обмеження відстані.'**
  String get locationServicesAreOffShowingEventsWithoutADistanceLimit;

  /// No description provided for @allowLocationAccessToDiscoverNearbyEvents.
  ///
  /// In uk, this message translates to:
  /// **'Дозволь геолокацію, щоб бачити події поруч.'**
  String get allowLocationAccessToDiscoverNearbyEvents;

  /// No description provided for @youCanEnableLocationAccessInYourDeviceSettings.
  ///
  /// In uk, this message translates to:
  /// **'Доступ до геолокації можна увімкнути в налаштуваннях пристрою.'**
  String get youCanEnableLocationAccessInYourDeviceSettings;

  /// No description provided for @couldNotDetermineYourLocationShowingAvailableEvents.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося визначити позицію. Показуємо доступні події.'**
  String get couldNotDetermineYourLocationShowingAvailableEvents;

  /// No description provided for @thisEventIsNoLongerOpenToJoin207.
  ///
  /// In uk, this message translates to:
  /// **'Участь у цій події вже недоступна.'**
  String get thisEventIsNoLongerOpenToJoin207;

  /// No description provided for @thereAreNoPlacesLeft.
  ///
  /// In uk, this message translates to:
  /// **'Усі місця вже зайняті.'**
  String get thereAreNoPlacesLeft;

  /// No description provided for @jan.
  ///
  /// In uk, this message translates to:
  /// **'СІЧ'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In uk, this message translates to:
  /// **'ЛЮТ'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In uk, this message translates to:
  /// **'БЕР'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In uk, this message translates to:
  /// **'КВІ'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In uk, this message translates to:
  /// **'ТРА'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In uk, this message translates to:
  /// **'ЧЕР'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In uk, this message translates to:
  /// **'ЛИП'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In uk, this message translates to:
  /// **'СЕР'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In uk, this message translates to:
  /// **'ВЕР'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In uk, this message translates to:
  /// **'ЖОВ'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In uk, this message translates to:
  /// **'ЛИС'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In uk, this message translates to:
  /// **'ГРУ'**
  String get dec;

  /// No description provided for @participants221.
  ///
  /// In uk, this message translates to:
  /// **'учасників'**
  String get participants221;

  /// No description provided for @participant222.
  ///
  /// In uk, this message translates to:
  /// **'учасник'**
  String get participant222;

  /// No description provided for @participants223.
  ///
  /// In uk, this message translates to:
  /// **'учасники'**
  String get participants223;

  /// No description provided for @pastEvent.
  ///
  /// In uk, this message translates to:
  /// **'Подія минула'**
  String get pastEvent;

  /// No description provided for @openToEveryone.
  ///
  /// In uk, this message translates to:
  /// **'Відкрита участь'**
  String get openToEveryone;

  /// No description provided for @placesLeft.
  ///
  /// In uk, this message translates to:
  /// **'Залишилось місць: {arg0}'**
  String placesLeft(String arg0);

  /// No description provided for @view.
  ///
  /// In uk, this message translates to:
  /// **'Переглянути'**
  String get view;

  /// No description provided for @viewEvent.
  ///
  /// In uk, this message translates to:
  /// **'{arg0}. {arg1}. {arg2}. {arg3}. {arg4}. {arg5}. Переглянути подію.'**
  String viewEvent(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
    String arg4,
    String arg5,
  );

  /// No description provided for @m.
  ///
  /// In uk, this message translates to:
  /// **'{arg0} м'**
  String m(String arg0);

  /// No description provided for @km.
  ///
  /// In uk, this message translates to:
  /// **'{arg0} км'**
  String km(String arg0);

  /// No description provided for @theParticipantLimitMustBeGreaterThanZero.
  ///
  /// In uk, this message translates to:
  /// **'Кількість учасників має бути більшою за нуль.'**
  String get theParticipantLimitMustBeGreaterThanZero;

  /// No description provided for @couldNotUpdateTheChatAvatar.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося оновити аватар чату: {arg0}'**
  String couldNotUpdateTheChatAvatar(String arg0);

  /// No description provided for @enterTheFullImageUrl.
  ///
  /// In uk, this message translates to:
  /// **'Встав повне посилання на зображення'**
  String get enterTheFullImageUrl;

  /// No description provided for @theUrlMustStartWithHttpsOrHttp.
  ///
  /// In uk, this message translates to:
  /// **'Посилання має починатися з https:// або http://'**
  String get theUrlMustStartWithHttpsOrHttp;

  /// No description provided for @useADirectLinkToAnImageFile.
  ///
  /// In uk, this message translates to:
  /// **'Це має бути пряме посилання на файл картинки'**
  String get useADirectLinkToAnImageFile;

  /// No description provided for @chatAvatar.
  ///
  /// In uk, this message translates to:
  /// **'Аватар чату'**
  String get chatAvatar;

  /// No description provided for @avatarUrl.
  ///
  /// In uk, this message translates to:
  /// **'Посилання на аватарку'**
  String get avatarUrl;

  /// No description provided for @directUrlHttpsSiteComAvatarPng.
  ///
  /// In uk, this message translates to:
  /// **'Прямий URL: https://site.com/avatar.png'**
  String get directUrlHttpsSiteComAvatarPng;

  /// No description provided for @saving239.
  ///
  /// In uk, this message translates to:
  /// **'Збереження...'**
  String get saving239;

  /// No description provided for @save.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get save;

  /// No description provided for @removeAvatar.
  ///
  /// In uk, this message translates to:
  /// **'Очистити аватар'**
  String get removeAvatar;

  /// No description provided for @addStreamApiKeyToMobileEnvAndFullyRestart.
  ///
  /// In uk, this message translates to:
  /// **'Додай STREAM_API_KEY у mobile/.env і повністю перезапусти Flutter.'**
  String get addStreamApiKeyToMobileEnvAndFullyRestart;

  /// No description provided for @theEventHasEndedItsChatIsNoLongerAvailable.
  ///
  /// In uk, this message translates to:
  /// **'Подія завершена. Чат більше недоступний.'**
  String get theEventHasEndedItsChatIsNoLongerAvailable;

  /// No description provided for @streamChatIsNotConfiguredYet.
  ///
  /// In uk, this message translates to:
  /// **'Stream Chat ще не налаштовано.'**
  String get streamChatIsNotConfiguredYet;

  /// No description provided for @chats.
  ///
  /// In uk, this message translates to:
  /// **'Чати'**
  String get chats;

  /// No description provided for @connectedAsOnlyChatsForYourEventsAppearHere.
  ///
  /// In uk, this message translates to:
  /// **'Підключено як {arg0}. Тут показані тільки чати твоїх подій.'**
  String connectedAsOnlyChatsForYourEventsAppearHere(String arg0);

  /// No description provided for @couldNotLoadChats.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося завантажити чати'**
  String get couldNotLoadChats;

  /// No description provided for @yourConversationsStartHere.
  ///
  /// In uk, this message translates to:
  /// **'Твої розмови почнуться тут'**
  String get yourConversationsStartHere;

  /// No description provided for @joinAnEventToChatWithItsParticipants.
  ///
  /// In uk, this message translates to:
  /// **'Долучися до події, щоб спілкуватися з її учасниками.'**
  String get joinAnEventToChatWithItsParticipants;

  /// No description provided for @findEvents.
  ///
  /// In uk, this message translates to:
  /// **'Знайти події'**
  String get findEvents;

  /// No description provided for @participants251.
  ///
  /// In uk, this message translates to:
  /// **'{arg0} · {arg1} · {arg2} учасн.'**
  String participants251(String arg0, String arg1, String arg2);

  /// No description provided for @chatAvatarUpdated.
  ///
  /// In uk, this message translates to:
  /// **'Аватар чату оновлено'**
  String get chatAvatarUpdated;

  /// No description provided for @thisEventSChatIsNoLongerAvailable.
  ///
  /// In uk, this message translates to:
  /// **'Чат цієї події більше недоступний.'**
  String get thisEventSChatIsNoLongerAvailable;

  /// No description provided for @removeParticipant.
  ///
  /// In uk, this message translates to:
  /// **'Викинути учасника?'**
  String get removeParticipant;

  /// No description provided for @willLoseAccessToTheEventAndItsChat.
  ///
  /// In uk, this message translates to:
  /// **'{arg0} втратить доступ до події та її чату.'**
  String willLoseAccessToTheEventAndItsChat(String arg0);

  /// No description provided for @remove.
  ///
  /// In uk, this message translates to:
  /// **'Викинути'**
  String get remove;

  /// No description provided for @participantRemovedFromTheEventAndChat.
  ///
  /// In uk, this message translates to:
  /// **'Учасника видалено з події та чату'**
  String get participantRemovedFromTheEventAndChat;

  /// No description provided for @chatMembers.
  ///
  /// In uk, this message translates to:
  /// **'Учасники чату'**
  String get chatMembers;

  /// No description provided for @noParticipantsYet259.
  ///
  /// In uk, this message translates to:
  /// **'Учасників ще немає'**
  String get noParticipantsYet259;

  /// No description provided for @user260.
  ///
  /// In uk, this message translates to:
  /// **'Користувач'**
  String get user260;

  /// No description provided for @profileUpdated.
  ///
  /// In uk, this message translates to:
  /// **'Профіль оновлено'**
  String get profileUpdated;

  /// No description provided for @profile.
  ///
  /// In uk, this message translates to:
  /// **'Профіль'**
  String get profile;

  /// No description provided for @edit.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати'**
  String get edit;

  /// No description provided for @myActivity.
  ///
  /// In uk, this message translates to:
  /// **'Моя активність'**
  String get myActivity;

  /// No description provided for @reportsAndStatistics.
  ///
  /// In uk, this message translates to:
  /// **'Звіти та статистика'**
  String get reportsAndStatistics;

  /// No description provided for @myContributionParticipationAndPdfReport.
  ///
  /// In uk, this message translates to:
  /// **'Мій внесок, участь і PDF-звіт'**
  String get myContributionParticipationAndPdfReport;

  /// No description provided for @settings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settings;

  /// No description provided for @darkTheme.
  ///
  /// In uk, this message translates to:
  /// **'Темна тема'**
  String get darkTheme;

  /// No description provided for @couldNotLoadYourEvents.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося завантажити твої події'**
  String get couldNotLoadYourEvents;

  /// No description provided for @eventsICreated.
  ///
  /// In uk, this message translates to:
  /// **'Мої створені події'**
  String get eventsICreated;

  /// No description provided for @youHavenTCreatedAnyEventsYet271.
  ///
  /// In uk, this message translates to:
  /// **'Ти ще не створював подій'**
  String get youHavenTCreatedAnyEventsYet271;

  /// No description provided for @eventsIJoined.
  ///
  /// In uk, this message translates to:
  /// **'Я учасник'**
  String get eventsIJoined;

  /// No description provided for @youHavenTJoinedAnyEventsYet273.
  ///
  /// In uk, this message translates to:
  /// **'Ти ще не долучався до подій'**
  String get youHavenTJoinedAnyEventsYet273;

  /// No description provided for @holdToSignOut.
  ///
  /// In uk, this message translates to:
  /// **'Затисни, щоб вийти'**
  String get holdToSignOut;

  /// No description provided for @keepHoldingToSignOut.
  ///
  /// In uk, this message translates to:
  /// **'Тримай, щоб вийти'**
  String get keepHoldingToSignOut;

  /// No description provided for @bringPeopleTogetherAroundYourIdea.
  ///
  /// In uk, this message translates to:
  /// **'Об’єднай людей навколо своєї ідеї.'**
  String get bringPeopleTogetherAroundYourIdea;

  /// No description provided for @chooseAnEventAndJoinItWillAppearHere.
  ///
  /// In uk, this message translates to:
  /// **'Обери подію та долучися — вона з’явиться тут.'**
  String get chooseAnEventAndJoinItWillAppearHere;

  /// No description provided for @couldNotUpdateYourProfile.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося оновити профіль: {arg0}'**
  String couldNotUpdateYourProfile(String arg0);

  /// No description provided for @editProfile.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати профіль'**
  String get editProfile;

  /// No description provided for @initiativesMap.
  ///
  /// In uk, this message translates to:
  /// **'Мапа ініціатив'**
  String get initiativesMap;

  /// No description provided for @createAnInitiativeAndInvitePeople.
  ///
  /// In uk, this message translates to:
  /// **'Створи ініціативу та запроси людей.'**
  String get createAnInitiativeAndInvitePeople;

  /// No description provided for @tryAnotherCategoryOrBrowseAllEvents.
  ///
  /// In uk, this message translates to:
  /// **'Спробуй іншу категорію або переглянь усі події.'**
  String get tryAnotherCategoryOrBrowseAllEvents;

  /// No description provided for @changeFilters.
  ///
  /// In uk, this message translates to:
  /// **'Змінити фільтри'**
  String get changeFilters;

  /// No description provided for @events284.
  ///
  /// In uk, this message translates to:
  /// **'Подій: {arg0}'**
  String events284(String arg0);

  /// No description provided for @distanceUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Відстань недоступна'**
  String get distanceUnavailable;

  /// No description provided for @mAway.
  ///
  /// In uk, this message translates to:
  /// **'{arg0} м від тебе'**
  String mAway(String arg0);

  /// No description provided for @kmAway.
  ///
  /// In uk, this message translates to:
  /// **'{arg0} км від тебе'**
  String kmAway(String arg0);

  /// No description provided for @closeCard.
  ///
  /// In uk, this message translates to:
  /// **'Закрити картку'**
  String get closeCard;

  /// No description provided for @viewEvent289.
  ///
  /// In uk, this message translates to:
  /// **'Переглянути подію'**
  String get viewEvent289;

  /// No description provided for @eventFilters.
  ///
  /// In uk, this message translates to:
  /// **'Фільтри подій'**
  String get eventFilters;

  /// No description provided for @closeFilters.
  ///
  /// In uk, this message translates to:
  /// **'Закрити фільтри'**
  String get closeFilters;

  /// No description provided for @categoriesSelectMoreThanOne.
  ///
  /// In uk, this message translates to:
  /// **'Категорії · можна обрати декілька'**
  String get categoriesSelectMoreThanOne;

  /// No description provided for @allCategories.
  ///
  /// In uk, this message translates to:
  /// **'Усі категорії'**
  String get allCategories;

  /// No description provided for @eventStartDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата початку події'**
  String get eventStartDate;

  /// No description provided for @anyDate.
  ///
  /// In uk, this message translates to:
  /// **'Будь-яка дата'**
  String get anyDate;

  /// No description provided for @clearDates.
  ///
  /// In uk, this message translates to:
  /// **'Прибрати дати'**
  String get clearDates;

  /// No description provided for @radiusKm.
  ///
  /// In uk, this message translates to:
  /// **'Радіус: {arg0} км'**
  String radiusKm(String arg0);

  /// No description provided for @fromYourSelectedCityOrCurrentLocation.
  ///
  /// In uk, this message translates to:
  /// **'Від вибраного міста або твоєї геолокації.'**
  String get fromYourSelectedCityOrCurrentLocation;

  /// No description provided for @aRadiusRequiresYourLocationOrASelectedCityCurrently.
  ///
  /// In uk, this message translates to:
  /// **'Для радіуса потрібна геолокація або вибране місто. Зараз пошук без обмеження відстані.'**
  String get aRadiusRequiresYourLocationOrASelectedCityCurrently;

  /// No description provided for @showEvents.
  ///
  /// In uk, this message translates to:
  /// **'Показати події'**
  String get showEvents;

  /// No description provided for @resetAllFilters.
  ///
  /// In uk, this message translates to:
  /// **'Скинути всі фільтри'**
  String get resetAllFilters;

  /// No description provided for @registration.
  ///
  /// In uk, this message translates to:
  /// **'Реєстрація'**
  String get registration;

  /// No description provided for @createAccount.
  ///
  /// In uk, this message translates to:
  /// **'Створити акаунт'**
  String get createAccount;

  /// No description provided for @signUpToCreateInitiativesAndJoinNearbyEvents.
  ///
  /// In uk, this message translates to:
  /// **'Зареєструйся, щоб створювати ініціативи та долучатися до подій поруч.'**
  String get signUpToCreateInitiativesAndJoinNearbyEvents;

  /// No description provided for @forExampleAnnaPetrenko.
  ///
  /// In uk, this message translates to:
  /// **'Наприклад, Анна Петренко'**
  String get forExampleAnnaPetrenko;

  /// No description provided for @enterYourName.
  ///
  /// In uk, this message translates to:
  /// **'Введи імʼя'**
  String get enterYourName;

  /// No description provided for @enterYourEmail.
  ///
  /// In uk, this message translates to:
  /// **'Введи пошту'**
  String get enterYourEmail;

  /// No description provided for @password.
  ///
  /// In uk, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @atLeastCharacters309.
  ///
  /// In uk, this message translates to:
  /// **'Мінімум 6 символів'**
  String get atLeastCharacters309;

  /// No description provided for @pleaseWait310.
  ///
  /// In uk, this message translates to:
  /// **'Зачекай...'**
  String get pleaseWait310;

  /// No description provided for @signUp.
  ///
  /// In uk, this message translates to:
  /// **'Зареєструватися'**
  String get signUp;

  /// No description provided for @initiativesEventsAndPeopleNearby.
  ///
  /// In uk, this message translates to:
  /// **'Ініціативи, події та люди поруч'**
  String get initiativesEventsAndPeopleNearby;

  /// No description provided for @retryRestoringYourSession.
  ///
  /// In uk, this message translates to:
  /// **'Повторити відновлення входу'**
  String get retryRestoringYourSession;

  /// No description provided for @enterAValidEmail.
  ///
  /// In uk, this message translates to:
  /// **'Введи коректну пошту'**
  String get enterAValidEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In uk, this message translates to:
  /// **'Введи пароль'**
  String get enterYourPassword;

  /// No description provided for @signIn.
  ///
  /// In uk, this message translates to:
  /// **'Увійти'**
  String get signIn;

  /// No description provided for @forgotPassword.
  ///
  /// In uk, this message translates to:
  /// **'Забув пароль?'**
  String get forgotPassword;

  /// No description provided for @accountCreatedSignInWithYourEmailAndPassword.
  ///
  /// In uk, this message translates to:
  /// **'Акаунт створено. Тепер увійди зі своєю поштою та паролем.'**
  String get accountCreatedSignInWithYourEmailAndPassword;

  /// No description provided for @passwordResetEmailSentCheckYourInboxAndSpamFolder.
  ///
  /// In uk, this message translates to:
  /// **'Лист для зміни пароля надіслано. Перевір пошту та папку Спам.'**
  String get passwordResetEmailSentCheckYourInboxAndSpamFolder;

  /// No description provided for @resetPassword.
  ///
  /// In uk, this message translates to:
  /// **'Відновлення пароля'**
  String get resetPassword;

  /// No description provided for @enterYourAccountEmailToReceiveAPasswordResetLink.
  ///
  /// In uk, this message translates to:
  /// **'Введи пошту акаунта, і Firebase надішле лист для зміни пароля.'**
  String get enterYourAccountEmailToReceiveAPasswordResetLink;

  /// No description provided for @emailSentCheckYourSpamFolderOrResendWhenThe.
  ///
  /// In uk, this message translates to:
  /// **'Лист надіслано. Якщо його немає, перевір папку Спам або надішли повторно після таймера.'**
  String get emailSentCheckYourSpamFolderOrResendWhenThe;

  /// No description provided for @sending.
  ///
  /// In uk, this message translates to:
  /// **'Надсилання...'**
  String get sending;

  /// No description provided for @resendInS.
  ///
  /// In uk, this message translates to:
  /// **'Повторно через {arg0} с'**
  String resendInS(String arg0);

  /// No description provided for @resendEmail.
  ///
  /// In uk, this message translates to:
  /// **'Надіслати повторно'**
  String get resendEmail;

  /// No description provided for @sendEmail.
  ///
  /// In uk, this message translates to:
  /// **'Надіслати лист'**
  String get sendEmail;

  /// No description provided for @couldNotSignIn.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося увійти.'**
  String get couldNotSignIn;

  /// No description provided for @couldNotCreateTheUser.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося створити користувача.'**
  String get couldNotCreateTheUser;

  /// No description provided for @passwordResetIsOnlyAvailableThroughFirebaseAuth.
  ///
  /// In uk, this message translates to:
  /// **'Скидання пароля доступне тільки через Firebase Auth.'**
  String get passwordResetIsOnlyAvailableThroughFirebaseAuth;

  /// No description provided for @thisEmailIsAlreadyInUse.
  ///
  /// In uk, this message translates to:
  /// **'Ця пошта вже використовується.'**
  String get thisEmailIsAlreadyInUse;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In uk, this message translates to:
  /// **'Некоректна адреса пошти.'**
  String get invalidEmailAddress;

  /// No description provided for @thePasswordIsTooWeak.
  ///
  /// In uk, this message translates to:
  /// **'Пароль занадто слабкий.'**
  String get thePasswordIsTooWeak;

  /// No description provided for @noUserFoundWithThisEmail.
  ///
  /// In uk, this message translates to:
  /// **'Користувача з такою поштою не знайдено.'**
  String get noUserFoundWithThisEmail;

  /// No description provided for @incorrectEmailOrPassword.
  ///
  /// In uk, this message translates to:
  /// **'Невірна пошта або пароль.'**
  String get incorrectEmailOrPassword;

  /// No description provided for @noConnectionToFirebase.
  ///
  /// In uk, this message translates to:
  /// **'Немає зʼєднання з Firebase.'**
  String get noConnectionToFirebase;

  /// No description provided for @firebaseAuthError.
  ///
  /// In uk, this message translates to:
  /// **'Помилка Firebase Auth.'**
  String get firebaseAuthError;

  /// No description provided for @home.
  ///
  /// In uk, this message translates to:
  /// **'Головна'**
  String get home;

  /// No description provided for @map.
  ///
  /// In uk, this message translates to:
  /// **'Мапа'**
  String get map;

  /// No description provided for @create.
  ///
  /// In uk, this message translates to:
  /// **'Створити'**
  String get create;

  /// No description provided for @lviv.
  ///
  /// In uk, this message translates to:
  /// **'Львів'**
  String get lviv;

  /// No description provided for @kyiv.
  ///
  /// In uk, this message translates to:
  /// **'Київ'**
  String get kyiv;

  /// No description provided for @ivanoFrankivsk.
  ///
  /// In uk, this message translates to:
  /// **'Івано-Франківськ'**
  String get ivanoFrankivsk;

  /// No description provided for @ternopil.
  ///
  /// In uk, this message translates to:
  /// **'Тернопіль'**
  String get ternopil;

  /// No description provided for @odesa.
  ///
  /// In uk, this message translates to:
  /// **'Одеса'**
  String get odesa;

  /// No description provided for @dnipro.
  ///
  /// In uk, this message translates to:
  /// **'Дніпро'**
  String get dnipro;

  /// No description provided for @kharkiv.
  ///
  /// In uk, this message translates to:
  /// **'Харків'**
  String get kharkiv;

  /// No description provided for @whereShouldWeLook.
  ///
  /// In uk, this message translates to:
  /// **'Де шукаємо події?'**
  String get whereShouldWeLook;

  /// No description provided for @showingEventsWithinTheSelectedSearchRadius.
  ///
  /// In uk, this message translates to:
  /// **'Показуємо події в межах вибраного радіуса пошуку.'**
  String get showingEventsWithinTheSelectedSearchRadius;

  /// No description provided for @nearMe.
  ///
  /// In uk, this message translates to:
  /// **'Поруч зі мною'**
  String get nearMe;

  /// No description provided for @usingYourDeviceSLocation.
  ///
  /// In uk, this message translates to:
  /// **'За геолокацією пристрою'**
  String get usingYourDeviceSLocation;

  /// No description provided for @myProfile.
  ///
  /// In uk, this message translates to:
  /// **'Мій профіль'**
  String get myProfile;

  /// No description provided for @me.
  ///
  /// In uk, this message translates to:
  /// **'Я'**
  String get me;

  /// No description provided for @yourCityYourPeople.
  ///
  /// In uk, this message translates to:
  /// **'ТВОЄ МІСТО. ТВОЇ ЛЮДИ.'**
  String get yourCityYourPeople;

  /// No description provided for @goodThingsNstartNearby.
  ///
  /// In uk, this message translates to:
  /// **'Добрі справи\nпочинаються поруч.'**
  String get goodThingsNstartNearby;

  /// No description provided for @discoverEventsMeetPeopleNandMakeADifferenceInYour.
  ///
  /// In uk, this message translates to:
  /// **'Знаходь події, знайомся з людьми\nта змінюй своє місто.'**
  String get discoverEventsMeetPeopleNandMakeADifferenceInYour;

  /// No description provided for @findAnEventOrAGoodCause.
  ///
  /// In uk, this message translates to:
  /// **'Знайти подію або добру справу'**
  String get findAnEventOrAGoodCause;

  /// No description provided for @clearSearch.
  ///
  /// In uk, this message translates to:
  /// **'Очистити пошук'**
  String get clearSearch;

  /// No description provided for @whatMattersToYou.
  ///
  /// In uk, this message translates to:
  /// **'Що тобі близьке?'**
  String get whatMattersToYou;

  /// No description provided for @advancedFilters.
  ///
  /// In uk, this message translates to:
  /// **'Розширені фільтри'**
  String get advancedFilters;

  /// No description provided for @all360.
  ///
  /// In uk, this message translates to:
  /// **'Усе'**
  String get all360;

  /// No description provided for @yourCalendarIsTemporarilyUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Твій календар поки недоступний'**
  String get yourCalendarIsTemporarilyUnavailable;

  /// No description provided for @anIdeaForYourCommunity.
  ///
  /// In uk, this message translates to:
  /// **'Є ІДЕЯ ДЛЯ СПІЛЬНОТИ?'**
  String get anIdeaForYourCommunity;

  /// No description provided for @yourEventIsHappening.
  ///
  /// In uk, this message translates to:
  /// **'ТВОЯ ПОДІЯ ТРИВАЄ'**
  String get yourEventIsHappening;

  /// No description provided for @yourEventIsToday.
  ///
  /// In uk, this message translates to:
  /// **'ТВОЯ ПОДІЯ СЬОГОДНІ'**
  String get yourEventIsToday;

  /// No description provided for @yourNextEvent.
  ///
  /// In uk, this message translates to:
  /// **'ТВОЯ НАСТУПНА ПОДІЯ'**
  String get yourNextEvent;

  /// No description provided for @bringPeopleTogetherNforAGoodCause.
  ///
  /// In uk, this message translates to:
  /// **'Об’єднай людей\nнавколо доброї справи.'**
  String get bringPeopleTogetherNforAGoodCause;

  /// No description provided for @createEvent367.
  ///
  /// In uk, this message translates to:
  /// **'Створити подію →'**
  String get createEvent367;

  /// No description provided for @couldNotLoadEvents.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося завантажити події'**
  String get couldNotLoadEvents;

  /// No description provided for @letSFindYourCity.
  ///
  /// In uk, this message translates to:
  /// **'Знайдемо твоє місто?'**
  String get letSFindYourCity;

  /// No description provided for @withoutLocationAccessWeShowEventsFromDifferentCities.
  ///
  /// In uk, this message translates to:
  /// **'Без геолокації показуємо доступні події з різних міст.'**
  String get withoutLocationAccessWeShowEventsFromDifferentCities;

  /// No description provided for @chooseACity.
  ///
  /// In uk, this message translates to:
  /// **'Обрати місто'**
  String get chooseACity;

  /// No description provided for @noEventsMatchYourSearch.
  ///
  /// In uk, this message translates to:
  /// **'За цим запитом подій немає'**
  String get noEventsMatchYourSearch;

  /// No description provided for @itSQuietHereWantToStartSomething.
  ///
  /// In uk, this message translates to:
  /// **'Тут поки тихо. Почнемо з тебе?'**
  String get itSQuietHereWantToStartSomething;

  /// No description provided for @tryDifferentWordsOrAnotherCategory.
  ///
  /// In uk, this message translates to:
  /// **'Спробуй інші слова або вибери іншу категорію.'**
  String get tryDifferentWordsOrAnotherCategory;

  /// No description provided for @createTheFirstInitiativeOrTryAnotherCity.
  ///
  /// In uk, this message translates to:
  /// **'Створи першу ініціативу або пошукай в іншому місті.'**
  String get createTheFirstInitiativeOrTryAnotherCity;

  /// No description provided for @thisWeekend.
  ///
  /// In uk, this message translates to:
  /// **'Цими вихідними'**
  String get thisWeekend;

  /// No description provided for @searchResults.
  ///
  /// In uk, this message translates to:
  /// **'Результати пошуку'**
  String get searchResults;

  /// No description provided for @nearbyEvents.
  ///
  /// In uk, this message translates to:
  /// **'Події поруч'**
  String get nearbyEvents;

  /// No description provided for @discoverSomethingNew.
  ///
  /// In uk, this message translates to:
  /// **'Відкривай нове'**
  String get discoverSomethingNew;

  /// No description provided for @openMap.
  ///
  /// In uk, this message translates to:
  /// **'Відкрити мапу'**
  String get openMap;

  /// No description provided for @loadingEvents.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження подій'**
  String get loadingEvents;

  /// No description provided for @loading.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження'**
  String get loading;

  /// No description provided for @theServerDidNotRespondInTimeTryAgain.
  ///
  /// In uk, this message translates to:
  /// **'Сервер не відповів вчасно. Спробуй ще раз.'**
  String get theServerDidNotRespondInTimeTryAgain;

  /// No description provided for @noConnectionToTheServerCheckYourInternetAndTry.
  ///
  /// In uk, this message translates to:
  /// **'Немає з’єднання із сервером. Перевір інтернет і спробуй ще раз.'**
  String get noConnectionToTheServerCheckYourInternetAndTry;

  /// No description provided for @yourSessionHasExpiredSignInAgain.
  ///
  /// In uk, this message translates to:
  /// **'Сесія завершилася. Увійди ще раз.'**
  String get yourSessionHasExpiredSignInAgain;

  /// No description provided for @youDonTHavePermissionToDoThis.
  ///
  /// In uk, this message translates to:
  /// **'Недостатньо прав для цієї дії.'**
  String get youDonTHavePermissionToDoThis;

  /// No description provided for @theServiceIsTemporarilyUnavailableTryAgainLater.
  ///
  /// In uk, this message translates to:
  /// **'Сервіс тимчасово недоступний. Спробуй пізніше.'**
  String get theServiceIsTemporarilyUnavailableTryAgainLater;

  /// No description provided for @couldNotCompleteTheRequest.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося виконати запит.'**
  String get couldNotCompleteTheRequest;

  /// No description provided for @theServerReturnedInvalidData.
  ///
  /// In uk, this message translates to:
  /// **'Сервер повернув некоректні дані.'**
  String get theServerReturnedInvalidData;

  /// No description provided for @language.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In uk, this message translates to:
  /// **'Мова пристрою'**
  String get systemLanguage;

  /// No description provided for @draftServerUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Сервер ще не підтримує безпечне збереження чернеток. Подію не опубліковано. Спробуй після оновлення сервера.'**
  String get draftServerUnavailable;

  /// No description provided for @bio.
  ///
  /// In uk, this message translates to:
  /// **'Про себе'**
  String get bio;

  /// No description provided for @eventNotFound.
  ///
  /// In uk, this message translates to:
  /// **'Подію не знайдено.'**
  String get eventNotFound;

  /// No description provided for @chatNotFound.
  ///
  /// In uk, this message translates to:
  /// **'Чат не знайдено.'**
  String get chatNotFound;

  /// No description provided for @userNotFound.
  ///
  /// In uk, this message translates to:
  /// **'Користувача не знайдено.'**
  String get userNotFound;

  /// No description provided for @profileNotSynced.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося синхронізувати профіль. Спробуй увійти ще раз.'**
  String get profileNotSynced;

  /// No description provided for @validationFailed.
  ///
  /// In uk, this message translates to:
  /// **'Перевір заповнені поля.'**
  String get validationFailed;

  /// No description provided for @statusChangeUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Ця зміна статусу вже недоступна. Онови подію.'**
  String get statusChangeUnavailable;

  /// No description provided for @completeStartedOnly.
  ///
  /// In uk, this message translates to:
  /// **'Завершити можна лише подію, яка вже почалася.'**
  String get completeStartedOnly;

  /// No description provided for @startMustBeFuture.
  ///
  /// In uk, this message translates to:
  /// **'Новий час початку має бути в майбутньому.'**
  String get startMustBeFuture;

  /// No description provided for @endHasPassed.
  ///
  /// In uk, this message translates to:
  /// **'Час завершення вже минув.'**
  String get endHasPassed;

  /// No description provided for @publishFutureStart.
  ///
  /// In uk, this message translates to:
  /// **'Перед публікацією обери майбутній час початку.'**
  String get publishFutureStart;

  /// No description provided for @startedTimeLocked.
  ///
  /// In uk, this message translates to:
  /// **'Не можна переносити початок події, яка вже почалася.'**
  String get startedTimeLocked;

  /// No description provided for @capacityBelowAttendance.
  ///
  /// In uk, this message translates to:
  /// **'Ліміт не може бути меншим за кількість учасників.'**
  String get capacityBelowAttendance;

  /// No description provided for @endedParticipationLocked.
  ///
  /// In uk, this message translates to:
  /// **'Участь у завершеній події не змінюється.'**
  String get endedParticipationLocked;

  /// No description provided for @organizerCannotLeave.
  ///
  /// In uk, this message translates to:
  /// **'Організатор не може вийти зі своєї події.'**
  String get organizerCannotLeave;

  /// No description provided for @organizerCannotBeRemoved.
  ///
  /// In uk, this message translates to:
  /// **'Організатора не можна видалити з події.'**
  String get organizerCannotBeRemoved;

  /// No description provided for @leaveInsteadOfRemove.
  ///
  /// In uk, this message translates to:
  /// **'Скористайся кнопкою виходу з події.'**
  String get leaveInsteadOfRemove;

  /// No description provided for @notEventMember.
  ///
  /// In uk, this message translates to:
  /// **'Користувач не є учасником цієї події.'**
  String get notEventMember;

  /// No description provided for @chatUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Чат зараз недоступний. Спробуй пізніше.'**
  String get chatUnavailable;
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
