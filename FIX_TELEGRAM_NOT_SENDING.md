# Исправление: Telegram не отправляет запросы на webhook

## Проблема
- Webhook установлен правильно
- Endpoint доступен и работает
- Но Telegram не отправляет запросы (нет логов в Vercel)

## Возможные причины и решения

### 1. Переменные окружения не установлены на Vercel

**Проверка:**
1. Vercel Dashboard → Settings → Environment Variables
2. Убедитесь, что добавлен `TELEGRAM_BOT_TOKEN`

**Решение:**
- Добавьте `TELEGRAM_BOT_TOKEN` = `6436071741:AAFqCJ_EkbFKQQXJN5xCVb0Fh8h0wwSjuyI`
- **Обязательно переразверните проект** после добавления

### 2. Проект не переразвернут после добавления переменных

**Решение:**
1. Deployments → последний деплой
2. Нажмите "..." → "Redeploy"
3. Дождитесь завершения развертывания

### 3. Telegram не может достучаться до webhook

**Проверка:**
```powershell
$botToken = "6436071741:AAFqCJ_EkbFKQQXJN5xCVb0Fh8h0wwSjuyI"
$webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getWebhookInfo"
Write-Host "URL: $($webhookInfo.result.url)"
Write-Host "Last error: $($webhookInfo.result.last_error_message)"
```

Если есть ошибки в `last_error_message`, исправьте их.

### 4. Webhook установлен, но Telegram не отправляет обновления

**Решение:**
1. Удалите webhook
2. Установите заново
3. Отправьте сообщение боту

```powershell
$botToken = "6436071741:AAFqCJ_EkbFKQQXJN5xCVb0Fh8h0wwSjuyI"

# Удалить webhook
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/deleteWebhook?drop_pending_updates=true" -Method GET

# Установить заново
$vercelUrl = "https://find-origin.vercel.app"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=$vercelUrl/api/webhook" -Method GET
```

### 5. Проверка через тестовый запрос

Отправьте тестовый POST запрос на webhook:

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

Затем проверьте логи Vercel - должны появиться записи с `[WEBHOOK]`.

---

## Пошаговая инструкция

### Шаг 1: Проверьте переменные окружения на Vercel

1. Откройте https://vercel.com
2. Выберите проект `find-origin`
3. Settings → Environment Variables
4. Убедитесь, что добавлен:
   - `TELEGRAM_BOT_TOKEN` = `6436071741:AAFqCJ_EkbFKQQXJN5xCVb0Fh8h0wwSjuyI`

### Шаг 2: Переразверните проект

1. Deployments → последний деплой
2. "..." → "Redeploy"
3. Дождитесь завершения

### Шаг 3: Переустановите webhook

```powershell
$botToken = "6436071741:AAFqCJ_EkbFKQQXJN5xCVb0Fh8h0wwSjuyI"
$vercelUrl = "https://find-origin.vercel.app"

# Удалить и установить заново
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/deleteWebhook?drop_pending_updates=true" -Method GET
Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/setWebhook?url=$vercelUrl/api/webhook" -Method GET
```

### Шаг 4: Отправьте сообщение боту

1. Откройте Telegram
2. Найдите вашего бота
3. Отправьте `/start`
4. Проверьте логи Vercel (Logs → выберите проект)

### Шаг 5: Проверьте логи

1. Vercel Dashboard → Logs (левое меню)
2. Выберите проект `find-origin`
3. Отправьте сообщение боту
4. Смотрите логи - должны появиться записи с `[WEBHOOK]`

---

## Если ничего не помогает

1. **Проверьте, что бот активен:**
   ```powershell
   $botToken = "6436071741:AAFqCJ_EkbFKQQXJN5xCVb0Fh8h0wwSjuyI"
   Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getMe"
   ```

2. **Проверьте webhook еще раз:**
   ```powershell
   $botToken = "6436071741:AAFqCJ_EkbFKQQXJN5xCVb0Fh8h0wwSjuyI"
   Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getWebhookInfo" | ConvertTo-Json -Depth 5
   ```

3. **Попробуйте использовать polling вместо webhook (временно для теста):**
   ```powershell
   # Удалить webhook
   Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/deleteWebhook" -Method GET
   ```
   
   Затем запустите локально с polling (но это не решение для production).

---

## Важно

**Главная причина обычно:** Переменные окружения не добавлены на Vercel или проект не переразвернут после их добавления.

**Обязательно:**
1. Добавьте `TELEGRAM_BOT_TOKEN` на Vercel
2. Переразверните проект
3. Переустановите webhook
4. Отправьте сообщение боту
5. Проверьте логи

