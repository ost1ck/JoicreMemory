import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_localizations/stream_chat_localizations.dart';

/// Stream's bundled translations omit Ukrainian. Supply it alongside English.
class AppChatLocalizationsDelegate
    extends LocalizationsDelegate<StreamChatLocalizations> {
  const AppChatLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['uk', 'en'].contains(locale.languageCode);
  @override
  Future<StreamChatLocalizations> load(Locale locale) => SynchronousFuture(
    locale.languageCode == 'uk'
        ? const UkrainianChatLocalizations()
        : const StreamChatLocalizationsEn(),
  );
  @override
  bool shouldReload(AppChatLocalizationsDelegate old) => false;
}

class UkrainianChatLocalizations extends StreamChatLocalizationsEn {
  const UkrainianChatLocalizations() : super(localeName: 'uk');
  @override
  String get launchUrlError => "Не вдалося відкрити посилання";
  @override
  String get loadingUsersError => "Не вдалося завантажити користувачів";
  @override
  String get noUsersLabel => "Користувачів поки немає";
  @override
  String get noPhotoOrVideoLabel => "Фото й відео поки немає";
  @override
  String get retryLabel => "Повторити";
  @override
  String get userLastOnlineText => "Востаннє в мережі";
  @override
  String get userOnlineText => "У мережі";
  @override
  String get threadReplyLabel => "Відповідь у гілці";
  @override
  String get onlyVisibleToYouText => "Видно лише тобі";
  @override
  String get sendMessagePermissionError =>
      "Ти не маєш права надсилати повідомлення";
  @override
  String get emptyMessagesText => "Повідомлень поки немає";
  @override
  String get genericErrorText => "Щось пішло не так";
  @override
  String get loadingMessagesError => "Не вдалося завантажити повідомлення";
  @override
  String get messageDeletedText => "Це повідомлення видалено.";
  @override
  String get messageDeletedLabel => "Повідомлення видалено";
  @override
  String get systemMessageLabel => "Системне повідомлення";
  @override
  String get editedMessageLabel => "Змінено";
  @override
  String get messageReactionsLabel => "Реакції на повідомлення";
  @override
  String get emptyChatMessagesText => "Чатів поки немає…";
  @override
  String get connectedLabel => "Підключено";
  @override
  String get disconnectedLabel => "Немає з’єднання";
  @override
  String get reconnectingLabel => "Відновлюємо з’єднання…";
  @override
  String get alsoSendAsDirectMessageLabel =>
      "Також надіслати особистим повідомленням";
  @override
  String get addACommentOrSendLabel => "Додай коментар або надішли";
  @override
  String get searchGifLabel => "Пошук GIF";
  @override
  String get writeAMessageLabel => "Напиши повідомлення";
  @override
  String get instantCommandsLabel => "Швидкі команди";
  @override
  String get couldNotReadBytesFromFileError => "Не вдалося прочитати файл.";
  @override
  String get addAFileLabel => "Додати файл";
  @override
  String get photoFromCameraLabel => "Зробити фото";
  @override
  String get uploadAFileLabel => "Завантажити файл";
  @override
  String get uploadAPhotoLabel => "Завантажити фото";
  @override
  String get uploadAVideoLabel => "Завантажити відео";
  @override
  String get videoFromCameraLabel => "Записати відео";
  @override
  String get okLabel => "Гаразд";
  @override
  String get somethingWentWrongError => "Щось пішло не так";
  @override
  String get addMoreFilesLabel => "Додати ще файли";
  @override
  String get enablePhotoAndVideoAccessMessage =>
      "Дозволь доступ до фото й відео, щоб ділитися ними.";
  @override
  String get allowGalleryAccessMessage => "Дозволити доступ до галереї";
  @override
  String get flagMessageLabel => "Поскаржитися на повідомлення";
  @override
  String get flagMessageQuestion =>
      "Надіслати копію повідомлення модератору для перевірки?";
  @override
  String get flagLabel => "ПОСКАРЖИТИСЯ";
  @override
  String get cancelLabel => "СКАСУВАТИ";
  @override
  String get flagMessageSuccessfulLabel => "Скаргу надіслано";
  @override
  String get flagMessageSuccessfulText => "Повідомлення надіслано модератору.";
  @override
  String get deleteLabel => "ВИДАЛИТИ";
  @override
  String get deleteMessageLabel => "Видалити повідомлення";
  @override
  String get deleteMessageQuestion => "Назавжди видалити це повідомлення?";
  @override
  String get operationCouldNotBeCompletedText => "Не вдалося виконати дію.";
  @override
  String get replyLabel => "Відповісти";
  @override
  String get copyMessageLabel => "Скопіювати повідомлення";
  @override
  String get editMessageLabel => "Редагувати повідомлення";
  @override
  String get photosLabel => "Фото";
  @override
  String get todayLabel => "Сьогодні";
  @override
  String get yesterdayLabel => "Учора";
  @override
  String get channelIsMutedText => "Сповіщення чату вимкнено";
  @override
  String get noTitleText => "Без назви";
  @override
  String get letsStartChattingLabel => "Почнімо спілкування!";
  @override
  String get sendingFirstMessageLabel =>
      "Надішли перше повідомлення учасникам.";
  @override
  String get startAChatLabel => "Почати чат";
  @override
  String get loadingChannelsError => "Не вдалося завантажити чати";
  @override
  String get deleteConversationLabel => "Видалити розмову";
  @override
  String get deleteConversationQuestion => "Видалити цю розмову?";
  @override
  String get streamChatLabel => "Чат";
  @override
  String get searchingForNetworkText => "Шукаємо мережу";
  @override
  String get offlineLabel => "Поза мережею…";
  @override
  String get tryAgainLabel => "Спробувати ще раз";
  @override
  String get viewInfoLabel => "Переглянути інформацію";
  @override
  String get leaveGroupLabel => "Вийти з групи";
  @override
  String get leaveLabel => "ВИЙТИ";
  @override
  String get leaveConversationLabel => "Вийти з розмови";
  @override
  String get leaveConversationQuestion => "Вийти з цієї розмови?";
  @override
  String get showInChatLabel => "Показати в чаті";
  @override
  String get saveImageLabel => "Зберегти зображення";
  @override
  String get saveVideoLabel => "Зберегти відео";
  @override
  String get uploadErrorLabel => "ПОМИЛКА ЗАВАНТАЖЕННЯ";
  @override
  String get giphyLabel => "Giphy";
  @override
  String get shuffleLabel => "Інший варіант";
  @override
  String get sendLabel => "Надіслати";
  @override
  String get withText => "з";
  @override
  String get inText => "у";
  @override
  String get youText => "Ти";
  @override
  String get fileText => "Файл";
  @override
  String get replyToMessageLabel => "Відповісти на повідомлення";
  @override
  String get slowModeOnLabel => "Повільний режим увімкнено";
  @override
  String get downloadLabel => "Завантажити";
  @override
  String get linkDisabledDetails =>
      "У цій розмові не можна надсилати посилання.";
  @override
  String get linkDisabledError => "Посилання вимкнено";
  @override
  String get viewLibrary => "Переглянути бібліотеку";
  @override
  String get enableFileAccessMessage =>
      "Дозволь доступ до файлів, щоб ділитися ними.";
  @override
  String get allowFileAccessMessage => "Дозволити доступ до файлів";
  @override
  String get markAsUnreadLabel => "Позначити непрочитаним";
  @override
  String get markUnreadError =>
      "Можна позначити непрочитаними лише останні 100 повідомлень чату.";
  @override
  String get questionsLabel => "Запитання";
  @override
  String get askAQuestionLabel => "Поставити запитання";
  @override
  String get pollOptionEmptyError => "Варіант не може бути порожнім";
  @override
  String get pollOptionDuplicateError => "Такий варіант уже є";
  @override
  String get addAnOptionLabel => "Додати варіант";
  @override
  String get multipleAnswersLabel => "Кілька відповідей";
  @override
  String get maximumVotesPerPersonLabel => "Максимум голосів від учасника";
  @override
  String get anonymousPollLabel => "Анонімне опитування";
  @override
  String get pollOptionsLabel => "Варіанти відповіді";
  @override
  String get suggestAnOptionLabel => "Запропонувати варіант";
  @override
  String get enterANewOptionLabel => "Введи новий варіант";
  @override
  String get addACommentLabel => "Додати коментар";
  @override
  String get pollCommentsLabel => "Коментарі до опитування";
  @override
  String get updateYourCommentLabel => "Оновити коментар";
  @override
  String get enterYourCommentLabel => "Введи коментар";
  @override
  String get endVoteConfirmationText => "Завершити голосування?";
  @override
  String get deletePollOptionLabel => "Видалити варіант";
  @override
  String get deletePollOptionQuestion => "Видалити цей варіант?";
  @override
  String get createLabel => "Створити";
  @override
  String get endLabel => "Завершити";
  @override
  String get viewCommentsLabel => "Переглянути коментарі";
  @override
  String get viewResultsLabel => "Переглянути результати";
  @override
  String get endVoteLabel => "Завершити голосування";
  @override
  String get pollResultsLabel => "Результати опитування";
  @override
  String get noPollVotesLabel => "Голосів поки немає";
  @override
  String get loadingPollVotesError => "Не вдалося завантажити голоси";
  @override
  String get repliedToLabel => "у відповідь на:";
  @override
  String get slideToCancelLabel => "Проведи, щоб скасувати";
  @override
  String get holdToRecordLabel =>
      "Утримуй для запису, відпусти для надсилання.";
  @override
  String get sendAnywayLabel => "Усе одно надіслати";
  @override
  String get moderatedMessageBlockedText =>
      "Повідомлення заблоковано правилами модерації";
  @override
  String get moderationReviewModalTitle => "Ти впевнений?";
  @override
  String get moderationReviewModalDescription =>
      "Подумай, як твій коментар вплине на інших, і дотримуйся правил спільноти.";
  @override
  String get voiceRecordingText => "Голосове повідомлення";
  @override
  String get audioAttachmentText => "Аудіо";
  @override
  String get imageAttachmentText => "Зображення";
  @override
  String get videoAttachmentText => "Відео";
  @override
  String get pollYouVotedText => "Ти проголосував";
  @override
  String get pollYouCreatedText => "Ти створив";
  @override
  String get draftLabel => "Чернетка";
  @override
  String userTypingText(Iterable<User> users) =>
      users.isEmpty
          ? ''
          : users.length == 1
          ? '${users.first.name} пише'
          : '${users.first.name} та ще ${users.length - 1} пишуть';
  @override
  String threadReplyCountText(int count) => 'Відповідей у гілці: $count';
  @override
  String attachmentsUploadProgressText({
    required int remaining,
    required int total,
  }) => 'Завантаження $remaining/$total…';
  @override
  String pinnedByUserText({
    required User pinnedBy,
    required User currentUser,
  }) =>
      pinnedBy.id == currentUser.id
          ? 'Закріплено тобою'
          : 'Закріплено: ${pinnedBy.name}';
  @override
  String resultCountText(int count) => 'Результатів: $count';
  @override
  String threadSeparatorText(int replyCount) => 'Відповідей: $replyCount';
  @override
  String fileTooLargeAfterCompressionError(double limitInMB) =>
      'Файл завеликий навіть після стиснення. Ліміт: $limitInMB МБ.';
  @override
  String fileTooLargeError(double limitInMB) =>
      'Файл завеликий. Ліміт: $limitInMB МБ.';
  @override
  String togglePinUnpinText({required bool pinned}) =>
      pinned ? 'Відкріпити' : 'Закріпити';
  @override
  String toggleDeleteRetryDeleteMessageText({required bool isDeleteFailed}) =>
      isDeleteFailed ? 'Повторити видалення' : 'Видалити повідомлення';
  @override
  String toggleResendOrResendEditedMessage({required bool isUpdateFailed}) =>
      isUpdateFailed
          ? 'Повторно надіслати змінене повідомлення'
          : 'Надіслати повторно';
  @override
  String sentAtText({required DateTime date, required DateTime time}) =>
      'Надіслано ${DateFormat.yMMMd('uk').format(date.toLocal())} о ${DateFormat.Hm('uk').format(time.toLocal())}';
  @override
  String membersCountText(int count) => 'Учасників: $count';
  @override
  String watchersCountText(int count) => 'У мережі: $count';
  @override
  String galleryPaginationText({
    required int currentPage,
    required int totalPages,
  }) => '${currentPage + 1} із $totalPages';
  @override
  String attachmentLimitExceedError(int limit) =>
      'Перевищено ліміт вкладень: $limit';
  @override
  String toggleMuteUnmuteUserText({required bool isMuted}) =>
      isMuted
          ? 'Увімкнути сповіщення користувача'
          : 'Вимкнути сповіщення користувача';
  @override
  String toggleMuteUnmuteGroupText({required bool isMuted}) =>
      isMuted ? 'Увімкнути сповіщення групи' : 'Вимкнути сповіщення групи';
  @override
  String toggleMuteUnmuteGroupQuestion({required bool isMuted}) =>
      isMuted
          ? 'Увімкнути сповіщення цієї групи?'
          : 'Вимкнути сповіщення цієї групи?';
  @override
  String toggleMuteUnmuteUserQuestion({required bool isMuted}) =>
      isMuted
          ? 'Увімкнути сповіщення цього користувача?'
          : 'Вимкнути сповіщення цього користувача?';
  @override
  String toggleMuteUnmuteAction({required bool isMuted}) =>
      isMuted ? 'УВІМКНУТИ' : 'ВИМКНУТИ';
  @override
  String unreadMessagesSeparatorText() => 'Нові повідомлення';
  @override
  String unreadCountIndicatorLabel({required int unreadCount}) =>
      'Непрочитаних: $unreadCount';
  @override
  String createPollLabel({bool isNew = false}) =>
      isNew ? 'Створити нове опитування' : 'Створити опитування';
  @override
  String? pollQuestionValidationError(int length, Range<int> range) {
    if (range.min != null && length < range.min!) {
      return 'Мінімум ${range.min} символів';
    }
    if (range.max != null && length > range.max!) {
      return 'Максимум ${range.max} символів';
    }
    return null;
  }

