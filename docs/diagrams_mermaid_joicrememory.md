# Mermaid діаграми для курсової JoicreMemory

Цей файл містить Mermaid-код для діаграм, які можна експортувати у PNG/SVG через Mermaid Live Editor або інший інструмент. Діаграми узгоджені з реальною структурою проєкту JoicreMemory: Flutter mobile app, Node.js/Express backend, PostgreSQL/PostGIS у Supabase, Firebase Auth, Stream Chat SDK, Google Maps.

Важливо: у проєкті немає таблиць `messages`, `reviews`, `categories`, `supervisors`, `projects`; повідомлення чатів зберігаються у Stream Chat, а PostgreSQL зберігає лише користувачів, події, участь і зв'язок події з каналом чату.

---

## Рис. 2.1 - Архітектура програмної системи JoicreMemory

```mermaid
flowchart LR
    User["Користувач / Організатор"]
    Mobile["Flutter mobile app\n(iOS / Android)"]
    API["Backend REST API\nNode.js + Express\nRender"]
    DB[("PostgreSQL + PostGIS\nSupabase")]
    Firebase["Firebase Auth\nemail/password, ID token"]
    Stream["Stream Chat SDK\nчати подій"]
    Maps["Google Maps API\nмапа і маркери"]
    PDF["PDF / Printing\nзвіт користувача"]

    User --> Mobile
    Mobile -->|"HTTPS JSON\nBearer Firebase ID token"| API
    Mobile -->|"реєстрація / вхід"| Firebase
    Mobile -->|"мапа, вибір локації"| Maps
    Mobile -->|"чат у реальному часі"| Stream
    Mobile --> PDF

    API -->|"перевірка ID token"| Firebase
    API -->|"SQL-запити"| DB
    API -->|"створення каналів,\nучасники, токени"| Stream

    DB -->|"users, events,\nevent_participants,\nevent_chat_channels"| API
    API -->|"профілі, події,\nзвіти, права доступу"| Mobile
```

---

## Рис. 4.1 - DFD-модель потоків даних

```mermaid
flowchart LR
    User["Користувач"]
    Organizer["Організатор"]
    App["Мобільний застосунок\nFlutter"]
    API["REST API\nNode.js / Express"]

    Firebase["Firebase Auth"]
    Maps["Google Maps API"]
    Stream["Stream Chat SDK"]

    D1[("D1 users")]
    D2[("D2 events")]
    D3[("D3 event_participants")]
    D4[("D4 event_chat_channels")]

    User -->|"email, пароль,\nпрофіль, запити"| App
    Organizer -->|"дані події,\nкерування учасниками"| App

    App -->|"реєстрація / вхід"| Firebase
    Firebase -->|"Firebase ID token"| App

    App -->|"захищені API-запити"| API
    API -->|"перевірка токена"| Firebase

    App -->|"координати,\nперегляд карти"| Maps
    Maps -->|"карта, геошари"| App

    API -->|"створення / оновлення профілю"| D1
    API -->|"створення, пошук,\nвидалення подій"| D2
    API -->|"долучення / вихід\nз події"| D3
    API -->|"зв'язок події\nз каналом Stream"| D4

    API -->|"створення каналу,\nдодавання учасників"| Stream
    Stream -->|"чат події,\nповідомлення"| App

    API -->|"список подій,\nзвіти, статистика"| App
```

---

## Рис. 4.2 - Контекстна діаграма IDEF0 A-0

Mermaid не є точною нотацією IDEF0, тому після вставки в Draw.io варто вручну трохи розставити стрілки, якщо потрібно. Логіка відповідає IDEF0: вхід зліва, керування зверху, механізми знизу, вихід справа.

