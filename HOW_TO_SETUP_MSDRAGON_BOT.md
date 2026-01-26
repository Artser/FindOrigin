# Инструкция по настройке бота @MsDragonBot

## Шаг 1: Получите токен от @BotFather

1. Откройте [@BotFather](https://t.me/BotFather) в Telegram
2. Отправьте команду `/mybots`
3. Выберите бота **@MsDragonBot**
4. Выберите **API Token**
5. Скопируйте токен (формат: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

## Шаг 2: Запустите скрипт настройки

Откройте PowerShell в папке проекта и выполните:

```powershell
.\setup-msdragon-bot-simple.ps1 "ВАШ_ТОКЕН_ОТ_BOTFATHER"
```

Например:
```powershell
.\setup-msdragon-bot-simple.ps1 "123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
```

Скрипт:
- ✅ Проверит, что токен принадлежит @MsDragonBot
- ✅ Удалит старый webhook
- ✅ Установит новый webhook на `https://find-origin.vercel.app/api/webhook`
- ✅ Покажет токен для копирования в Vercel

## Шаг 3: Установите токен на Vercel

1. Откройте [Vercel Dashboard](https://vercel.com/dashboard)
2. Выберите проект **FindOrigin**
3. Перейдите в **Settings** → **Environment Variables**
4. Найдите или создайте переменную `TELEGRAM_BOT_TOKEN`
5. **ВАЖНО:** Вставьте токен БЕЗ кавычек
   - ✅ Правильно: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`
   - ❌ Неправильно: `"123456789:ABCdefGHIjklMNOpqrsTUVwxyz"`
6. Выберите окружения: **Production**, **Preview**, **Development**
7. Нажмите **Save**

## Шаг 4: Переразверните проект

После сохранения переменной:

1. Перейдите в раздел **Deployments**
2. Найдите последний деплой
3. Нажмите на три точки (⋮) → **Redeploy**
4. Дождитесь завершения деплоя (1-2 минуты)

Или Vercel может автоматически переразвернуть проект после изменения переменных окружения.

## Шаг 5: Проверьте работу бота

1. Откройте Telegram
2. Найдите бота **@MsDragonBot**
3. Отправьте команду `/start`
4. Бот должен ответить приветственным сообщением

## Если бот не отвечает

### Проверьте логи Vercel:

1. Откройте проект на Vercel
2. Перейдите в **Deployments**
3. Выберите последний деплой
4. Откройте **Functions** → `/api/webhook`
5. Отправьте `/start` боту
6. Обновите логи и ищите записи с префиксами:
   - `[WEBHOOK]` - обработка webhook
   - `[TELEGRAM]` - отправка сообщений

### Проверьте webhook:

```powershell
.\check-webhook-status.ps1 -Token "ВАШ_ТОКЕН"
```

Должно показать:
- Webhook URL: `https://find-origin.vercel.app/api/webhook`
- Pending updates: `0`
- No errors

### Проверьте переменные окружения на Vercel:

Убедитесь, что:
- ✅ `TELEGRAM_BOT_TOKEN` установлен
- ✅ Токен БЕЗ кавычек
- ✅ Токен совпадает с токеном, который вы использовали для установки webhook

## Полезные команды

### Проверить информацию о боте:
```powershell
$token = "ВАШ_ТОКЕН"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
```

### Проверить webhook:
```powershell
$token = "ВАШ_ТОКЕН"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
```

### Удалить webhook:
```powershell
$token = "ВАШ_ТОКЕН"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true"
```


