# Решение: Бот не отвечает после смены токена

## Проблема
- ✅ Новый токен установлен на Vercel
- ✅ Проект переразвернут
- ❌ Бот не отвечает

## Причина
Webhook установлен на **старый токен**, а на Vercel используется **новый токен**. Нужно переустановить webhook на новый токен.

## Решение

### Шаг 1: Узнайте новый токен

Токен должен быть установлен на Vercel в переменной окружения `TELEGRAM_BOT_TOKEN`.

Если вы не помните токен, его можно найти:
1. Vercel Dashboard → ваш проект → Settings → Environment Variables
2. Найдите `TELEGRAM_BOT_TOKEN` и скопируйте значение

### Шаг 2: Переустановите webhook с новым токеном

Используйте скрипт:

```powershell
.\reinstall-webhook.ps1 -Token "ВАШ_НОВЫЙ_ТОКЕН"
```

Или вручную:

```powershell
$newToken = "ВАШ_НОВЫЙ_ТОКЕН"

# Удалить старый webhook
Invoke-RestMethod -Uri "https://api.telegram.org/bot$newToken/deleteWebhook?drop_pending_updates=true" -Method GET

# Подождать
Start-Sleep -Seconds 3

# Установить новый webhook
Invoke-RestMethod -Uri "https://api.telegram.org/bot$newToken/setWebhook?url=https://find-origin.vercel.app/api/webhook" -Method GET
```

### Шаг 3: Проверьте статус webhook

```powershell
$newToken = "ВАШ_НОВЫЙ_ТОКЕН"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$newToken/getWebhookInfo"
Write-Host "URL: $($info.result.url)"
Write-Host "Pending: $($info.result.pending_update_count)"
if ($info.result.last_error_date) {
    Write-Host "ERROR: $($info.result.last_error_message)"
}
```

### Шаг 4: Убедитесь, что токены совпадают

**ВАЖНО:** Токен на Vercel должен совпадать с токеном, на который установлен webhook.

1. Проверьте токен на Vercel:
   - Vercel Dashboard → ваш проект → Settings → Environment Variables
   - Найдите `TELEGRAM_BOT_TOKEN`

2. Проверьте токен webhook:
   ```powershell
   $token = "ВАШ_ТОКЕН"
   $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
   Write-Host "Webhook установлен для токена, который ведет на: $($info.result.url)"
   ```

3. Убедитесь, что они совпадают!

### Шаг 5: Отправьте тестовое сообщение

1. Откройте Telegram
2. Найдите вашего бота (по username из `getMe`)
3. Отправьте `/start` или любой текст
4. Бот должен ответить

## Частые ошибки

### Ошибка: "Invalid token"

**Причина:** Токен неверный или бот не существует.

**Решение:**
1. Проверьте токен через `getMe`:
   ```powershell
   $token = "ВАШ_ТОКЕН"
   Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
   ```
2. Если ошибка - токен неверный

### Ошибка: "Webhook URL mismatch"

**Причина:** Webhook установлен на другой URL.

**Решение:**
1. Переустановите webhook с правильным URL
2. Убедитесь, что URL правильный: `https://find-origin.vercel.app/api/webhook`

### Ошибка: Бот не отвечает после переустановки

**Причина:** Токен на Vercel не совпадает с токеном webhook.

**Решение:**
1. Проверьте токен на Vercel
2. Проверьте токен webhook
3. Убедитесь, что они совпадают
4. Переразверните проект на Vercel

## Контрольный список

- [ ] Новый токен установлен на Vercel
- [ ] Webhook переустановлен с новым токеном
- [ ] Токен на Vercel совпадает с токеном webhook
- [ ] Проект переразвернут на Vercel
- [ ] Отправлено тестовое сообщение боту
- [ ] Проверены логи Vercel на наличие ошибок

## Важно

**Токен на Vercel и токен webhook должны совпадать!**

Если они не совпадают:
- Endpoint получит запрос от Telegram
- Но не сможет отправить ответ, потому что использует другой токен
- Бот не будет отвечать

## Быстрое решение

1. Узнайте новый токен из Vercel
2. Запустите:
   ```powershell
   .\reinstall-webhook.ps1 -Token "ВАШ_НОВЫЙ_ТОКЕН"
   ```
3. Отправьте сообщение боту