```mermaid
flowchart LR
    I1["Запити користувачів:\nреєстрація, вхід,\nстворення події,\nдолучення до події"]
    A0["A-0\nJoicreMemory\nКерування локальними\nсоціальними ініціативами"]
    O1["Опубліковані події\nна мапі та у списку"]
    O2["Списки учасників\nі доступні чати подій"]
    O3["Персональні звіти\nта PDF для друку"]

    C1["Правила авторизації\nFirebase Auth"]
    C2["Обмеження БД:\nPK, FK, CHECK"]
    C3["Ролі користувачів:\nучасник / організатор"]
    C4["Ліміти учасників\nта правила доступу до чатів"]

    M1["Flutter mobile app"]
    M2["Node.js / Express API"]
    M3["PostgreSQL / PostGIS"]
    M4["Google Maps API\nStream Chat SDK"]

    I1 --> A0
    A0 --> O1
    A0 --> O2
    A0 --> O3

    C1 --> A0
    C2 --> A0
    C3 --> A0
    C4 --> A0

    M1 --> A0
    M2 --> A0
    M3 --> A0
    M4 --> A0
```

Якщо Mermaid у Draw.io розставить блоки неідеально, для звіту достатньо вручну перетягнути блоки так: `C1-C4` зверху, `I1` зліва, `O1-O3` справа, `M1-M4` знизу, `A-0` у центрі.

---

## Рис. 4.2 альтернативний варіант - декомпозиція A0

Цей варіант можна використати як додаткову діаграму, якщо потрібна не контекстна A-0, а декомпозиція процесу.

```mermaid
flowchart TB
    A0["A0\nКерування локальними\nсоціальними ініціативами"]
    A1["A1\nРеєстрація, авторизація\nта керування профілем"]
    A2["A2\nСтворення, пошук\nі перегляд подій"]
    A3["A3\nКерування участю\nу подіях"]
    A4["A4\nКомунікація\nу чатах подій"]
    A5["A5\nФормування звітів\nі PDF-друк"]

    A0 --> A1
    A0 --> A2
    A0 --> A3
    A0 --> A4
    A0 --> A5

    A1 --> A2
    A2 --> A3
    A3 --> A4
    A3 --> A5
```

---

## Рис. 4.3 - UML-діаграма прецедентів

У Mermaid немає повноцінної стандартної UML Use Case-нотації, тому нижче подано лише спрощену візуальну заміну. Для звіту краще використати готовий Draw.io-файл:

`docs/use_case_joicrememory.drawio`

```mermaid
flowchart LR
    User["Користувач"]
    Organizer["Організатор\n(користувач, який створив подію)"]
    Firebase["Firebase Auth"]
    Stream["Stream Chat SDK"]
    Maps["Google Maps API"]

    Login(["Зареєструватися / увійти"])
    Restore(["Відновити пароль"])
    Profile(["Редагувати профіль"])
    Map(["Переглянути мапу подій"])
    List(["Переглянути список подій"])
    Join(["Долучитися до події"])
    Leave(["Вийти з події"])
    Chat(["Спілкуватися в чаті події"])
    Report(["Сформувати PDF-звіт"])

    Create(["Створити подію"])
    PickLocation(["Обрати місце на мапі"])
    Delete(["Видалити свою подію"])
    ManageMembers(["Керувати учасниками"])
    ChatAvatar(["Змінити аватар чату"])

    User --> Login
    User --> Restore
    User --> Profile
    User --> Map
    User --> List
    User --> Join
    User --> Leave
    User --> Chat
    User --> Report
    User --> Create

    Organizer --> Delete
    Organizer --> ManageMembers
    Organizer --> ChatAvatar
    Organizer --> Create

    Login --> Firebase
    Restore --> Firebase
    Map --> Maps
    PickLocation --> Maps
    Chat --> Stream
    Create --> PickLocation
```

---

## Рис. 5.1 - Логічна модель бази даних

