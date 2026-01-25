# Исправление: Telegram бот не отвечает на Vercel

## 🔍 Диагностика проблемы

### Шаг 1: Проверьте webhook URL

Убедитесь, что webhook установлен на правильный URL вашего Vercel проекта:

```powershell
# Замените YOUR_BOT_TOKEN на ваш токен бота
$botToken = "YOUR_BOT_TOKEN"
$response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getWebhookInfo"
$response | ConvertTo-Json -Depth 5
```

**Проверьте:**
- ✅ `url` должен быть: `https://ваш-проект.vercel.app/api/webhook`
- ✅ `pending_update_count` должен быть `0` (если есть pending updates, бот не будет отвечать)
- ✅ `last_error_date` должен быть `null` (если есть ошибки, они будут показаны)

### Шаг 2: Установите/обновите webhook

Если webhook не установлен или установлен неправильно:

```powershell
# Замените на ваши значения
$botToken = "YOUR_BOT_TOKEN"
$vercelUrl = "https://ваш-проект.vercel.app"
$webhookUrl = "$vercelUrl/api/webhook"

# Установка webhook
$response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=$webhookUrl" -Method GET
$response | ConvertTo-Json
```

**Или через API endpoint вашего проекта:**

```powershell
$vercelUrl = "https://ваш-проект.vercel.app"
Invoke-WebRequest -Uri "$vercelUrl/api/set-webhook?url=$vercelUrl/api/webhook" -Method GET
```

### Шаг 3: Проверьте переменные окружения на Vercel

1. Откройте https://vercel.com
2. Выберите проект `FindOrigin`
3. Перейдите в **Settings** → **Environment Variables**
4. Убедитесь, что добавлены:

**Обязательно:**
- ✅ `TELEGRAM_BOT_TOKEN` - токен вашего бота
- ✅ `OPENROUTER_API_KEY` или `OPENAI_API_KEY` - для AI-анализа
- ✅ `OPENAI_BASE_URL` - URL API (например, `https://openrouter.ai/api/v1`)
- ✅ Хотя бы один поисковый API:
  - `BING_SEARCH_API_KEY` (рекомендуется)
  - ИЛИ `GOOGLE_SEARCH_API_KEY` + `GOOGLE_SEARCH_ENGINE_ID`
  - ИЛИ `SERPAPI_KEY`

**Опционально:**
- `TELEGRAM_WEBHOOK_SECRET` - для безопасности webhook

### Шаг 4: Проверьте логи Vercel

1. В Vercel Dashboard перейдите в **Deployments**
2. Выберите последний деплой
3. Откройте **Logs**
4. Ищите ошибки:
   - ❌ `TELEGRAM_BOT_TOKEN не установлен`
   - ❌ `OPENAI_API_KEY или OPENROUTER_API_KEY не установлен`
   - ❌ Ошибки при обработке webhook

### Шаг 5: Проверьте доступность webhook endpoint

```powershell
$vercelUrl = "https://ваш-проект.vercel.app"
try {
    $response = Invoke-WebRequest -Uri "$vercelUrl/api/webhook" -Method GET
    Write-Host "✅ Webhook endpoint доступен" -ForegroundColor Green
    Write-Host "Ответ: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Webhook endpoint недоступен" -ForegroundColor Red
    Write-Host "Ошибка: $_" -ForegroundColor Yellow
}
```

Должен вернуться JSON: `{"status":"ok","message":"FindOrigin Telegram Bot Webhook",...}`

---

## 🔧 Решение проблем

### Проблема 1: Webhook не установлен

**Симптомы:**
- `getWebhookInfo` показывает `url: ""` или старый URL

**Решение:**
```powershell
$botToken = "YOUR_BOT_TOKEN"
$vercelUrl = "https://ваш-проект.vercel.app"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=$vercelUrl/api/webhook" -Method GET
```

### Проблема 2: Есть pending updates

**Симптомы:**
- `getWebhookInfo` показывает `pending_update_count > 0`

**Решение:**
```powershell
$botToken = "YOUR_BOT_TOKEN"
# Удалить все pending updates
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/deleteWebhook?drop_pending_updates=true" -Method GET
# Затем установить webhook заново
$vercelUrl = "https://ваш-проект.vercel.app"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=$vercelUrl/api/webhook" -Method GET
```

### Проблема 3: Переменные окружения не установлены

