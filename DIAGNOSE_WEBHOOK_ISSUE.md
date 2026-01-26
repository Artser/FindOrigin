# Диагностика: Telegram не отправляет запросы на webhook

## Проблема
- ✅ Переменные окружения установлены на Vercel
- ✅ Webhook установлен правильно: `https://find-origin.vercel.app/api/webhook`
- ✅ Endpoint доступен и отвечает на POST запросы
- ❌ Логи `[WEBHOOK]` не появляются в Vercel
- ❌ Telegram не отправляет запросы на endpoint

## Возможные причины

### 1. Telegram блокирует запросы из-за предыдущих ошибок

**Решение:**
Проверьте последнюю ошибку webhook:
```powershell
$token = "YOUR_BOT_TOKEN"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
if ($info.result.last_error_date) {
    Write-Host "Последняя ошибка: $($info.result.last_error_message)"
}
```

Если есть ошибки:
1. Удалите webhook
2. Подождите 1-2 минуты
3. Установите заново

### 2. Vercel не показывает логи для некоторых запросов

**Проверка:**
1. Откройте Vercel Dashboard
2. Ваш проект → **Deployments**
3. Выберите **последний деплой**
4. Перейдите в раздел **Logs**
5. **ВАЖНО:** Убедитесь, что вы смотрите логи **Production**, а не Preview
6. Проверьте фильтры - возможно, логи фильтруются по времени или типу

### 3. Endpoint работает, но логи не записываются

**Тест:**
После развертывания нового кода (через 1-2 минуты):
```powershell
# Тест логирования
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/test-log" -Method GET
```

Затем проверьте логи Vercel - должны появиться записи с `[TEST-LOG]`.

### 4. Telegram отправляет запросы, но они не доходят до Vercel

**Проверка:**
1. Откройте Vercel Dashboard
2. Ваш проект → **Analytics** или **Functions**
3. Проверьте метрики запросов к `/api/webhook`
4. Если запросов нет - Telegram действительно не отправляет

### 5. Проблема с конфигурацией Vercel

**Проверка `vercel.json`:**
Убедитесь, что файл `vercel.json` правильно настроен для API routes.

## Пошаговая диагностика

### Шаг 1: Проверьте статус webhook в Telegram

```powershell
$token = "YOUR_BOT_TOKEN"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"

Write-Host "URL: $($info.result.url)"
Write-Host "Pending: $($info.result.pending_update_count)"
Write-Host "Last error date: $($info.result.last_error_date)"
Write-Host "Last error message: $($info.result.last_error_message)"
```

**Если есть ошибки:**
- Запишите сообщение об ошибке
- Удалите и переустановите webhook

### Шаг 2: Переустановите webhook

```powershell
$token = "YOUR_BOT_TOKEN"
$webhookUrl = "https://find-origin.vercel.app/api/webhook"

# Удалить
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET

# Подождать 10 секунд
Start-Sleep -Seconds 10

# Установить заново
$result = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$webhookUrl" -Method GET
Write-Host "Результат: $($result | ConvertTo-Json)"
```

### Шаг 3: Проверьте доступность endpoint

```powershell
# GET запрос
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method GET

# POST запрос (симуляция Telegram)
$body = @{
    update_id = 999999
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

После POST запроса **сразу проверьте логи Vercel** - должны появиться записи `[WEBHOOK]`.

### Шаг 4: Проверьте логи Vercel правильно

1. **Откройте правильный раздел:**
   - Vercel Dashboard → ваш проект
   - **Deployments** (не Overview!)
   - Выберите **последний Production деплой**
   - **Logs** (не Metrics!)

2. **Проверьте фильтры:**
   - Убедитесь, что нет фильтров по времени
   - Проверьте, что вы смотрите логи Production, а не Preview

3. **Ищите записи:**
   - `[WEBHOOK]` - для webhook запросов
   - `[TEST-LOG]` - для тестовых запросов
   - Любые ошибки или предупреждения

### Шаг 5: Отправьте тестовое сообщение боту

1. Откройте Telegram
2. Найдите бота @ArtserShowBot
3. Отправьте `/start` или любой текст
4. **Сразу** проверьте логи Vercel (обновите страницу)

### Шаг 6: Проверьте через Telegram API напрямую

Если логи все еще не появляются, проверьте, отправляет ли Telegram запросы:

```powershell
# Получить pending updates (если они есть)
$token = "YOUR_BOT_TOKEN"
$updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getUpdates" -Method GET
Write-Host "Pending updates: $($updates.result.Count)"
```

Если есть pending updates, значит Telegram пытается отправить, но webhook не работает.

## Альтернативное решение: Использовать getUpdates вместо webhook

Если webhook не работает, можно временно использовать polling:

```powershell
# Удалить webhook
$token = "YOUR_BOT_TOKEN"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook" -Method GET

# Теперь можно использовать getUpdates для получения обновлений
```

Но это не решение для production - нужно исправить webhook.

## Что проверить на Vercel

1. **Переменные окружения:**
   - Settings → Environment Variables
   - Убедитесь, что `TELEGRAM_BOT_TOKEN` установлен
   - Проверьте, что значение правильное (совпадает с `.env.local`)

2. **Деплой:**
   - Deployments → последний деплой
   - Убедитесь, что деплой **успешен** (зеленый статус)
   - Проверьте время деплоя - должен быть свежим

3. **Логи:**
   - Deployments → последний деплой → Logs
   - Проверьте, что вы смотрите логи **Production**
   - Обновите страницу после отправки сообщения боту

4. **Функции:**
   - Analytics → Functions
   - Проверьте, есть ли вызовы `/api/webhook`
   - Если вызовов нет - Telegram не отправляет запросы

## Если ничего не помогает

1. **Создайте новый webhook URL** с другим путем (например, `/api/telegram-webhook`)
2. **Проверьте, нет ли блокировок** на стороне Vercel или Telegram
3. **Используйте другой домен** для тестирования (если есть)
4. **Проверьте, работает ли endpoint локально** с тем же кодом

## Контрольный список

- [ ] Webhook установлен правильно (`getWebhookInfo` показывает правильный URL)
- [ ] Нет ошибок в `last_error_message`
- [ ] Endpoint доступен (GET и POST запросы проходят)
- [ ] Переменные окружения установлены на Vercel
- [ ] Проект переразвернут после добавления переменных
- [ ] Логи Vercel проверены в правильном разделе (Deployments → последний деплой → Logs)
- [ ] Тестовый POST запрос создает логи `[WEBHOOK]`
- [ ] Отправлено тестовое сообщение боту
- [ ] Логи обновлены после отправки сообщения