```mermaid
erDiagram
    USERS ||--o{ EVENTS : creates
    USERS ||--o{ EVENT_PARTICIPANTS : joins
    EVENTS ||--o{ EVENT_PARTICIPANTS : has
    EVENTS ||--|| EVENT_CHAT_CHANNELS : owns
    USERS ||--o{ EVENT_CHAT_CHANNELS : creates

    USERS {
        uuid id PK
        text firebase_uid UK
        citext email UK
        text full_name
        text avatar_url
        text bio
        text phone
        text stream_user_id UK
        timestamptz created_at
        timestamptz updated_at
    }

    EVENTS {
        uuid id PK
        uuid creator_user_id FK
        text title
        text description
        text category
        text status
        text location_name
        text address
        numeric latitude
        numeric longitude
        geography geo
        timestamptz starts_at
        timestamptz ends_at
        integer max_participants
        text image_url
        timestamptz created_at
        timestamptz updated_at
    }

    EVENT_PARTICIPANTS {
        uuid event_id PK,FK
        uuid user_id PK,FK
        text role
        text status
        timestamptz created_at
        timestamptz updated_at
    }

    EVENT_CHAT_CHANNELS {
        uuid id PK
        uuid event_id FK,UK
        text stream_channel_id UK
        text avatar_url
        uuid created_by_user_id FK
        timestamptz created_at
        timestamptz updated_at
    }
```

---

## Рис. 5.2 - Фізична модель бази даних PostgreSQL/PostGIS

```mermaid
erDiagram
    users ||--o{ events : "creator_user_id"
    users ||--o{ event_participants : "user_id"
    events ||--o{ event_participants : "event_id"
    events ||--|| event_chat_channels : "event_id"
    users ||--o{ event_chat_channels : "created_by_user_id"

    users {
        UUID id PK "DEFAULT gen_random_uuid()"
        TEXT firebase_uid UK "NOT NULL"
        CITEXT email UK "NOT NULL"
        TEXT full_name "NOT NULL, length 2..120"
        TEXT avatar_url
        TEXT bio "max 500"
        TEXT phone
        TEXT stream_user_id UK
        TIMESTAMPTZ created_at "DEFAULT now()"
        TIMESTAMPTZ updated_at "DEFAULT now()"
    }

    events {
        UUID id PK "DEFAULT gen_random_uuid()"
        UUID creator_user_id FK "ON DELETE CASCADE"
        TEXT title "NOT NULL, length 3..140"
        TEXT description "NOT NULL, length 10..5000"
        TEXT category "CHECK enum"
        TEXT status "draft/published/cancelled/completed"
        TEXT location_name "NOT NULL"
        TEXT address
        NUMERIC latitude "CHECK -90..90"
        NUMERIC longitude "CHECK -180..180"
        GEOGRAPHY geo "Point, 4326, generated"
        TIMESTAMPTZ starts_at "NOT NULL"
        TIMESTAMPTZ ends_at "nullable, >= starts_at"
        INTEGER max_participants "nullable, 1..10000"
        TEXT image_url
        TIMESTAMPTZ created_at "DEFAULT now()"
        TIMESTAMPTZ updated_at "DEFAULT now()"
    }

    event_participants {
        UUID event_id PK,FK "ON DELETE CASCADE"
        UUID user_id PK,FK "ON DELETE CASCADE"
        TEXT role "organizer/participant"
        TEXT status "joined/pending/cancelled"
        TIMESTAMPTZ created_at "DEFAULT now()"
        TIMESTAMPTZ updated_at "DEFAULT now()"
    }

    event_chat_channels {
        UUID id PK "DEFAULT gen_random_uuid()"
        UUID event_id FK,UK "ON DELETE CASCADE"
        TEXT stream_channel_id UK "NOT NULL"
        TEXT avatar_url "nullable, http/https"
        UUID created_by_user_id FK "ON DELETE CASCADE"
        TIMESTAMPTZ created_at "DEFAULT now()"
        TIMESTAMPTZ updated_at "DEFAULT now()"
    }
```
