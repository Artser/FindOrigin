# Быстрое исправление проблем с ботом

## Шаг 1: Проверьте, что сервер запущен

```powershell
npm run dev
```

Сервер должен быть доступен на `http://localhost:3000`

## Шаг 2: Проверьте переменные окружения

Откройте файл `.env.local` и убедитесь, что установлены:

```env
# Обязательно
TELEGRAM_BOT_TOKEN=ваш_токен
OPENAI_API_KEY=sk-ваш_ключ

# Хотя бы один поисковый API
GOOGLE_SEARCH_API_KEY=ваш_ключ
GOOGLE_SEARCH_ENGINE_ID=ваш_id

# ИЛИ
YANDEX_CLOUD_API_KEY=AQVN...
YANDEX_FOLDER_ID=b1g...
YANDEX_AUTH_TYPE=Api-Key
```

**ВАЖНО:** После изменения `.env.local` перезапустите сервер (Ctrl+C, затем `npm run dev`)

## Шаг 3: Настройте webhook

### Для локальной разработки (через ngrok):

1. **Установите ngrok** (если еще не установлен):
   - Скачайте с https://ngrok.com/download
   - Распакуйте в папку

2. **Запустите ngrok** в отдельном терминале:
   ```powershell
   ngrok http 3000
   ```

3. **Скопируйте URL** (например: `https://abc123.ngrok.io`)

4. **Установите webhook**:
   - Откройте в браузере:
   ```
   http://localhost:3000/api/set-webhook?url=https://abc123.ngrok.io/api/webhook
   ```
   - Или через PowerShell:
   ```powershell
   $ngrokUrl = "https://abc123.ngrok.io"
   Invoke-WebRequest -Uri "http://localhost:3000/api/set-webhook?url=$ngrokUrl/api/webhook"
   ```

### Для продакшена (Vercel):

1. Деплойте проект на Vercel
2. Установите webhook:
   ```
   https://ваш-домен.vercel.app/api/set-webhook?url=https://ваш-домен.vercel.app/api/webhook
   ```

## Шаг 4: Проверьте работу бота

1. Откройте Telegram
2. Найдите вашего бота
3. Отправьте команду `/start`
4. Бот должен ответить приветствием

## Шаг 5: Проверьте логи

Если бот не отвечает, проверьте консоль, где запущен `npm run dev`:
- Там должны быть ошибки (красным цветом)
- Скопируйте текст ошибки

## Типичные ошибки и решения

### "OPENAI_API_KEY не установлен"
- Проверьте, что `OPENAI_API_KEY` есть в `.env.local`
- Убедитесь, что строка не закомментирована (нет `#` в начале)
- Перезапустите сервер

### "Не настроен ни один поисковый API"
- Настройте хотя бы один поисковый API в `.env.local`
- Перезапустите сервер

### "403 Forbidden" или "401 Unauthorized"
- Проверьте правильность API ключей
- Проверьте биллинг в Google Cloud / Azure / Yandex Cloud

### Бот не отвечает вообще
- Проверьте, что webhook настроен правильно
- Убедитесь, что ngrok запущен (для локальной разработки)
- Проверьте, что сервер запущен и доступен

## Проверка webhook вручную

```powershell
# Замените YOUR_BOT_TOKEN на ваш токен
$token = "YOUR_BOT_TOKEN"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
```

Должен вернуться JSON с информацией о webhook.

## Если ничего не помогает

1. **Проверьте логи сервера** - там должны быть детальные ошибки
2. **Проверьте все переменные окружения** - убедитесь, что все установлены
3. **Перезапустите сервер** - после изменения `.env.local`
4. **Переустановите webhook** - удалите старый и создайте новый

## Полезные команды

```powershell
# Проверка работы сервера
Invoke-WebRequest -Uri "http://localhost:3000/api/webhook" -Method GET

# Удаление webhook (если нужно начать заново)
$token = "YOUR_BOT_TOKEN"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook"

# Проверка информации о боте
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
```





