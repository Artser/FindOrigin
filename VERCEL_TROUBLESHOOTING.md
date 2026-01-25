# Устранение проблемы: нет логов при отправке сообщения боту

## Проблема
- Проект развернут на Vercel
- Webhook настроен правильно
- Но при отправке сообщения боту в логах Vercel ничего не появляется

## Возможные причины

### 1. Переменные окружения не добавлены на Vercel

**Проверка:**
1. Vercel Dashboard → Settings → Environment Variables
2. Убедитесь, что добавлены:
   - `TELEGRAM_BOT_TOKEN`
   - `OPENROUTER_API_KEY` (или `OPENAI_API_KEY`)
   - `OPENAI_BASE_URL`
   - Хотя бы один поисковый API

**Решение:**
- Добавьте все переменные
- **Обязательно переразверните проект** после добавления переменных

### 2. Webhook не получает запросы от Telegram

**Проверка:**
```powershell
$botToken = "ваш_telegram_bot_token"
$webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getWebhookInfo"
$webhookInfo | ConvertTo-Json -Depth 5
```

Проверьте:
- `url` должен быть: `https://find-origin.vercel.app/api/webhook`
- `pending_update_count` должен быть `0`
- `last_error_date` должен быть `null` (если есть ошибки, они будут показаны)

**Если есть ошибки:**
```powershell
# Удалить webhook и установить заново
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/deleteWebhook?drop_pending_updates=true" -Method GET
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=https://find-origin.vercel.app/api/webhook" -Method GET
```

### 3. Логи не показываются в реальном времени

**Как проверить логи:**
1. Vercel Dashboard → Deployments → выберите последний деплой
2. Нажмите на деплой (откроется детальная страница)
3. Перейдите на вкладку **"Logs"**
4. Отправьте сообщение боту
5. Смотрите логи в реальном времени

**Или через функцию Logs:**
1. Vercel Dashboard → **Logs** (в левом меню)
2. Выберите проект
3. Отправьте сообщение боту
4. Смотрите логи

### 4. Переменные окружения не применяются

**Важно:** После добавления переменных окружения на Vercel:
1. Перейдите в Deployments
2. Найдите последний деплой
3. Нажмите "..." → **"Redeploy"**
4. Дождитесь завершения развертывания

**Проверка переменных в коде:**
Добавьте временный endpoint для проверки переменных:

```typescript
// app/api/check-env/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    hasTelegramToken: !!process.env.TELEGRAM_BOT_TOKEN,
    hasOpenRouterKey: !!process.env.OPENROUTER_API_KEY,
    hasOpenAIKey: !!process.env.OPENAI_API_KEY,
    hasBaseUrl: !!process.env.OPENAI_BASE_URL,
    hasBingKey: !!process.env.BING_SEARCH_API_KEY,
    hasGoogleKey: !!process.env.GOOGLE_SEARCH_API_KEY,
  });
}
```

Затем проверьте:
```powershell
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/check-env" -Method GET
```

### 5. Webhook endpoint не обрабатывает запросы

**Проверка:**
1. Откройте логи Vercel в реальном времени
2. Отправьте сообщение боту
3. Если в логах ничего нет, значит Telegram не отправляет запросы

**Решение:**
- Проверьте webhook через `getWebhookInfo`
- Убедитесь, что нет ошибок в `last_error_message`
- Переустановите webhook

---

## Пошаговая диагностика

### Шаг 1: Проверьте переменные окружения

```powershell
# Создайте временный endpoint для проверки (см. выше)
# Затем проверьте:
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/check-env" -Method GET
```

Если какие-то переменные `false`, добавьте их на Vercel и переразверните проект.

### Шаг 2: Проверьте webhook

```powershell
$botToken = "ваш_telegram_bot_token"
$webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getWebhookInfo"
Write-Host "URL: $($webhookInfo.result.url)"
Write-Host "Pending: $($webhookInfo.result.pending_update_count)"
Write-Host "Last error: $($webhookInfo.result.last_error_message)"
```

### Шаг 3: Проверьте логи в реальном времени

1. Vercel Dashboard → **Logs** (левое меню)
2. Выберите проект
3. Отправьте сообщение боту (`/start`)
4. Смотрите логи - должны появиться записи

### Шаг 4: Тестовая отправка сообщения

Отправьте боту команду `/start` и проверьте:
- Появляются ли логи на Vercel
- Если нет - проблема в webhook или переменных окружения

---

## Быстрое решение

1. **Добавьте все переменные окружения на Vercel:**
   - Settings → Environment Variables
   - Добавьте все из `.env.local`

2. **Переразверните проект:**
   - Deployments → последний деплой → "..." → "Redeploy"

3. **Проверьте webhook:**
   ```powershell
   $botToken = "ваш_токен"
   Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=https://find-origin.vercel.app/api/webhook" -Method GET
   ```

4. **Отправьте сообщение боту и проверьте логи:**
   - Vercel Dashboard → Logs
   - Отправьте `/start` боту
   - Должны появиться логи

---

## Если ничего не помогает

1. **Проверьте, что проект успешно развернут:**
   - В Deployments должен быть статус "Ready" (зеленый)

2. **Проверьте, что webhook endpoint доступен:**
   ```powershell
   Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method GET
   ```
   Должен вернуть `{"status":"ok"}`

3. **Проверьте логи на наличие ошибок:**
   - Даже если нет запросов от Telegram, могут быть ошибки при старте приложения

4. **Попробуйте отправить тестовый POST запрос на webhook:**
   ```powershell
   $testBody = @{
       update_id = 123
       message = @{
           message_id = 1
           chat = @{
               id = 123456
               type = "private"
           }
           text = "/start"
       }
   } | ConvertTo-Json -Depth 10
   
   Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method POST -Body $testBody -ContentType "application/json"
   ```
   
   Затем проверьте логи Vercel - должны появиться записи.