**Симптомы:**
- В логах Vercel ошибки о недостающих переменных

**Решение:**
1. Добавьте все необходимые переменные в Vercel (см. `VERCEL_ENV_VARIABLES.md`)
2. **Обязательно переразверните проект** после добавления переменных:
   - Deployments → последний деплой → "..." → "Redeploy"

### Проблема 4: Webhook endpoint возвращает ошибку

**Симптомы:**
- `getWebhookInfo` показывает `last_error_date` и `last_error_message`

**Решение:**
1. Проверьте логи Vercel на наличие ошибок
2. Убедитесь, что endpoint доступен (см. Шаг 5 выше)
3. Проверьте, что проект успешно развернут (нет ошибок сборки)

### Проблема 5: Бот отвечает, но с ошибками

**Симптомы:**
- Бот получает сообщения, но не может обработать их

**Решение:**
1. Проверьте логи Vercel - там будут детальные ошибки
2. Убедитесь, что все API ключи (OpenRouter, поисковые API) правильные и активные
3. Проверьте, что API ключи добавлены для правильного окружения (Production)

---

## ✅ Быстрая проверка всего

Выполните этот скрипт для полной диагностики:

```powershell
# Замените на ваши значения
$botToken = "YOUR_BOT_TOKEN"
$vercelUrl = "https://ваш-проект.vercel.app"

Write-Host "=== Диагностика Telegram бота ===" -ForegroundColor Cyan
Write-Host ""

# 1. Проверка webhook
Write-Host "1. Проверка webhook..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getWebhookInfo"
    Write-Host "   URL: $($webhookInfo.result.url)" -ForegroundColor $(if ($webhookInfo.result.url -like "*$vercelUrl*") { "Green" } else { "Red" })
    Write-Host "   Pending updates: $($webhookInfo.result.pending_update_count)" -ForegroundColor $(if ($webhookInfo.result.pending_update_count -eq 0) { "Green" } else { "Red" })
    if ($webhookInfo.result.last_error_date) {
        Write-Host "   ❌ Последняя ошибка: $($webhookInfo.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host "   ✅ Ошибок нет" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Ошибка при проверке webhook: $_" -ForegroundColor Red
}

Write-Host ""

# 2. Проверка доступности endpoint
Write-Host "2. Проверка доступности endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$vercelUrl/api/webhook" -Method GET
    Write-Host "   ✅ Endpoint доступен (статус: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Endpoint недоступен: $_" -ForegroundColor Red
}

Write-Host ""

# 3. Проверка бота
Write-Host "3. Проверка информации о боте..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getMe"
    Write-Host "   Имя: $($botInfo.result.first_name)" -ForegroundColor Green
    Write-Host "   Username: @$($botInfo.result.username)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Ошибка при проверке бота: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Конец диагностики ===" -ForegroundColor Cyan
```

---

## 🚀 После исправления

1. **Отправьте тестовое сообщение боту** (например, `/start`)
2. **Проверьте логи Vercel** - должны быть записи о получении webhook
3. **Если бот не отвечает**, проверьте логи на наличие ошибок

---

## 📝 Чеклист

- [ ] Webhook установлен на правильный URL
- [ ] Нет pending updates
- [ ] `TELEGRAM_BOT_TOKEN` добавлен в Vercel
- [ ] AI API ключ добавлен в Vercel (`OPENROUTER_API_KEY` или `OPENAI_API_KEY`)
- [ ] `OPENAI_BASE_URL` добавлен в Vercel
- [ ] Хотя бы один поисковый API добавлен
- [ ] Проект переразвернут после добавления переменных
- [ ] Webhook endpoint доступен (возвращает 200 OK)
- [ ] В логах Vercel нет ошибок

---

## 🆘 Если ничего не помогает

1. **Проверьте логи Vercel в реальном времени:**
   - Deployments → последний деплой → Logs
   - Отправьте сообщение боту
   - Смотрите логи - там будут детальные ошибки

2. **Проверьте переменные окружения:**
   - Убедитесь, что они добавлены для **Production** окружения
   - Проверьте, что значения правильные (без лишних пробелов, кавычек)

3. **Переразверните проект:**
   - Deployments → "..." → "Redeploy"

4. **Проверьте, что проект успешно собрался:**
   - В Deployments должен быть статус "Ready" (зеленый)