  @override
  String optionLabel({bool isPlural = false}) =>
      isPlural ? 'Варіанти' : 'Варіант';
  @override
  String? maxVotesPerPersonValidationError(int votes, Range<int> range) {
    if (range.min != null && votes < range.min!) {
      return 'Мінімум голосів: ${range.min}';
    }
    if (range.max != null && votes > range.max!) {
      return 'Максимум голосів: ${range.max}';
    }
    return null;
  }

  @override
  String pollVotingModeLabel(PollVotingMode votingMode) => votingMode.when(
    disabled: () => 'Голосування завершено',
    unique: () => 'Обери один варіант',
    limited: (count) => 'Обери до $count варіантів',
    all: () => 'Обери один або кілька варіантів',
  );
  @override
  String seeAllOptionsLabel({int? count}) =>
      count == null ? 'Усі варіанти' : 'Усі варіанти ($count)';
  @override
  String showAllVotesLabel({int? count}) =>
      count == null ? 'Усі голоси' : 'Усі голоси ($count)';
  @override
  String voteCountLabel({int? count}) => 'Голосів: ${count ?? 0}';
  @override
  String newThreadsLabel({required int count}) => 'Нових гілок: $count';
  @override
  String pollSomeoneVotedText(String username) => 'Проголосував: $username';
  @override
  String pollSomeoneCreatedText(String username) => 'Створив: $username';
}
