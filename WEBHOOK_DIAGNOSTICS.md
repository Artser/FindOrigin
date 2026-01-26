# Диагностика проблемы с Telegram Webhook

## Проблема: Логи [WEBHOOK] не появляются

Если логи с префиксом `[WEBHOOK]` не появляются в Vercel, это означает, что **Telegram не отправляет запросы** на ваш endpoint.

## Шаги диагностики

### 1. Проверьте статус webhook в Telegram

Используйте скрипт для проверки и установки webhook:

```powershell
.\check-and-set-webhook.ps1
```

Или проверьте вручную через API:

```powershell
# Замените YOUR_BOT_TOKEN на ваш токен
$token = "YOUR_BOT_TOKEN"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
```

**Что проверить:**
- `url` - должен быть `https://find-origin.vercel.app/api/webhook`
- `pending_update_count` - должен быть `0` (если больше, удалите их)
- `last_error_date` - если есть, значит были ошибки доставки

### 2. Установите webhook правильно

Если webhook не установлен или установлен неправильно:

```powershell
.\check-and-set-webhook.ps1
```

Скрипт автоматически:
- Проверит текущий webhook
- Удалит старый webhook и pending updates
- Установит правильный webhook URL

### 3. Проверьте доступность endpoint

Проверьте, что endpoint доступен:

```powershell
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method GET
```

Должен вернуться JSON с `status: "ok"`.

### 4. Проверьте переменные окружения на Vercel

Убедитесь, что на Vercel установлены все необходимые переменные:

1. Откройте Vercel Dashboard
2. Перейдите в ваш проект
3. Settings → Environment Variables
4. Проверьте наличие:
   - `TELEGRAM_BOT_TOKEN` - **ОБЯЗАТЕЛЬНО**
   - `OPENROUTER_API_KEY` (или `OPENAI_API_KEY`)
   - `OPENAI_BASE_URL`
   - Поисковые API ключи

**ВАЖНО:** После добавления/изменения переменных окружения **обязательно переразверните проект**.

### 5. Проверьте логи Vercel

1. Откройте Vercel Dashboard
2. Перейдите в ваш проект
3. Откройте последний деплой
4. Перейдите в раздел **Logs**
5. Отправьте сообщение боту в Telegram
6. Ищите записи с префиксом `[WEBHOOK]`

**Если логи не появляются:**
- Telegram не отправляет запросы (webhook не установлен или неправильный)
- Endpoint недоступен для Telegram
- Проблемы с сетью между Telegram и Vercel

### 6. Проверьте через API endpoint

Используйте новый endpoint для проверки webhook через API:

```powershell
# Через Vercel endpoint (требует TELEGRAM_BOT_TOKEN на Vercel)
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook-info" -Method GET
```

Или напрямую через Telegram API:

```powershell
$token = "YOUR_BOT_TOKEN"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
```

## Улучшенное логирование

Теперь webhook endpoint логирует **все** входящие запросы с префиксом `[WEBHOOK]`:

- Момент получения запроса
- Заголовки запроса
- Тело запроса (первые 200 символов)
- Результат парсинга JSON
- Детали обработки

Если вы видите логи `[WEBHOOK]`, значит запрос дошел до endpoint.

## Частые проблемы

### Проблема: Webhook установлен, но логи не появляются

**Возможные причины:**
1. **Webhook установлен на другой URL** - проверьте через `getWebhookInfo`
2. **Telegram не может достучаться до Vercel** - проверьте доступность endpoint
3. **Переменные окружения не установлены на Vercel** - проверьте в Vercel Dashboard
4. **Проект не переразвернут после добавления переменных** - сделайте redeploy

### Проблема: Webhook показывает ошибки в `last_error_message`

**Решение:**
1. Проверьте сообщение об ошибке в `getWebhookInfo`
2. Убедитесь, что endpoint возвращает 200 OK
3. Проверьте, что endpoint доступен из интернета
4. Удалите старый webhook и установите заново

### Проблема: Pending updates > 0

**Решение:**
```powershell
$token = "YOUR_BOT_TOKEN"
# Удалить webhook и все pending updates
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET
# Установить webhook заново
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=https://find-origin.vercel.app/api/webhook" -Method GET
```

## Команды для быстрой диагностики

```powershell
# 1. Проверка webhook
$token = "YOUR_BOT_TOKEN"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"

# 2. Установка webhook
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=https://find-origin.vercel.app/api/webhook" -Method GET

# 3. Удаление webhook и pending updates
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET

# 4. Проверка доступности endpoint
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method GET

# 5. Проверка переменных окружения на Vercel
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/check-env" -Method GET
```

## Что делать дальше

1. **Запустите скрипт диагностики:**
   ```powershell
   .\check-and-set-webhook.ps1
   ```

2. **Убедитесь, что webhook установлен правильно:**
   - URL должен быть `https://find-origin.vercel.app/api/webhook`
   - Pending updates должны быть удалены

3. **Проверьте переменные окружения на Vercel:**
   - `TELEGRAM_BOT_TOKEN` должен быть установлен
   - После добавления переменных переразверните проект

4. **Отправьте тестовое сообщение боту**

5. **Проверьте логи Vercel:**
   - Должны появиться записи с префиксом `[WEBHOOK]`
   - Если записей нет, значит Telegram не отправляет запросы

6. **Если проблема сохраняется:**
   - Проверьте, что endpoint доступен из интернета
   - Проверьте, что нет блокировок на стороне Vercel
   - Попробуйте удалить и установить webhook заново

