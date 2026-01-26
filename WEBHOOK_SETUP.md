# Настройка Webhook для Telegram бота

## Важно

⚠️ **Webhook настраивается ПОСЛЕ первого деплоя** приложения в Vercel, когда у вас будет публичный URL.

**Порядок действий:**
1. Сначала разверните приложение в Vercel
2. Получите публичный URL вашего приложения
3. Затем настройте webhook, указав этот URL

## Варианты настройки webhook

### Вариант 1: Через API Route (рекомендуется)

После развертывания приложения откройте в браузере:

```
https://find-origin.vercel.app/api/setup-webhook
```

Или используйте PowerShell:

```powershell
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/setup-webhook" -Method GET
```

Этот endpoint автоматически:
- Использует токен из переменных окружения
- Устанавливает webhook на правильный URL
- Возвращает результат установки

### Вариант 2: Через скрипт (автоматический)

Запустите скрипт:

```powershell
.\setup-webhook-auto.ps1
```

Скрипт попробует использовать API endpoint, а если он недоступен - установит webhook напрямую через Telegram API.

### Вариант 3: Вручную через Telegram API

Выполните команду в PowerShell:

```powershell
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$webhookUrl = "https://find-origin.vercel.app/api/telegram"

Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$webhookUrl" -Method GET
```

### Вариант 4: Через существующий скрипт

```powershell
.\setup-webhook.ps1
```

## Переменные окружения

### Локально (`.env.local`)

```env
TELEGRAM_BOT_TOKEN=6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k
WEBHOOK_URL=https://find-origin.vercel.app/api/telegram
```

### На Vercel

1. Откройте [Vercel Dashboard](https://vercel.com/dashboard)
2. Выберите проект `find-origin`
3. Перейдите в **Settings → Environment Variables**
4. Добавьте переменные:
   - `TELEGRAM_BOT_TOKEN` = `6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k`
   - `WEBHOOK_URL` = `https://find-origin.vercel.app/api/telegram` (опционально)
5. **ОБЯЗАТЕЛЬНО переразверните проект** после добавления переменных

## Проверка webhook

После установки проверьте статус:

```powershell
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
$info.result
```

**Ожидаемый результат:**
- `url` должен быть `https://find-origin.vercel.app/api/telegram`
- `pending_update_count` должен быть 0
- `last_error_date` должен отсутствовать

## Endpoints

### Основной webhook endpoint
- **URL:** `https://find-origin.vercel.app/api/telegram`
- **Метод:** POST (для Telegram), GET (для проверки)

### Endpoint для совместимости
- **URL:** `https://find-origin.vercel.app/api/telegram`
- **Метод:** POST (перенаправляет на `/api/webhook`)

### Endpoint для установки webhook
- **URL:** `https://find-origin.vercel.app/api/setup-webhook`
- **Метод:** GET
- **Описание:** Автоматически устанавливает webhook используя переменные окружения

## Проверка работы бота

1. Найдите вашего бота в Telegram по username
2. Отправьте команду `/start`
3. Бот должен ответить приветственным сообщением

Если бот не отвечает:
1. Проверьте логи на Vercel (Deployments → последний деплой → Logs)
2. Убедитесь, что `TELEGRAM_BOT_TOKEN` установлен на Vercel
3. Убедитесь, что проект переразвернут после добавления переменных
4. Проверьте статус webhook через `getWebhookInfo`

## Безопасность

⚠️ **НИКОГДА не публикуйте токен бота в открытом доступе!**
- Храните токен в `.env.local` файле
- Не коммитьте `.env` или `.env.local` в Git (уже добавлены в `.gitignore`)
- Используйте переменные окружения для production на Vercel
