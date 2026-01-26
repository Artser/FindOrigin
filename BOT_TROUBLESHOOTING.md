# Устранение неполадок Telegram-бота

## Быстрая диагностика

Запустите скрипт проверки:

```powershell
.\CHECK_BOT_SETUP.ps1
```

## Основные проблемы и решения

### 1. Бот не отвечает на сообщения

#### Проверка 1: Сервер запущен?

```powershell
# Проверьте, запущен ли сервер
npm run dev
```

Сервер должен быть доступен на `http://localhost:3000`

#### Проверка 2: Webhook настроен?

**Для локальной разработки (через ngrok):**

1. Установите ngrok: https://ngrok.com/download
2. Запустите ngrok:
   ```powershell
   ngrok http 3000
   ```
3. Скопируйте URL (например: `https://abc123.ngrok.io`)
4. Установите webhook:
   ```
   https://abc123.ngrok.io/api/set-webhook
   ```
   Или через браузер:
   ```
   http://localhost:3000/api/set-webhook?url=https://abc123.ngrok.io/api/webhook
   ```

**Для продакшена (Vercel):**

1. Деплойте проект на Vercel
2. Установите webhook:
   ```
   https://ваш-домен.vercel.app/api/set-webhook?url=https://ваш-домен.vercel.app/api/webhook
   ```

#### Проверка 3: Переменные окружения

Убедитесь, что в `.env.local` установлены:

```env
# Обязательно
TELEGRAM_BOT_TOKEN=ваш_токен_от_BotFather
OPENAI_API_KEY=sk-ваш_ключ_openai

# Хотя бы один поисковый API
GOOGLE_SEARCH_API_KEY=ваш_ключ
GOOGLE_SEARCH_ENGINE_ID=ваш_id

# Или
YANDEX_CLOUD_API_KEY=AQVN...
YANDEX_FOLDER_ID=b1g...
YANDEX_AUTH_TYPE=Api-Key

# Или
BING_SEARCH_API_KEY=ваш_ключ

# Или
SERPAPI_KEY=ваш_ключ
```

**ВАЖНО:** После изменения `.env.local` перезапустите сервер!

#### Проверка 4: Логи сервера

Проверьте консоль, где запущен `npm run dev`. Там должны быть логи:
- Ошибки при обработке запросов
- Ошибки при вызове API
- Ошибки при отправке сообщений

### 2. Ошибка "OPENAI_API_KEY не установлен"

**Решение:**
1. Откройте `.env.local`
2. Убедитесь, что строка не закомментирована (нет `#` в начале)
3. Убедитесь, что ключ правильный (начинается с `sk-`)
4. Перезапустите сервер

### 3. Ошибка "Не настроен ни один поисковый API"

**Решение:**
Настройте хотя бы один поисковый API:

**Вариант A: Google Custom Search**
```env
GOOGLE_SEARCH_API_KEY=AIza...
GOOGLE_SEARCH_ENGINE_ID=c38...
```

**Вариант B: Yandex GPT (рекомендуется для России)**
```env
YANDEX_CLOUD_API_KEY=AQVN...
YANDEX_FOLDER_ID=b1g...
YANDEX_AUTH_TYPE=Api-Key
```

**Вариант C: Bing Search**
```env
BING_SEARCH_API_KEY=ваш_ключ
```

**Вариант D: SerpAPI**
```env
SERPAPI_KEY=ваш_ключ
```

### 4. Бот отвечает, но не находит источники

**Возможные причины:**
1. Поисковый API не работает (проверьте ключи)
2. Превышен лимит запросов
3. Проблемы с биллингом

**Решение:**
- Проверьте логи сервера на наличие ошибок API
- Проверьте статус биллинга в Google Cloud / Azure / Yandex Cloud
- Попробуйте другой поисковый API

### 5. AI-анализ не выполняется

**Причины:**
1. `OPENAI_API_KEY` не установлен
2. Неправильный ключ OpenAI
3. Превышен лимит запросов OpenAI

**Решение:**
- Проверьте наличие `OPENAI_API_KEY` в `.env.local`
- Проверьте правильность ключа на https://platform.openai.com/api-keys
- Проверьте баланс на OpenAI аккаунте

### 6. Webhook не работает (403, 401)

**Причины:**
1. Неправильный URL webhook
2. Секретный токен не совпадает
3. Telegram не может достучаться до вашего сервера

**Решение:**
- Для локальной разработки используйте ngrok
- Убедитесь, что URL доступен из интернета
- Проверьте, что `TELEGRAM_WEBHOOK_SECRET` совпадает (если используется)

### 7. Бот отвечает ошибками

**Проверьте логи сервера:**
- Откройте консоль, где запущен `npm run dev`
- Найдите ошибки (они будут красным цветом)
- Скопируйте текст ошибки

**Типичные ошибки:**
- `API key не установлен` → Проверьте переменные окружения
- `403 Forbidden` → Проверьте биллинг и права доступа
- `429 Rate limit` → Превышен лимит, подождите
- `401 Unauthorized` → Неправильный API ключ

## Пошаговая проверка

### Шаг 1: Проверка сервера

```powershell
# Запустите сервер
npm run dev

# В другом терминале проверьте
Invoke-WebRequest -Uri "http://localhost:3000/api/webhook" -Method GET
```

Должен вернуться JSON с `status: "ok"`

### Шаг 2: Проверка переменных окружения

```powershell
# Запустите скрипт проверки
.\CHECK_BOT_SETUP.ps1
```

### Шаг 3: Проверка webhook

```powershell
# Для локальной разработки через ngrok
# 1. Запустите ngrok
ngrok http 3000

# 2. Скопируйте URL (например: https://abc123.ngrok.io)

# 3. Установите webhook
Invoke-WebRequest -Uri "http://localhost:3000/api/set-webhook?url=https://abc123.ngrok.io/api/webhook"
```

### Шаг 4: Тест бота

1. Откройте Telegram
2. Найдите вашего бота
3. Отправьте команду `/start`
4. Бот должен ответить приветствием

### Шаг 5: Тест поиска

1. Отправьте боту любой текст
2. Бот должен начать обработку
3. Проверьте логи сервера на наличие ошибок

## Получение логов

### Локальная разработка

Логи отображаются в консоли, где запущен `npm run dev`

### Vercel

1. Откройте Vercel Dashboard
2. Выберите проект
3. Перейдите в раздел "Functions"
4. Выберите функцию `/api/webhook`
5. Просмотрите логи

## Полезные команды

```powershell
# Проверка статуса webhook (через Telegram Bot API)
$token = "ваш_токен"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"

# Удаление webhook
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook"

# Проверка работы бота
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
```

## Если ничего не помогает

1. Проверьте все логи (сервер, Vercel, Telegram)
2. Убедитесь, что все переменные окружения установлены
3. Перезапустите сервер
4. Переустановите webhook
5. Проверьте, что API ключи активны и имеют доступ

## Контакты для помощи

Если проблема не решается:
1. Скопируйте текст ошибки из логов
2. Проверьте, какие переменные окружения установлены (без значений)
3. Опишите, что именно не работает



