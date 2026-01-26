# Диагностика: Бот не отвечает

## Быстрая проверка

### 1. Запустите скрипт диагностики

```powershell
.\diagnose-bot.ps1
```

Скрипт проверит:
- Работает ли токен бота
- Установлен ли webhook
- Доступен ли endpoint
- Есть ли ошибки в webhook

### 2. Проверьте webhook вручную

```powershell
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
$info.result | ConvertTo-Json
```

**Ожидаемый результат:**
- `url` должен быть `https://find-origin.vercel.app/api/webhook`
- `pending_update_count` должен быть 0 или небольшое число
- `last_error_date` должен отсутствовать

### 3. Проверьте endpoint

```powershell
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method GET
```

**Ожидаемый результат:**
```json
{
  "status": "ok",
  "message": "FindOrigin Telegram Bot Webhook"
}
```

## Основные причины и решения

### Проблема 1: Webhook не установлен

**Симптомы:**
- `getWebhookInfo` показывает пустой URL или другой URL

**Решение:**
```powershell
.\setup-webhook.ps1
```

### Проблема 2: Переменные окружения не установлены на Vercel

**Симптомы:**
- Webhook установлен, но бот не отвечает
- В логах Vercel ошибка "TELEGRAM_BOT_TOKEN не установлен"

**Решение:**
1. Откройте [Vercel Dashboard](https://vercel.com/dashboard)
2. Выберите проект `find-origin`
3. Перейдите в **Settings → Environment Variables**
4. Убедитесь, что установлены:
   - `TELEGRAM_BOT_TOKEN` = `6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k`
   - `OPENROUTER_API_KEY`
   - `YANDEX_CLOUD_API_KEY`
   - `YANDEX_FOLDER_ID`
5. **ОБЯЗАТЕЛЬНО переразверните проект** после добавления переменных

### Проблема 3: Endpoint недоступен

**Симптомы:**
- GET запрос к `/api/webhook` не отвечает или возвращает ошибку
- В `getWebhookInfo` есть ошибка

**Решение:**
1. Проверьте, что проект развернут на Vercel
2. Проверьте логи деплоя на Vercel
3. Убедитесь, что домен правильный: `https://find-origin.vercel.app`

### Проблема 4: Ошибки в коде

**Симптомы:**
- Webhook установлен, endpoint доступен, но бот не отвечает
- В логах Vercel есть ошибки

**Решение:**
1. Откройте Vercel Dashboard
2. Перейдите в **Deployments → последний деплой → Logs**
3. Ищите записи с префиксом `[WEBHOOK]` или `[TELEGRAM]`
4. Проверьте ошибки и исправьте их

## Пошаговая диагностика

### Шаг 1: Проверка токена

```powershell
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
$botInfo.result
```

Должен вернуть информацию о боте. Если ошибка - токен неверный.

### Шаг 2: Проверка webhook

```powershell
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
$info.result
```

Проверьте:
- `url` - должен быть правильный
- `last_error_date` - должен отсутствовать
- `last_error_message` - должен отсутствовать

### Шаг 3: Проверка endpoint

```powershell
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method GET
```

Должен вернуть JSON с `status: "ok"`.

### Шаг 4: Проверка переменных на Vercel

1. Vercel Dashboard → ваш проект
2. Settings → Environment Variables
3. Убедитесь, что `TELEGRAM_BOT_TOKEN` установлен
4. Если нет - добавьте и переразверните

### Шаг 5: Проверка логов

1. Vercel Dashboard → ваш проект
2. Deployments → последний деплой → Logs
3. Отправьте `/start` боту
4. Ищите записи `[WEBHOOK]` в логах

## Тестирование

После исправления проблем:

1. Отправьте `/start` боту в Telegram
2. Проверьте логи на Vercel
3. Бот должен ответить приветственным сообщением

## Частые ошибки

### "TELEGRAM_BOT_TOKEN не установлен"

**Причина:** Переменная не установлена на Vercel или проект не переразвернут.

**Решение:** Добавьте переменную на Vercel и переразверните проект.

### "Telegram API error: 401"

**Причина:** Неверный токен.

**Решение:** Проверьте токен в `.env.local` и на Vercel.

### "Telegram API error: 403"

**Причина:** Бот заблокирован или токен недействителен.

**Решение:** Проверьте токен через `getMe`.

### Webhook error в getWebhookInfo

**Причина:** Endpoint недоступен или возвращает ошибку.

**Решение:** 
1. Проверьте доступность endpoint
2. Проверьте логи Vercel
3. Убедитесь, что проект развернут
