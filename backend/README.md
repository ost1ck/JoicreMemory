# JoicreMemory Backend

Node.js Express REST API.

Planned structure:

```text
src/
  config/
  controllers/
  middlewares/
  repositories/
  routes/
  services/
  utils/
```

Authentication will use Firebase ID tokens verified on the backend.

## Firebase

Local verification can run with project id only:

```env
AUTH_DEV_MODE=false
FIREBASE_PROJECT_ID=joicrememory
```

For production, use Firebase Console:

```text
Project settings -> Service accounts -> Generate new private key
```

Save the JSON in `backend/` and set:

```env
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-admin-service-account.json
```

## Run

```bash
cp .env.example .env
npm install
npm start
```

Open Swagger:

```text
http://localhost:3000/docs
```

Protected Swagger endpoints require a real Firebase ID token when:

```env
AUTH_DEV_MODE=false
```

Development header auth still exists as a fallback only if you explicitly set:

```env
AUTH_DEV_MODE=true
```

### Завершення подій і очищення чатів

Після розгортання оновленого backend `eventLifecycleService` при старті й раз на 60 секунд завершує опубліковані події з `ends_at <= NOW()`. Також очищення запускається при запиті списку чатів. Чати завершених/скасованих подій видаляються зі Stream (разом з історією), після успіху видаляється `event_chat_channels`. Самі події та участь лишаються для профілю й звітів. Помилка Stream або відсутні credentials залишають запис для повторної спроби. API списку одразу виключає завершені чати, а приєднання не відновлює їх.

Без `ends_at` завершення за часом не визначається: організатор має встановити завершення або статус `completed`/`cancelled`. Коли хостинг присипляє процес, інтервальний обробник не працює; очищення наздожене пропущені завершення після пробудження. Для гарантованої роботи за розкладом потрібен постійно активний worker/сервер. Схема БД не змінена. Локальні зміни треба розгорнути на Render; перезапуск мобільного клієнта не оновлює сервер.

Регресійні тести без підключення до БД/Stream: `node --test test/eventLifecycle.test.js`.

### Розширені фільтри

`GET /api/events` підтримує `categories=cleanup,education` (будь-яка з вибраних категорій), `startsFrom` (включно) і `startsBefore` (не включно) у форматі UTC ISO 8601. Категорії, дати, пошук і географічний радіус комбінуються. `categories` має пріоритет над старим `category`. Діапазон дат фільтрує час початку події; мобільний клієнт передає початок наступного дня як верхню межу, щоб включити весь останній вибраний день. Радіус потребує latitude/longitude. Потрібен деплой оновленого API: старий сервер ігнорує невідомі параметри.

### Правила статусів

- `POST /api/events` приймає `status: draft | published` (за замовчуванням published). Чернетка потребує основних полів події й не створює чат.
- `GET /api/events` не повертає чернетки. `GET /api/events/:id` допускає читання чернетки лише автором із перевіреною авторизацією; чужий/анонімний запит отримує 404. Власник бачить їх у `/events/mine`.
- `PATCH /api/events/:id`: draft → published/cancelled, published → completed/cancelled. Повторне відкриття й редагування кінцевих статусів заборонені (409). Для публікації чернетки потрібен майбутній початок. Ручне завершення можливе після початку. Часткові правки перевіряються разом із збереженими датами й числом учасників.
- Приєднання/вихід не змінюють завершені події. Рядок події блокується транзакцією під час зміни статусу/участі, щоб паралельні запити не обходили перевірки. Синхронізація чату також бере блокування події.
- Автозавершення працює за ends_at; без нього організатор завершує вручну. Чернетки автоматично не завершуються. Історія подій і участі зберігається; чат кінцевих статусів очищується.

Потрібен деплой backend і оновлення мобільного клієнта. Міграція схеми не потрібна; не запускайте повторно destructive `database/schema.sql`. Перевірки: `node --test test/*.test.js` (політики, права, чернетки та очищення, зі заміненими зовнішніми сервісами).

### Безпечне збереження чернеток

Новий клієнт використовує `POST /api/events/drafts`: сервер примусово задає `draft` до валідації. Старий backend не має цього маршруту й повертає помилку замість випадкової публікації через ігнорування status. Чернетки залишаються приватними, потребують основних полів і не створюють чат. Після збереження з головної форми клієнт відкриває профіль.
