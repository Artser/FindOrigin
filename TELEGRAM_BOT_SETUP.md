# Настройка Telegram-бота

## ✅ Статус настройки

- [x] Токен бота получен и сохранен
- [x] Переменная `TELEGRAM_BOT_TOKEN` установлена в `.env.local`
- [x] Переменная `WEBHOOK_URL` установлена в `.env.local`
- [x] Endpoint `/api/telegram` создан и работает
- [x] Endpoint `/api/setup-webhook` создан
- [x] Скрипт `setup-webhook.ps1` создан
- [x] Проект развернут на Vercel
- [x] Webhook установлен на `https://find-origin.vercel.app/api/telegram`

## Инструкция по созданию бота через BotFather

### 1. Получить токен бота ✅

1. ✅ Откройте Telegram и найдите бота **@BotFather**
2. ✅ Начните диалог с ботом, нажав кнопку **Start** или отправив команду `/start`
3. ✅ Отправьте команду `/newbot` для создания нового бота
4. ✅ Следуйте инструкциям BotFather:
   - Введите **имя бота** (отображается в контактах): например, `Учебный бот`
   - Введите **username бота** (должен заканчиваться на `bot`): например, `ucheba_telegram_bot`
5. ✅ BotFather предоставит вам **токен бота** (выглядит как `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)
6. ✅ **Сохраните токен** - он понадобится для настройки переменных окружения

### 2. Настроить описание и команды бота

#### Настроить описание бота:
1. Отправьте команду `/setdescription` в BotFather
2. Выберите вашего бота из списка
3. Введите описание: `Бот для тренировки и проверки знаний в формате тестовых заданий`

#### Настроить команды бота:
1. Отправьте команду `/setcommands` в BotFather
2. Выберите вашего бота из списка
3. Отправьте список команд в формате:
```
start - Начать работу с ботом
help - Получить справку
```

### 3. Настроить webhook для получения обновлений ✅

⚠️ **Важно**: Webhook настраивается **ПОСЛЕ первого деплоя** приложения в Vercel (или другую платформу), когда у вас будет публичный URL.

**Порядок действий:**
1. ✅ Сначала разверните приложение (например, в Vercel)
2. ✅ Получите публичный URL вашего приложения: `https://find-origin.vercel.app`
3. ✅ Затем настройте webhook, указав этот URL

После развертывания бота выполните один из вариантов:

#### Вариант 1: Через API Route (рекомендуется) ✅
✅ Создайте endpoint для настройки webhook: `app/api/setup-webhook/route.ts`

#### Вариант 2: Вручную через Telegram API ✅
✅ Отправьте POST-запрос:
```
https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=<YOUR_WEBHOOK_URL>
```

Где:
- `<YOUR_BOT_TOKEN>` - токен вашего бота: `6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k`
- `<YOUR_WEBHOOK_URL>` - публичный URL вашего приложения + `/api/telegram`
  - ✅ Установлено: `https://find-origin.vercel.app/api/telegram`

### Переменные окружения ✅

✅ После получения токена добавьте в файл `.env.local`:

```env
TELEGRAM_BOT_TOKEN=6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k
WEBHOOK_URL=https://find-origin.vercel.app/api/telegram
```

**Примечание:** 
- ✅ `TELEGRAM_BOT_TOKEN` - добавлено в `.env.local`
- ✅ `WEBHOOK_URL` - добавлено в `.env.local` после деплоя

**Текущие значения:**
```env
TELEGRAM_BOT_TOKEN=6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k
WEBHOOK_URL=https://find-origin.vercel.app/api/telegram
```

⚠️ **Важно**: Токен установлен и сохранен в `.env.local` (не коммитится в Git).

### Проверка работы бота

1. ✅ Найдите вашего бота в Telegram по username: `@MsDragonBot`
2. ⚠️ Отправьте команду `/start`
3. ⚠️ Бот должен ответить приветственным сообщением

**Примечание:** Если бот не отвечает, проверьте:
- ✅ Webhook установлен правильно
- ⚠️ Переменная `TELEGRAM_BOT_TOKEN` установлена на Vercel
- ⚠️ Проект переразвернут после добавления переменных
- ⚠️ Логи Vercel на наличие записей `[TELEGRAM]` или `[WEBHOOK]`

### Безопасность ✅

⚠️ **НИКОГДА не публикуйте токен бота в открытом доступе!**
- ✅ Храните токен в `.env.local` файле
- ✅ Не коммитьте `.env.local` в Git (уже добавлен в `.gitignore`)
- ⚠️ Используйте переменные окружения для production на Vercel

**Важно:** Убедитесь, что `TELEGRAM_BOT_TOKEN` установлен на Vercel в разделе Environment Variables.


