# FindOrigin Telegram Bot

Telegram-бот для поиска источников информации. Получает текст или ссылку на пост и находит возможные источники этой информации.

## Технологии

- **Next.js** - React фреймворк
- **TypeScript** - Типизированный JavaScript
- **Vercel** - Платформа для деплоя
- **Telegram Bot API** - API для работы с Telegram ботами

## Установка и настройка

### 1. Установка зависимостей

```powershell
npm install
```

### 2. Настройка переменных окружения

Создайте файл `.env.local` на основе `.env.local.example`:

```powershell
Copy-Item .env.local.example .env.local
```
11
Заполните следующие переменные:

- `TELEGRAM_BOT_TOKEN` - Токен бота от [@BotFather](https://t.me/BotFather)
- `TELEGRAM_WEBHOOK_SECRET` - Секретный ключ для верификации webhook (опционально)
- `AI_API_KEY` - Ключ для AI API (пока не используется, для будущей реализации)
- `GOOGLE_SEARCH_API_KEY` и `GOOGLE_SEARCH_ENGINE_ID` - Для Google Custom Search API
- ИЛИ `SERPAPI_KEY` - Для SerpAPI

### 3. Получение API ключей

#### Telegram Bot Token
1. Откройте [@BotFather](https://t.me/BotFather) в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям и получите токен

#### Google Custom Search API
1. Перейдите на [Google Cloud Console](https://console.cloud.google.com/)
2. Создайте проект
3. Включите Custom Search API
4. Создайте API ключ
5. Создайте поисковую систему на [Google Custom Search](https://programmablesearchengine.google.com/)
6. Получите Engine ID

#### SerpAPI (альтернатива)
1. Зарегистрируйтесь на [SerpAPI](https://serpapi.com/)
2. Получите API ключ из dashboard

## Запуск

### Локальная разработка

```powershell
npm run dev
```

Приложение будет доступно по адресу `http://localhost:3000`

### Production сборка

```powershell
npm run build
npm start
```

## Деплой на Vercel

### 1. Установка Vercel CLI (если еще не установлен)

```powershell
npm install -g vercel
```

### 2. Деплой

```powershell
vercel
```

Следуйте инструкциям в терминале.

### 3. Настройка переменных окружения в Vercel

1. Перейдите в [Vercel Dashboard](https://vercel.com/dashboard)
2. Выберите ваш проект
3. Перейдите в Settings → Environment Variables
4. Добавьте все переменные из `.env.local`

### 4. Установка Webhook

После деплоя получите URL вашего приложения (например, `https://your-app.vercel.app`)

Установите webhook одним из способов:

#### Способ 1: Через API endpoint

```powershell
Invoke-WebRequest -Uri "https://your-app.vercel.app/api/set-webhook?url=https://your-app.vercel.app/api/webhook" -Method GET
```

#### Способ 2: Через Telegram API напрямую

```powershell
$botToken = "YOUR_BOT_TOKEN"
$webhookUrl = "https://your-app.vercel.app/api/webhook"
Invoke-WebRequest -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=$webhookUrl" -Method GET
```

## Использование

1. Найдите вашего бота в Telegram
2. Отправьте команду `/start`
3. Отправьте текст или ссылку на Telegram-пост
4. Бот найдет возможные источники информации

## API Endpoints

### POST /api/webhook
Webhook endpoint для получения обновлений от Telegram.

### GET /api/webhook
Проверка работоспособности endpoint.

### GET /api/set-webhook?url=<webhook_url>
Установка webhook URL для бота.

## Структура проекта

```
FindOrigin/
├── app/
│   ├── api/
│   │   ├── webhook/
│   │   │   └── route.ts      # Webhook обработчик
│   │   └── set-webhook/
│   │       └── route.ts      # Установка webhook
│   ├── layout.tsx            # Корневой layout
│   └── page.tsx              # Главная страница
├── lib/
│   ├── telegram.ts           # Утилиты для Telegram API
│   ├── textParser.ts         # Парсинг текста и ссылок
│   ├── keyElementsExtractor.ts # Извлечение ключевых элементов
│   ├── searchSources.ts      # Поиск источников
│   └── processRequest.ts     # Обработка запросов пользователя
├── .env.local.example        # Пример файла с переменными окружения
├── next.config.js            # Конфигурация Next.js
├── package.json              # Зависимости проекта
├── tsconfig.json             # Конфигурация TypeScript
└── vercel.json               # Конфигурация Vercel
```

## Текущий статус реализации

✅ **Реализовано:**
- Настройка проекта и инфраструктуры
- Webhook обработчик
- Парсинг текста и ссылок на Telegram-посты
- Извлечение ключевых элементов (даты, числа, имена, ссылки)
- Поиск источников через Google Custom Search или SerpAPI
- Фильтрация результатов по типам источников
- Извлечение текста со страниц источников

⏳ **В разработке:**
- AI-анализ и сравнение смысла текстов
- Оценка уверенности в найденных источниках
- Асинхронная обработка с очередями задач

## Примечания

- Бот возвращает 200 OK сразу после получения запроса, обработка происходит асинхронно
- Для извлечения текста из Telegram-постов используется парсинг HTML (может быть нестабильным)
- AI-анализ еще не реализован, показываются только найденные источники

## Лицензия

ISC


