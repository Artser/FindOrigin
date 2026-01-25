# Быстрый старт FindOrigin Bot

## Шаг 1: Установка зависимостей

Если зависимости еще не установлены:

```powershell
npm install
```

## Шаг 2: Настройка переменных окружения

Файл `.env.local` уже создан на основе `env.example`. Теперь нужно заполнить его реальными значениями:

### 2.1 Получение токена Telegram бота

1. Откройте Telegram и найдите [@BotFather](https://t.me/BotFather)
2. Отправьте команду `/newbot`
3. Следуйте инструкциям:
   - Введите имя бота (например: "FindOrigin Bot")
   - Введите username бота (должен заканчиваться на `bot`, например: `findorigin_bot`)
4. Скопируйте полученный токен (выглядит как `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 2.2 Настройка поискового API

Выберите один из вариантов:

#### Вариант A: Google Custom Search API (рекомендуется)

1. Перейдите на [Google Cloud Console](https://console.cloud.google.com/)
2. Создайте новый проект или выберите существующий
3. Включите **Custom Search API**:
   - Перейдите в "APIs & Services" → "Library"
   - Найдите "Custom Search API" и нажмите "Enable"
4. Создайте API ключ:
   - Перейдите в "APIs & Services" → "Credentials"
   - Нажмите "Create Credentials" → "API Key"
   - Скопируйте ключ
5. Создайте поисковую систему:
   - Перейдите на [Google Custom Search](https://programmablesearchengine.google.com/)
   - Нажмите "Add" для создания новой поисковой системы
   - Укажите сайты для поиска (можно оставить "Search the entire web")
   - Скопируйте **Search engine ID** (выглядит как `012345678901234567890:abcdefghijk`)

#### Вариант B: SerpAPI

1. Зарегистрируйтесь на [SerpAPI](https://serpapi.com/)
2. Перейдите в Dashboard и скопируйте ваш API ключ

### 2.3 Заполнение .env.local

Откройте файл `.env.local` и замените значения:

```env
# Обязательные переменные
TELEGRAM_BOT_TOKEN=ваш_токен_от_BotFather
GOOGLE_SEARCH_API_KEY=ваш_google_api_ключ
GOOGLE_SEARCH_ENGINE_ID=ваш_search_engine_id

# Или вместо Google используйте SerpAPI
# SERPAPI_KEY=ваш_serpapi_ключ

# Опциональные переменные
TELEGRAM_WEBHOOK_SECRET=ваш_секретный_ключ_для_webhook
AI_API_KEY=ваш_ai_api_ключ  # Пока не используется, для будущей реализации
```

**Минимально необходимые переменные:**
- `TELEGRAM_BOT_TOKEN` - обязательно
- `GOOGLE_SEARCH_API_KEY` и `GOOGLE_SEARCH_ENGINE_ID` - обязательно (или `SERPAPI_KEY`)

## Шаг 3: Запуск проекта

### Локальная разработка

```powershell
npm run dev
```

Приложение запустится на `http://localhost:3000`

Вы увидите сообщение:
```
▲ Next.js 16.x.x
- Local:        http://localhost:3000
```

### Проверка работоспособности

1. Откройте браузер и перейдите на `http://localhost:3000`
2. Вы должны увидеть страницу с текстом "FindOrigin Telegram Bot"
3. Проверьте webhook endpoint: `http://localhost:3000/api/webhook` (должен вернуть JSON с `status: "ok"`)

## Шаг 4: Настройка webhook для локальной разработки

Для локальной разработки можно использовать:

### Вариант A: ngrok (рекомендуется для тестирования)

1. Скачайте и установите [ngrok](https://ngrok.com/)
2. Запустите ngrok:
   ```powershell
   ngrok http 3000
   ```
3. Скопируйте HTTPS URL (например: `https://abc123.ngrok.io`)
4. Установите webhook:
   ```powershell
   $botToken = "ваш_токен_бота"
   $webhookUrl = "https://abc123.ngrok.io/api/webhook"
   Invoke-WebRequest -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=$webhookUrl" -Method GET
   ```

### Вариант B: Деплой на Vercel (для production)

1. Установите Vercel CLI:
   ```powershell
   npm install -g vercel
   ```

2. Задеплойте проект:
   ```powershell
   vercel
   ```

3. Настройте переменные окружения в [Vercel Dashboard](https://vercel.com/dashboard):
   - Выберите проект
   - Settings → Environment Variables
   - Добавьте все переменные из `.env.local`

4. Установите webhook:
   ```powershell
   $botToken = "ваш_токен_бота"
   $webhookUrl = "https://ваш-проект.vercel.app/api/webhook"
   Invoke-WebRequest -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=$webhookUrl" -Method GET
   ```

## Шаг 5: Тестирование бота

1. Найдите вашего бота в Telegram (по username, который вы указали при создании)
2. Отправьте команду `/start`
3. Отправьте текст или ссылку на Telegram-пост
4. Бот должен найти и вернуть возможные источники

## Полезные команды

```powershell
# Запуск в режиме разработки
npm run dev

# Сборка для production
npm run build

# Запуск production версии
npm start

# Проверка типов TypeScript
npx tsc --noEmit

# Проверка линтера
npm run lint
```

## Устранение проблем

### Ошибка: "TELEGRAM_BOT_TOKEN не установлен"
- Убедитесь, что файл `.env.local` существует и содержит правильный токен
- Перезапустите сервер разработки

### Ошибка: "Не настроен ни один поисковый API"
- Убедитесь, что заполнены либо `GOOGLE_SEARCH_API_KEY` и `GOOGLE_SEARCH_ENGINE_ID`, либо `SERPAPI_KEY`
- Проверьте правильность ключей

### Webhook не работает
- Убедитесь, что URL доступен из интернета (используйте ngrok для локальной разработки)
- Проверьте, что токен бота правильный
- Проверьте логи сервера на наличие ошибок

### Бот не отвечает
- Проверьте логи в консоли, где запущен `npm run dev`
- Убедитесь, что webhook установлен правильно
- Проверьте, что бот не заблокирован

## Следующие шаги

После успешного запуска можно перейти к реализации AI-анализа (Этап 5 из PLAN.md).


