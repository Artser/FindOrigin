# Как проверить логи и работу бота

## Где искать логи

### 1. Логи сервера (локальная разработка)

**Где:** В терминале, где запущен `npm run dev`

**Как проверить:**

1. Откройте терминал, где запущен сервер
2. Вы должны видеть логи в реальном времени
3. При ошибках они будут красным цветом

**Пример логов:**
```
✓ Ready in 2.3s
○ Compiling /api/webhook ...
✓ Compiled /api/webhook in 234ms
```

**Пример ошибок:**
```
✗ Error: OPENAI_API_KEY не установлен
  at callOpenAI (lib/openai.ts:31:5)
```

### 2. Консоль браузера (для веб-интерфейса)

**Где:** В браузере, на странице `http://localhost:3000`

**Как открыть:**

1. Откройте `http://localhost:3000` в браузере
2. Нажмите `F12` или `Ctrl+Shift+I` (Chrome/Edge)
3. Перейдите на вкладку **Console**
4. Там будут ошибки JavaScript

### 3. Логи Vercel (если используете продакшен)

**Где:** Vercel Dashboard

**Как проверить:**

1. Откройте https://vercel.com/dashboard
2. Выберите ваш проект
3. Перейдите в раздел **Functions**
4. Выберите функцию `/api/webhook`
5. Просмотрите логи

## Как проверить работу бота

### Способ 1: Проверка через веб-интерфейс

1. Откройте `http://localhost:3000` в браузере
2. Введите любой текст в поле поиска
3. Нажмите "Найти источники"
4. Проверьте результат:
   - Если видите источники и AI-анализ → бот работает ✅
   - Если видите ошибку → скопируйте текст ошибки

### Способ 2: Проверка через Telegram

1. Откройте Telegram
2. Найдите вашего бота
3. Отправьте команду `/start`
4. Бот должен ответить приветствием
5. Отправьте любой текст
6. Бот должен начать обработку

**Если бот не отвечает:**
- Проверьте, что webhook настроен (см. ниже)
- Проверьте логи сервера

### Способ 3: Проверка через API напрямую

Откройте в браузере или через PowerShell:

```powershell
# Проверка webhook endpoint
Invoke-WebRequest -Uri "http://localhost:3000/api/webhook" -Method GET

# Проверка search endpoint (тест)
$body = @{ query = "тест" } | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:3000/api/search" -Method POST -Body $body -ContentType "application/json"
```

## Проверка webhook

### Проверка статуса webhook

```powershell
# Замените YOUR_BOT_TOKEN на ваш токен из .env.local
$token = "YOUR_BOT_TOKEN"
$response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
$response | ConvertTo-Json
```

**Что проверить:**
- `url` - должен быть ваш webhook URL
- `pending_update_count` - должно быть 0 (если есть ошибки, будет > 0)
- `last_error_message` - если есть ошибки, здесь будет описание

### Установка webhook (если не установлен)

**Для локальной разработки через ngrok:**

1. Запустите ngrok в отдельном терминале:
   ```powershell
   ngrok http 3000
   ```

2. Скопируйте URL (например: `https://abc123.ngrok.io`)

3. Установите webhook:
   ```powershell
   $ngrokUrl = "https://abc123.ngrok.io"
   Invoke-WebRequest -Uri "http://localhost:3000/api/set-webhook?url=$ngrokUrl/api/webhook"
   ```

## Типичные ошибки в логах

### "OPENAI_API_KEY или OPENROUTER_API_KEY не установлен"

**Решение:**
- Проверьте `.env.local` - должен быть `OPENROUTER_API_KEY` или `OPENAI_API_KEY`
- Перезапустите сервер

### "Не настроен ни один поисковый API"

**Решение:**
- Настройте хотя бы один поисковый API в `.env.local`
- Перекзапустите сервер

### "403 Forbidden" или "401 Unauthorized"

**Решение:**
- Проверьте правильность API ключей
- Проверьте биллинг в Google Cloud / Azure / Yandex Cloud

### "429 Rate limit exceeded"

**Решение:**
- Превышен лимит запросов
- Подождите или пополните баланс

### "Cannot read properties of undefined"

**Решение:**
- Ошибка в коде
- Проверьте логи сервера для деталей
- Убедитесь, что все зависимости установлены: `npm install`

## Создание скрипта для проверки

Создайте файл `check-bot.ps1`:

```powershell
Write-Host "=== Проверка бота ===" -ForegroundColor Cyan

# Проверка сервера
Write-Host "`n1. Проверка сервера..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/webhook" -Method GET -TimeoutSec 2
    Write-Host "   [OK] Сервер запущен" -ForegroundColor Green
} catch {
    Write-Host "   [ОШИБКА] Сервер не запущен. Запустите: npm run dev" -ForegroundColor Red
}

# Проверка переменных окружения
Write-Host "`n2. Проверка переменных окружения..." -ForegroundColor Yellow
if (Test-Path ".env.local") {
    $content = Get-Content ".env.local" -Raw
    if ($content -match "OPENROUTER_API_KEY|OPENAI_API_KEY") {
        Write-Host "   [OK] API ключ найден" -ForegroundColor Green
    } else {
        Write-Host "   [ОШИБКА] API ключ не найден" -ForegroundColor Red
    }
} else {
    Write-Host "   [ОШИБКА] Файл .env.local не найден" -ForegroundColor Red
}

# Проверка webhook
Write-Host "`n3. Проверка webhook..." -ForegroundColor Yellow
$token = (Get-Content ".env.local" | Select-String "TELEGRAM_BOT_TOKEN").ToString() -replace "TELEGRAM_BOT_TOKEN=", ""
if ($token) {
    try {
        $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
        if ($webhookInfo.ok) {
            Write-Host "   [OK] Webhook настроен: $($webhookInfo.result.url)" -ForegroundColor Green
            if ($webhookInfo.result.pending_update_count -gt 0) {
                Write-Host "   [ПРЕДУПРЕЖДЕНИЕ] Есть $($webhookInfo.result.pending_update_count) необработанных обновлений" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "   [ОШИБКА] Не удалось проверить webhook" -ForegroundColor Red
    }
}

Write-Host "`n=== Готово ===" -ForegroundColor Cyan
```

Запустите:
```powershell
.\check-bot.ps1
```

## Быстрая проверка

**Минимальная проверка:**

1. Сервер запущен? → Откройте `http://localhost:3000` в браузере
2. Есть ошибки в терминале? → Проверьте консоль, где запущен `npm run dev`
3. Бот отвечает? → Отправьте `/start` в Telegram
4. Webhook настроен? → Используйте команду выше для проверки

## Если ничего не помогает

1. **Скопируйте все ошибки** из терминала (где запущен `npm run dev`)
2. **Проверьте `.env.local`** - убедитесь, что все переменные установлены
3. **Перезапустите сервер** - полностью остановите (Ctrl+C) и запустите снова
4. **Проверьте webhook** - используйте команды выше



