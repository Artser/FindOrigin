# Решение проблемы: Логи [WEBHOOK] не появляются

## Проблема
Webhook установлен правильно, но в логах Vercel нет записей с префиксом `[WEBHOOK]`. Это означает, что Telegram не отправляет запросы на endpoint.

## Что уже проверено
- ✅ Webhook установлен: `https://find-origin.vercel.app/api/webhook`
- ✅ Pending updates: 0
- ✅ Endpoint доступен для POST запросов (статус 200)

## Возможные причины и решения

### 1. Переменные окружения не установлены на Vercel

**Проверка:**
```powershell
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/check-env" -Method GET
```

**Решение:**
1. Откройте Vercel Dashboard
2. Перейдите в ваш проект `find-origin`
3. Settings → Environment Variables
4. Убедитесь, что установлены:
   - `TELEGRAM_BOT_TOKEN` - **ОБЯЗАТЕЛЬНО**
   - `OPENROUTER_API_KEY` (или `OPENAI_API_KEY`)
   - `OPENAI_BASE_URL`
   - Поисковые API ключи

**ВАЖНО:** После добавления/изменения переменных **ОБЯЗАТЕЛЬНО переразверните проект!**

### 2. Проект не переразвернут после добавления переменных

**Решение:**
1. В Vercel Dashboard откройте ваш проект
2. Перейдите в раздел **Deployments**
3. Найдите последний деплой
4. Нажмите на три точки (⋮) → **Redeploy**
5. Или сделайте новый коммит и push в GitHub

### 3. Telegram не может достучаться до Vercel

**Проверка:**
```powershell
# Проверка доступности endpoint
Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method POST -Body '{"test":true}' -ContentType "application/json"
```

Если запрос проходит, значит endpoint доступен.

### 4. Webhook установлен, но Telegram не отправляет обновления

**Решение:**
1. Удалите webhook:
```powershell
$token = "YOUR_BOT_TOKEN"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET
```

2. Установите webhook заново:
```powershell
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=https://find-origin.vercel.app/api/webhook" -Method GET
```

3. Проверьте статус:
```powershell
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
```

### 5. Проверка через тестовый запрос

Отправьте тестовый POST запрос на endpoint, чтобы убедиться, что логирование работает:

```powershell
$body = @{
    update_id = 12345
    message = @{
        message_id = 1
        chat = @{
            id = 123456789
            type = "private"
        }
        text = "/start"
    }
} | ConvertTo-Json -Depth 10

Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method POST -Body $body -ContentType "application/json"
```

После этого проверьте логи Vercel - должны появиться записи с `[WEBHOOK]`.

## Пошаговая инструкция

### Шаг 1: Проверьте переменные окружения на Vercel

1. Откройте https://vercel.com/dashboard
2. Выберите проект `find-origin`
3. Settings → Environment Variables
4. Проверьте наличие `TELEGRAM_BOT_TOKEN`

### Шаг 2: Переразверните проект

**Вариант A: Через Dashboard**
1. Deployments → последний деплой → ⋮ → Redeploy

**Вариант B: Через Git**
```powershell
git commit --allow-empty -m "Redeploy to apply environment variables"
git push
```

### Шаг 3: Переустановите webhook

```powershell
# Получите токен из .env.local
$token = (Get-Content ".env.local" | Select-String "TELEGRAM_BOT_TOKEN").ToString() -replace "TELEGRAM_BOT_TOKEN\s*=\s*", ""

# Удалите старый webhook
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET

# Установите новый webhook
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=https://find-origin.vercel.app/api/webhook" -Method GET

# Проверьте статус
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
Write-Host "URL: $($info.result.url)"
Write-Host "Pending: $($info.result.pending_update_count)"
```

### Шаг 4: Отправьте тестовое сообщение боту

Откройте Telegram и отправьте боту сообщение (например, `/start`).

### Шаг 5: Проверьте логи Vercel

1. Vercel Dashboard → ваш проект
2. Последний деплой → Logs
3. Ищите записи с префиксом `[WEBHOOK]`

Если логи появились - проблема решена!
Если нет - проверьте, что `TELEGRAM_BOT_TOKEN` установлен на Vercel и проект переразвернут.

## Диагностика

Если проблема сохраняется, выполните полную диагностику:

```powershell
# 1. Проверка webhook
$token = "YOUR_BOT_TOKEN"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
Write-Host "Webhook URL: $($info.result.url)"
Write-Host "Pending updates: $($info.result.pending_update_count)"
if ($info.result.last_error_date) {
    Write-Host "ERROR: $($info.result.last_error_message)"
}

# 2. Проверка endpoint
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method GET

# 3. Проверка переменных окружения на Vercel
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/check-env" -Method GET
```

## Частые ошибки

1. **Переменные добавлены, но проект не переразвернут** - самая частая причина!
2. **Неправильное имя переменной** - должно быть `TELEGRAM_BOT_TOKEN`, а не `TELEGRAM_TOKEN`
3. **Webhook установлен на другой URL** - проверьте через `getWebhookInfo`
4. **Telegram блокирует запросы** - проверьте `last_error_message` в `getWebhookInfo`

