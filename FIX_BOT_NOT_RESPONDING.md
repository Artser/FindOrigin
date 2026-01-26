# Решение: Бот не отвечает

## Проблема
- ✅ Webhook установлен правильно
- ✅ Endpoint доступен
- ❌ Бот не отвечает на сообщения

## Возможные причины

### 1. Переменные окружения не установлены на Vercel

**КРИТИЧНО:** Если `TELEGRAM_BOT_TOKEN` не установлен на Vercel, endpoint не сможет обработать запросы.

**Проверка:**
1. Откройте Vercel Dashboard
2. Ваш проект → Settings → Environment Variables
3. Убедитесь, что `TELEGRAM_BOT_TOKEN` установлен
4. **ВАЖНО:** Значение должно совпадать с токеном из `.env.local`

**Решение:**
1. Добавьте `TELEGRAM_BOT_TOKEN` на Vercel
2. **ОБЯЗАТЕЛЬНО переразверните проект** после добавления переменных

### 2. Проект не переразвернут после добавления переменных

**Решение:**
1. Vercel Dashboard → ваш проект
2. Deployments → последний деплой → ⋮ → **Redeploy**
3. Или сделайте новый коммит и push

### 3. Endpoint возвращает ошибку

**Проверка:**
```powershell
# Тест POST запроса
$testBody = '{"update_id":999999,"message":{"message_id":1,"chat":{"id":123456789,"type":"private"},"text":"/start"}}'
Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method POST -Body $testBody -ContentType "application/json"
```

Если запрос возвращает ошибку - проверьте логи Vercel.

### 4. Telegram блокирует запросы из-за ошибок

**Проверка:**
```powershell
$token = "YOUR_BOT_TOKEN"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
if ($info.result.last_error_date) {
    Write-Host "Ошибка: $($info.result.last_error_message)"
}
```

**Решение:**
1. Удалите webhook
2. Подождите 1-2 минуты
3. Установите заново

### 5. Endpoint не может отправить ответ из-за отсутствия токена

Если `TELEGRAM_BOT_TOKEN` не установлен на Vercel, endpoint получит запрос, но не сможет отправить ответ пользователю.

## Пошаговое решение

### Шаг 1: Проверьте переменные окружения на Vercel

1. Откройте https://vercel.com/dashboard
2. Выберите проект **find-origin**
3. Settings → Environment Variables
4. Проверьте наличие:
   - `TELEGRAM_BOT_TOKEN` - **ОБЯЗАТЕЛЬНО**
   - `OPENROUTER_API_KEY` (или `OPENAI_API_KEY`)
   - `OPENAI_BASE_URL`
   - Поисковые API ключи

**Если `TELEGRAM_BOT_TOKEN` отсутствует:**
1. Добавьте его (значение из `.env.local`)
2. **ОБЯЗАТЕЛЬНО переразверните проект**

### Шаг 2: Переразверните проект

**Вариант A: Через Dashboard**
1. Deployments → последний деплой
2. Три точки (⋮) → **Redeploy**

**Вариант B: Через Git**
```powershell
git commit --allow-empty -m "Redeploy to apply environment variables"
git push
```

### Шаг 3: Переустановите webhook

```powershell
$token = "YOUR_BOT_TOKEN"

# Удалить
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET

# Подождать
Start-Sleep -Seconds 5

# Установить
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=https://find-origin.vercel.app/api/webhook" -Method GET
```

### Шаг 4: Проверьте статус webhook

```powershell
$token = "YOUR_BOT_TOKEN"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
Write-Host "URL: $($info.result.url)"
Write-Host "Pending: $($info.result.pending_update_count)"
if ($info.result.last_error_date) {
    Write-Host "ERROR: $($info.result.last_error_message)"
}
```

### Шаг 5: Отправьте тестовое сообщение

1. Откройте Telegram
2. Найдите бота @ArtserShowBot
3. Отправьте `/start`
4. Подождите 5-10 секунд

### Шаг 6: Проверьте логи Vercel

1. Vercel Dashboard → ваш проект
2. Deployments → последний деплой → Logs
3. Ищите ошибки или записи `[WEBHOOK]`

## Частые ошибки

### Ошибка: "TELEGRAM_BOT_TOKEN не установлен"

**Причина:** Переменная окружения не установлена на Vercel или проект не переразвернут.

**Решение:**
1. Добавьте `TELEGRAM_BOT_TOKEN` на Vercel
2. Переразверните проект

### Ошибка: "Telegram API error: 401"

**Причина:** Неверный токен.

**Решение:**
1. Проверьте, что токен правильный
2. Убедитесь, что токен установлен на Vercel
3. Переразверните проект

### Ошибка: "Telegram API error: 403"

**Причина:** Бот заблокирован или токен недействителен.

**Решение:**
1. Проверьте токен через `getMe`:
   ```powershell
   $token = "YOUR_BOT_TOKEN"
   Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
   ```
2. Если ошибка - токен неверный

## Контрольный список

- [ ] `TELEGRAM_BOT_TOKEN` установлен на Vercel
- [ ] Значение токена совпадает с `.env.local`
- [ ] Проект переразвернут после добавления переменных
- [ ] Webhook установлен правильно
- [ ] Нет ошибок в `getWebhookInfo`
- [ ] Endpoint доступен (GET запрос возвращает 200)
- [ ] Отправлено тестовое сообщение боту
- [ ] Проверены логи Vercel на наличие ошибок

## Если ничего не помогает

1. **Проверьте токен:**
   ```powershell
   $token = "YOUR_BOT_TOKEN"
   Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
   ```
   Должен вернуть информацию о боте.

2. **Проверьте, что endpoint работает:**
   ```powershell
   Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method GET
   ```
   Должен вернуть JSON с `status: "ok"`.

3. **Проверьте логи Vercel на ошибки:**
   - Deployments → последний деплой → Logs
   - Ищите ошибки (красные записи)

4. **Создайте новый webhook:**
   - Удалите старый
   - Подождите 2 минуты
   - Установите заново

5. **Проверьте, что проект развернут:**
   - Deployments → последний деплой должен быть успешен (зеленый)

## Самая частая причина

**90% проблем** - это отсутствие `TELEGRAM_BOT_TOKEN` на Vercel или проект не переразвернут после добавления переменных.

**Решение:**
1. Добавьте `TELEGRAM_BOT_TOKEN` на Vercel
2. **ОБЯЗАТЕЛЬНО переразверните проект**
3. Переустановите webhook

