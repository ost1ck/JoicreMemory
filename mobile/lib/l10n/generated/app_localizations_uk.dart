// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get reports => 'Звіти';

  @override
  String get couldNotGenerateTheReport => 'Не вдалося сформувати звіт.';

  @override
  String get createdEvents => 'Створені події';

  @override
  String get youHavenTCreatedAnyEventsYet => 'Ти ще не створював подій.';

  @override
  String get myParticipation => 'Моя участь';

  @override
  String get youHavenTJoinedAnyEventsYet => 'Ти ще не долучався до подій.';

  @override
  String get personalReport => 'Персональний звіт';

  @override
  String updated(String arg0) {
    return 'Оновлено $arg0';
  }

  @override
  String get preparingPdf => 'Підготовка PDF...';

  @override
  String get generateAndPrintPdf => 'Сформувати і друкувати PDF';

  @override
  String get created => 'Створено';

  @override
  String get joined => 'Участь';

  @override
  String get participants => 'Учасників';

  @override
  String get fillRate => 'Заповненість';

  @override
  String get plannedHrs => 'Планові год.';

  @override
  String get upcoming => 'Майбутні';

  @override
  String get myContribution => 'Мій внесок';

  @override
  String get eventsByCategory => 'Події за категоріями';

  @override
  String get noChartDataYet => 'Ще немає даних для діаграми.';

  @override
  String get activity => 'Активність';

  @override
  String get created20 => 'Створ.';

  @override
  String get upcoming21 => 'Майб.';

  @override
  String get ended => 'Зав.';

  @override
  String thePdfWillIncludeMoreEvents(String arg0) {
    return 'У PDF буде ще $arg0 подій.';
  }

  @override
  String hrs(String arg0) {
    return '$arg0 год';
  }

  @override
  String get noEndTime => 'без кінця';

  @override
  String get tryAgain => 'Спробувати ще раз';

  @override
  String get eventsTheUserHasJoined => 'Події, де користувач є учасником';

  @override
  String get joicrememoryReport => 'Звіт JoicreMemory';

  @override
  String user(String arg0) {
    return 'Користувач: $arg0';
  }

  @override
  String email(String arg0) {
    return 'Пошта: $arg0';
  }

  @override
  String generated(String arg0) {
    return 'Сформовано: $arg0';
  }

  @override
  String get summary => 'Коротка аналітика';

  @override
  String get metric => 'Показник';

  @override
  String get value => 'Значення';

  @override
  String get eventsCreated => 'Створено подій';

  @override
  String get eventsJoined => 'Участь у подіях';

  @override
  String get participantsInMyEvents => 'Учасників у моїх подіях';

  @override
  String get averageFillRate => 'Середня заповненість';

  @override
  String get plannedHoursEventsWithAnEndTime =>
      'Планові години (де вказано завершення)';

  @override
  String get upcomingEvents => 'Майбутні події';

  @override
  String get completedEvents => 'Завершені події';

  @override
  String get categories => 'Категорії';

  @override
  String get noCategoryDataYet => 'Даних за категоріями ще немає.';

  @override
  String get category => 'Категорія';

  @override
  String get participants45 => 'Учасники';

  @override
  String get noEventsInThisSection => 'Немає подій для цього розділу.';

  @override
  String get title => 'Назва';

  @override
  String get date => 'Дата';

  @override
  String get place => 'Місце';

  @override
  String participants50(String arg0) {
    return 'Учасники: $arg0';
  }

  @override
  String get noParticipantsYet => 'Учасників ще немає.';

  @override
  String get name => 'Імʼя';

  @override
  String get email53 => 'Пошта';

  @override
  String get role => 'Роль';

  @override
  String get dateJoined => 'Дата долучення';

  @override
  String get organizer => 'Організатор';

  @override
  String get participant => 'Учасник';

  @override
  String noEndTime58(String arg0) {
    return '$arg0 (без завершення)';
  }

  @override
  String get addressFoundCheckItAndClarifyTheMeetingPointIf =>
      'Адресу визначено. Перевір її та за потреби уточни місце зустрічі.';

  @override
  String get pinSavedNoAddressFoundYouCanAddALandmark =>
      'Точку збережено. Адресу не знайдено — можеш додати орієнтир вручну.';

  @override
  String get pinSavedCouldNotFindTheAddressYouCanEnter =>
      'Точку збережено. Не вдалося визначити адресу — її можна уточнити вручну.';

  @override
  String get mapPin => 'Точка на мапі';

  @override
  String get draftSavedToYourProfile => 'Чернетку збережено у профілі';

  @override
  String get eventPublished => 'Подію опубліковано';

  @override
  String get changesSaved => 'Зміни збережено';

  @override
  String couldNotSaveTheEvent(String arg0) {
    return 'Не вдалося створити подію: $arg0';
  }

  @override
  String get newEvent => 'Нова подія';

  @override
  String get editEvent => 'Редагувати подію';

  @override
  String get draft => 'Чернетка';

  @override
  String get saving => 'Зберігаємо…';

  @override
  String get publishEvent => 'Опублікувати подію';

  @override
  String get saveDraft => 'Зберегти чернетку';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get aGoodCauseStartsWithYou => 'Хороша справа починається з тебе.';

  @override
  String get shareYourIdeaChooseAPlaceAndInvitePeopleTo =>
      'Розкажи про ідею, обери місце та запроси людей долучитися.';

  @override
  String get onlyYouCanSeeThisDraftInYourProfileIt =>
      'Чернетка видима лише тобі у профілі. Вона не з’явиться на мапі чи у стрічці, а чат буде створено після публікації. Заповни основні поля, щоб зберегти її.';

  @override
  String get aboutTheEvent => 'Про подію';

  @override
  String get whatWillYouDoTogetherAndWhoIsItFor =>
      'Що ви робитимете разом і кому буде цікаво?';

  @override
  String get eventTitle => 'Назва події';

  @override
  String get characters => 'Від 3 до 140 символів';

  @override
  String get forExampleAParkCleanup => 'Наприклад, толока у парку';

  @override
  String get atLeastCharacters => 'Мінімум 3 символи';

  @override
  String get whatToKnow => 'Що варто знати';

  @override
  String get characters84 => 'Від 10 до 5000 символів';

  @override
  String get thePlanWhatToBringAndWhoCanJoin =>
      'План, що взяти із собою, кому підходить подія';

  @override
  String get atLeastCharacters86 => 'Мінімум 10 символів';

  @override
  String get whereWeLlMeet => 'Де зустрічаємось';

  @override
  String get dropAPinWeLlTryToFindTheAddress =>
      'Постав точку — адресу спробуємо визначити автоматично.';

  @override
  String get chooseAPlaceOnTheMap => 'Обери місце на мапі';

  @override
  String get chooseAPlaceOnTheMap90 => 'Обрати місце на мапі';

  @override
  String get moveTheMapPin => 'Змінити точку на мапі';

  @override
  String get atLeastCharacters92 => 'Мінімум 2 символи';

  @override
  String get placeNameOrLandmark => 'Назва місця або орієнтир';

  @override
  String get forExampleByTheMainEntrance => 'Наприклад, біля головного входу';

  @override
  String get optionalTheMapPinDefinesTheLocation =>
      'Необов’язково: місце визначає точка на мапі';

  @override
  String get address => 'Адреса';

  @override
  String get filledInAfterYouChooseAPin => 'Заповниться після вибору точки';

  @override
  String get youCanEditThisOrLeaveItBlank =>
      'Можна виправити або залишити порожньою';

  @override
  String get timeAndParticipants => 'Час та учасники';

  @override
  String get helpPeoplePlanTheirVisit => 'Допоможи людям спланувати участь.';

  @override
  String get start => 'Початок';

  @override
  String get theEndMustBeAfterTheEventStarts =>
      'Завершення має бути пізніше за початок події.';

  @override
  String get end => 'Завершення';

  @override
  String get notSpecified => 'Не вказано';

  @override
  String get withoutAnEndTimeTheChatCannotBeDeletedAutomatically =>
      'Без часу завершення чат не можна видалити автоматично за розкладом.';

  @override
  String get theEventChatWillBeDeletedAfterTheEventEnds =>
      'Після завершення події її чат буде видалено.';

  @override
  String get leaveTheEndTimeOpen => 'Не вказувати завершення';

  @override
  String get participantLimit => 'Ліміт учасників';

  @override
  String get forExample => 'Наприклад, 30';

  @override
  String get leaveBlankForUnlimitedParticipation =>
      'Залиш порожнім, якщо обмежень немає';

  @override
  String get enterAWholeNumberFromTo => 'Вкажи ціле число від 1 до 10000';

  @override
  String get mapLocationSelected => 'Місце на мапі обрано';

  @override
  String get volunteering => 'Волонтерство';

  @override
  String get charity => 'Благодійність';

  @override
  String get cleanup => 'Прибирання';

  @override
  String get education => 'Освіта';

  @override
  String get community => 'Громада';

  @override
  String get urgent => 'Терміново';

  @override
  String get other => 'Інше';

  @override
  String get youVeJoinedTheEvent => 'Ти долучився до події!';

  @override
  String get leaveTheEvent => 'Вийти з події?';

  @override
  String get youWillBeRemovedFromTheParticipantList =>
      'Ти більше не будеш у списку учасників.';

  @override
  String get leave => 'Вийти';

  @override
  String get youVeLeftTheEvent => 'Ти вийшов із події.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get deleteTheEvent => 'Видалити подію?';

  @override
  String get theEventAndItsChatWillBeDeletedThisCannot =>
      'Подію та її чат буде видалено. Цю дію не можна скасувати.';

  @override
  String get delete => 'Видалити';

  @override
  String get yourEvent => 'Твоя подія';

  @override
  String get publish => 'Опублікувати';

  @override
  String get completeEvent => 'Завершити подію';

  @override
  String get cancelEvent => 'Скасувати подію';

  @override
  String get viewParticipants => 'Переглянути учасників';

  @override
  String get deleteEvent => 'Видалити подію';

  @override
  String get publishTheEvent => 'Опублікувати подію?';

  @override
  String get completeTheEvent => 'Завершити подію?';

  @override
  String get cancelTheEvent => 'Скасувати подію?';

  @override
  String get theEventWillBecomeVisibleToOtherUsers =>
      'Подія стане видимою іншим користувачам.';

  @override
  String get newParticipantsWillNoLongerBeAbleToJoinThe =>
      'Нові учасники не зможуть долучитися. Чат та його історію буде видалено. Повернути попередній статус неможливо.';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get eventStatusUpdated => 'Статус події оновлено';

  @override
  String get eventParticipants => 'Учасники події';

  @override
  String get couldNotLoadParticipants => 'Не вдалося завантажити учасників.';

  @override
  String get retry => 'Повторити';

  @override
  String get noParticipantsYet145 => 'Учасників поки немає.';

  @override
  String get comingSoon => 'Незабаром';

  @override
  String get happeningNow => 'Триває зараз';

  @override
  String get today => 'Сьогодні';

  @override
  String get cancelled => 'Скасовано';

  @override
  String get completed => 'Завершено';

  @override
  String get eventDetails => 'Деталі події';

  @override
  String get youReTheOrganizer => 'Ти організатор';

  @override
  String get youReAttending => 'Ти береш участь';

  @override
  String get couldNotRefreshTheEventDetails => 'Не вдалося оновити дані події.';

  @override
  String get when => 'КОЛИ';

  @override
  String get noEndTimeSpecified => 'Час завершення не вказано';

  @override
  String until(String arg0) {
    return 'До $arg0';
  }

  @override
  String get where => 'ДЕ';

  @override
  String get theMeetingPointIsMarkedOnTheEventMap =>
      'Точку зустрічі позначено на мапі подій';

  @override
  String get meetingPointCopied => 'Місце зустрічі скопійовано';

  @override
  String get copyLocation => 'Скопіювати місце';

  @override
  String get whoSOrganizing => 'Хто організовує';

  @override
  String get organizerNameUnavailable => 'Ім’я організатора недоступне';

  @override
  String get eventOrganizer => 'Організатор події';

  @override
  String get joiningYou => 'Разом із тобою';

  @override
  String get noParticipantLimit => 'Кількість місць не обмежена.';

  @override
  String participantLimit167(String arg0) {
    return 'Ліміт учасників: $arg0';
  }

  @override
  String get youCanJoinAfterTheEventIsPublished =>
      'Участь відкриється після публікації.';

  @override
  String get registrationIsClosed => 'Реєстрацію на подію закрито.';

  @override
  String get theParticipantListWillBeAvailableAfterYouJoin =>
      'Список учасників буде доступний після приєднання.';

  @override
  String get pleaseWait => 'Зачекай…';

  @override
  String get refreshingEventDetails => 'Оновлюємо дані події';

  @override
  String get couldNotCheckEventDetailsAndParticipation =>
      'Не вдалося перевірити дані та участь';

  @override
  String get manageEvent => 'Керувати подією';

  @override
  String get youReOrganizingThisEvent => 'Ти організатор цієї події';

  @override
  String get youAttended => 'Ти був учасником';

  @override
  String get leaveEvent => 'Вийти з події';

  @override
  String get thisEventIsNoLongerOpenToJoin => 'Подія вже недоступна для участі';

  @override
  String get youReOnTheParticipantList => 'Ти у списку учасників';

  @override
  String get eventCancelled => 'Подію скасовано';

  @override
  String get thisEventHasnTBeenPublishedYet => 'Подію ще не опубліковано';

  @override
  String get eventCompleted => 'Подія завершена';

  @override
  String get participationUnavailable => 'Участь недоступна';

  @override
  String get noPlacesLeft => 'Усі місця зайняті';

  @override
  String get youCanCheckForPlacesLater =>
      'Можеш перевірити наявність місць пізніше';

  @override
  String get joinEvent => 'Долучитися';

  @override
  String get bePartOfAGoodCause => 'Долучайся до спільної справи';

  @override
  String placesAvailable(String arg0) {
    return 'Вільних місць: $arg0';
  }

  @override
  String get all => 'Усі';

  @override
  String get eventLocation => 'Місце події';

  @override
  String get myLocation => 'Моя позиція';

  @override
  String get noPinSelectedYet => 'Точку ще не обрано';

  @override
  String get useThisLocation => 'Використати місце';

  @override
  String get events => 'Події';

  @override
  String get refresh => 'Оновити';

  @override
  String get filters => 'Фільтри •';

  @override
  String get filters197 => 'Фільтри';

  @override
  String get noEventsNearbyYet => 'Поки немає подій поруч';

  @override
  String get createAnEventAndInvitePeopleToJoin =>
      'Створи подію та запроси людей долучитися.';

  @override
  String get tryBrowsingAllCategories => 'Спробуй переглянути всі категорії.';

  @override
  String get createEvent => 'Створити подію';

  @override
  String get resetFilters => 'Скинути фільтри';

  @override
  String get locationServicesAreOffShowingEventsWithoutADistanceLimit =>
      'Геолокація вимкнена. Показуємо події без обмеження відстані.';

  @override
  String get allowLocationAccessToDiscoverNearbyEvents =>
      'Дозволь геолокацію, щоб бачити події поруч.';

  @override
  String get youCanEnableLocationAccessInYourDeviceSettings =>
      'Доступ до геолокації можна увімкнути в налаштуваннях пристрою.';

  @override
  String get couldNotDetermineYourLocationShowingAvailableEvents =>
      'Не вдалося визначити позицію. Показуємо доступні події.';

  @override
  String get thisEventIsNoLongerOpenToJoin207 =>
      'Участь у цій події вже недоступна.';

  @override
  String get thereAreNoPlacesLeft => 'Усі місця вже зайняті.';

  @override
  String get jan => 'СІЧ';

  @override
  String get feb => 'ЛЮТ';

  @override
  String get mar => 'БЕР';

  @override
  String get apr => 'КВІ';

  @override
  String get may => 'ТРА';

  @override
  String get jun => 'ЧЕР';

  @override
  String get jul => 'ЛИП';

  @override
  String get aug => 'СЕР';

  @override
  String get sep => 'ВЕР';

  @override
  String get oct => 'ЖОВ';

  @override
  String get nov => 'ЛИС';

  @override
  String get dec => 'ГРУ';

  @override
  String get participants221 => 'учасників';

  @override
  String get participant222 => 'учасник';

  @override
  String get participants223 => 'учасники';

  @override
  String get pastEvent => 'Подія минула';

  @override
  String get openToEveryone => 'Відкрита участь';

  @override
  String placesLeft(String arg0) {
    return 'Залишилось місць: $arg0';
  }

  @override
  String get view => 'Переглянути';

  @override
  String viewEvent(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
    String arg4,
    String arg5,
  ) {
    return '$arg0. $arg1. $arg2. $arg3. $arg4. $arg5. Переглянути подію.';
  }

  @override
  String m(String arg0) {
    return '$arg0 м';
  }

  @override
  String km(String arg0) {
    return '$arg0 км';
  }

  @override
  String get theParticipantLimitMustBeGreaterThanZero =>
      'Кількість учасників має бути більшою за нуль.';

  @override
  String couldNotUpdateTheChatAvatar(String arg0) {
    return 'Не вдалося оновити аватар чату: $arg0';
  }

  @override
  String get enterTheFullImageUrl => 'Встав повне посилання на зображення';

  @override
  String get theUrlMustStartWithHttpsOrHttp =>
      'Посилання має починатися з https:// або http://';

  @override
  String get useADirectLinkToAnImageFile =>
      'Це має бути пряме посилання на файл картинки';

  @override
  String get chatAvatar => 'Аватар чату';

  @override
  String get avatarUrl => 'Посилання на аватарку';

  @override
  String get directUrlHttpsSiteComAvatarPng =>
      'Прямий URL: https://site.com/avatar.png';

  @override
  String get saving239 => 'Збереження...';

  @override
  String get save => 'Зберегти';

  @override
  String get removeAvatar => 'Очистити аватар';

  @override
  String get addStreamApiKeyToMobileEnvAndFullyRestart =>
      'Додай STREAM_API_KEY у mobile/.env і повністю перезапусти Flutter.';

  @override
  String get theEventHasEndedItsChatIsNoLongerAvailable =>
      'Подія завершена. Чат більше недоступний.';

  @override
  String get streamChatIsNotConfiguredYet => 'Stream Chat ще не налаштовано.';

  @override
  String get chats => 'Чати';

  @override
  String connectedAsOnlyChatsForYourEventsAppearHere(String arg0) {
    return 'Підключено як $arg0. Тут показані тільки чати твоїх подій.';
  }

  @override
  String get couldNotLoadChats => 'Не вдалося завантажити чати';

  @override
  String get yourConversationsStartHere => 'Твої розмови почнуться тут';

  @override
  String get joinAnEventToChatWithItsParticipants =>
      'Долучися до події, щоб спілкуватися з її учасниками.';

  @override
  String get findEvents => 'Знайти події';

  @override
  String participants251(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1 · $arg2 учасн.';
  }

  @override
  String get chatAvatarUpdated => 'Аватар чату оновлено';

  @override
  String get thisEventSChatIsNoLongerAvailable =>
      'Чат цієї події більше недоступний.';

  @override
  String get removeParticipant => 'Викинути учасника?';

  @override
  String willLoseAccessToTheEventAndItsChat(String arg0) {
    return '$arg0 втратить доступ до події та її чату.';
  }

  @override
  String get remove => 'Викинути';

  @override
  String get participantRemovedFromTheEventAndChat =>
      'Учасника видалено з події та чату';

  @override
  String get chatMembers => 'Учасники чату';

  @override
  String get noParticipantsYet259 => 'Учасників ще немає';

  @override
  String get user260 => 'Користувач';

  @override
  String get profileUpdated => 'Профіль оновлено';

  @override
  String get profile => 'Профіль';

  @override
  String get edit => 'Редагувати';

  @override
  String get myActivity => 'Моя активність';

  @override
  String get reportsAndStatistics => 'Звіти та статистика';

  @override
  String get myContributionParticipationAndPdfReport =>
      'Мій внесок, участь і PDF-звіт';

  @override
  String get settings => 'Налаштування';

  @override
  String get darkTheme => 'Темна тема';

  @override
  String get couldNotLoadYourEvents => 'Не вдалося завантажити твої події';

  @override
  String get eventsICreated => 'Мої створені події';

  @override
  String get youHavenTCreatedAnyEventsYet271 => 'Ти ще не створював подій';

  @override
  String get eventsIJoined => 'Я учасник';

  @override
  String get youHavenTJoinedAnyEventsYet273 => 'Ти ще не долучався до подій';

  @override
  String get holdToSignOut => 'Затисни, щоб вийти';

  @override
  String get keepHoldingToSignOut => 'Тримай, щоб вийти';

  @override
  String get bringPeopleTogetherAroundYourIdea =>
      'Об’єднай людей навколо своєї ідеї.';

  @override
  String get chooseAnEventAndJoinItWillAppearHere =>
      'Обери подію та долучися — вона з’явиться тут.';

  @override
  String couldNotUpdateYourProfile(String arg0) {
    return 'Не вдалося оновити профіль: $arg0';
  }

  @override
  String get editProfile => 'Редагувати профіль';

  @override
  String get initiativesMap => 'Мапа ініціатив';

  @override
  String get createAnInitiativeAndInvitePeople =>
      'Створи ініціативу та запроси людей.';

  @override
  String get tryAnotherCategoryOrBrowseAllEvents =>
      'Спробуй іншу категорію або переглянь усі події.';

  @override
  String get changeFilters => 'Змінити фільтри';

  @override
  String events284(String arg0) {
    return 'Подій: $arg0';
  }

  @override
  String get distanceUnavailable => 'Відстань недоступна';

  @override
  String mAway(String arg0) {
    return '$arg0 м від тебе';
  }

  @override
  String kmAway(String arg0) {
    return '$arg0 км від тебе';
  }

  @override
  String get closeCard => 'Закрити картку';

  @override
  String get viewEvent289 => 'Переглянути подію';

  @override
  String get eventFilters => 'Фільтри подій';

  @override
  String get closeFilters => 'Закрити фільтри';

  @override
  String get categoriesSelectMoreThanOne => 'Категорії · можна обрати декілька';

  @override
  String get allCategories => 'Усі категорії';

  @override
  String get eventStartDate => 'Дата початку події';

  @override
  String get anyDate => 'Будь-яка дата';

  @override
  String get clearDates => 'Прибрати дати';

  @override
  String radiusKm(String arg0) {
    return 'Радіус: $arg0 км';
  }

  @override
  String get fromYourSelectedCityOrCurrentLocation =>
      'Від вибраного міста або твоєї геолокації.';

  @override
  String get aRadiusRequiresYourLocationOrASelectedCityCurrently =>
      'Для радіуса потрібна геолокація або вибране місто. Зараз пошук без обмеження відстані.';

  @override
  String get showEvents => 'Показати події';

  @override
  String get resetAllFilters => 'Скинути всі фільтри';

  @override
  String get registration => 'Реєстрація';

  @override
  String get createAccount => 'Створити акаунт';

  @override
  String get signUpToCreateInitiativesAndJoinNearbyEvents =>
      'Зареєструйся, щоб створювати ініціативи та долучатися до подій поруч.';

  @override
  String get forExampleAnnaPetrenko => 'Наприклад, Анна Петренко';

  @override
  String get enterYourName => 'Введи імʼя';

  @override
  String get enterYourEmail => 'Введи пошту';

  @override
  String get password => 'Пароль';

  @override
  String get atLeastCharacters309 => 'Мінімум 6 символів';

  @override
  String get pleaseWait310 => 'Зачекай...';

  @override
  String get signUp => 'Зареєструватися';

  @override
  String get initiativesEventsAndPeopleNearby =>
      'Ініціативи, події та люди поруч';

  @override
  String get retryRestoringYourSession => 'Повторити відновлення входу';

  @override
  String get enterAValidEmail => 'Введи коректну пошту';

  @override
  String get enterYourPassword => 'Введи пароль';

  @override
  String get signIn => 'Увійти';

  @override
  String get forgotPassword => 'Забув пароль?';

  @override
  String get accountCreatedSignInWithYourEmailAndPassword =>
      'Акаунт створено. Тепер увійди зі своєю поштою та паролем.';

  @override
  String get passwordResetEmailSentCheckYourInboxAndSpamFolder =>
      'Лист для зміни пароля надіслано. Перевір пошту та папку Спам.';

  @override
  String get resetPassword => 'Відновлення пароля';

  @override
  String get enterYourAccountEmailToReceiveAPasswordResetLink =>
      'Введи пошту акаунта, і Firebase надішле лист для зміни пароля.';

  @override
  String get emailSentCheckYourSpamFolderOrResendWhenThe =>
      'Лист надіслано. Якщо його немає, перевір папку Спам або надішли повторно після таймера.';

  @override
  String get sending => 'Надсилання...';

  @override
  String resendInS(String arg0) {
    return 'Повторно через $arg0 с';
  }

  @override
  String get resendEmail => 'Надіслати повторно';

  @override
  String get sendEmail => 'Надіслати лист';

  @override
  String get couldNotSignIn => 'Не вдалося увійти.';

  @override
  String get couldNotCreateTheUser => 'Не вдалося створити користувача.';

  @override
  String get passwordResetIsOnlyAvailableThroughFirebaseAuth =>
      'Скидання пароля доступне тільки через Firebase Auth.';

  @override
  String get thisEmailIsAlreadyInUse => 'Ця пошта вже використовується.';

  @override
  String get invalidEmailAddress => 'Некоректна адреса пошти.';

  @override
  String get thePasswordIsTooWeak => 'Пароль занадто слабкий.';

  @override
  String get noUserFoundWithThisEmail =>
      'Користувача з такою поштою не знайдено.';

  @override
  String get incorrectEmailOrPassword => 'Невірна пошта або пароль.';

  @override
  String get noConnectionToFirebase => 'Немає зʼєднання з Firebase.';

  @override
  String get firebaseAuthError => 'Помилка Firebase Auth.';

  @override
  String get home => 'Головна';

  @override
  String get map => 'Мапа';

  @override
  String get create => 'Створити';

  @override
  String get lviv => 'Львів';

  @override
  String get kyiv => 'Київ';

  @override
  String get ivanoFrankivsk => 'Івано-Франківськ';

  @override
  String get ternopil => 'Тернопіль';

  @override
  String get odesa => 'Одеса';

  @override
  String get dnipro => 'Дніпро';

  @override
  String get kharkiv => 'Харків';

  @override
  String get whereShouldWeLook => 'Де шукаємо події?';

  @override
  String get showingEventsWithinTheSelectedSearchRadius =>
      'Показуємо події в межах вибраного радіуса пошуку.';

  @override
  String get nearMe => 'Поруч зі мною';

  @override
  String get usingYourDeviceSLocation => 'За геолокацією пристрою';

  @override
  String get myProfile => 'Мій профіль';

  @override
  String get me => 'Я';

  @override
  String get yourCityYourPeople => 'ТВОЄ МІСТО. ТВОЇ ЛЮДИ.';

  @override
  String get goodThingsNstartNearby => 'Добрі справи\nпочинаються поруч.';

  @override
  String get discoverEventsMeetPeopleNandMakeADifferenceInYour =>
      'Знаходь події, знайомся з людьми\nта змінюй своє місто.';

  @override
  String get findAnEventOrAGoodCause => 'Знайти подію або добру справу';

  @override
  String get clearSearch => 'Очистити пошук';

  @override
  String get whatMattersToYou => 'Що тобі близьке?';

  @override
  String get advancedFilters => 'Розширені фільтри';

  @override
  String get all360 => 'Усе';

  @override
  String get yourCalendarIsTemporarilyUnavailable =>
      'Твій календар поки недоступний';

  @override
  String get anIdeaForYourCommunity => 'Є ІДЕЯ ДЛЯ СПІЛЬНОТИ?';

  @override
  String get yourEventIsHappening => 'ТВОЯ ПОДІЯ ТРИВАЄ';

  @override
  String get yourEventIsToday => 'ТВОЯ ПОДІЯ СЬОГОДНІ';

  @override
  String get yourNextEvent => 'ТВОЯ НАСТУПНА ПОДІЯ';

  @override
  String get bringPeopleTogetherNforAGoodCause =>
      'Об’єднай людей\nнавколо доброї справи.';

  @override
  String get createEvent367 => 'Створити подію →';

  @override
  String get couldNotLoadEvents => 'Не вдалося завантажити події';

  @override
  String get letSFindYourCity => 'Знайдемо твоє місто?';

  @override
  String get withoutLocationAccessWeShowEventsFromDifferentCities =>
      'Без геолокації показуємо доступні події з різних міст.';

  @override
  String get chooseACity => 'Обрати місто';

  @override
  String get noEventsMatchYourSearch => 'За цим запитом подій немає';

  @override
  String get itSQuietHereWantToStartSomething =>
      'Тут поки тихо. Почнемо з тебе?';

  @override
  String get tryDifferentWordsOrAnotherCategory =>
      'Спробуй інші слова або вибери іншу категорію.';

  @override
  String get createTheFirstInitiativeOrTryAnotherCity =>
      'Створи першу ініціативу або пошукай в іншому місті.';

  @override
  String get thisWeekend => 'Цими вихідними';

  @override
  String get searchResults => 'Результати пошуку';

  @override
  String get nearbyEvents => 'Події поруч';

  @override
  String get discoverSomethingNew => 'Відкривай нове';

  @override
  String get openMap => 'Відкрити мапу';

  @override
  String get loadingEvents => 'Завантаження подій';

  @override
  String get loading => 'Завантаження';

  @override
  String get theServerDidNotRespondInTimeTryAgain =>
      'Сервер не відповів вчасно. Спробуй ще раз.';

  @override
  String get noConnectionToTheServerCheckYourInternetAndTry =>
      'Немає з’єднання із сервером. Перевір інтернет і спробуй ще раз.';

  @override
  String get yourSessionHasExpiredSignInAgain =>
      'Сесія завершилася. Увійди ще раз.';

  @override
  String get youDonTHavePermissionToDoThis => 'Недостатньо прав для цієї дії.';

  @override
  String get theServiceIsTemporarilyUnavailableTryAgainLater =>
      'Сервіс тимчасово недоступний. Спробуй пізніше.';

  @override
  String get couldNotCompleteTheRequest => 'Не вдалося виконати запит.';

  @override
  String get theServerReturnedInvalidData => 'Сервер повернув некоректні дані.';

  @override
  String get language => 'Мова';

  @override
  String get systemLanguage => 'Мова пристрою';

  @override
  String get draftServerUnavailable =>
      'Сервер ще не підтримує безпечне збереження чернеток. Подію не опубліковано. Спробуй після оновлення сервера.';

  @override
  String get bio => 'Про себе';

  @override
  String get eventNotFound => 'Подію не знайдено.';

  @override
  String get chatNotFound => 'Чат не знайдено.';

  @override
  String get userNotFound => 'Користувача не знайдено.';

  @override
  String get profileNotSynced =>
      'Не вдалося синхронізувати профіль. Спробуй увійти ще раз.';

  @override
  String get validationFailed => 'Перевір заповнені поля.';

  @override
  String get statusChangeUnavailable =>
      'Ця зміна статусу вже недоступна. Онови подію.';

  @override
  String get completeStartedOnly =>
      'Завершити можна лише подію, яка вже почалася.';

  @override
  String get startMustBeFuture => 'Новий час початку має бути в майбутньому.';

  @override
  String get endHasPassed => 'Час завершення вже минув.';

  @override
  String get publishFutureStart =>
      'Перед публікацією обери майбутній час початку.';

  @override
  String get startedTimeLocked =>
      'Не можна переносити початок події, яка вже почалася.';

  @override
  String get capacityBelowAttendance =>
      'Ліміт не може бути меншим за кількість учасників.';

  @override
  String get endedParticipationLocked =>
      'Участь у завершеній події не змінюється.';

  @override
  String get organizerCannotLeave =>
      'Організатор не може вийти зі своєї події.';

  @override
  String get organizerCannotBeRemoved =>
      'Організатора не можна видалити з події.';

  @override
  String get leaveInsteadOfRemove => 'Скористайся кнопкою виходу з події.';

  @override
  String get notEventMember => 'Користувач не є учасником цієї події.';

  @override
  String get chatUnavailable => 'Чат зараз недоступний. Спробуй пізніше.';
}
