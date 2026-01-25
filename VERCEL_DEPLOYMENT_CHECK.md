# Проверка деплоя на Vercel

## Текущий статус

Webhook настроен на: `https://find-origin.vercel.app/api/webhook`

## Проблема: Бот не отвечает

Если webhook настроен, но бот не отвечает, проблема может быть в:

### 1. Проект не задеплоен или не обновлен

**Проверка:**
1. Откройте https://vercel.com/dashboard
2. Найдите проект `find-origin`
3. Проверьте последний деплой:
   - Должен быть статус "Ready" (зеленый)
   - Должна быть дата недавнего деплоя

**Решение:**
Если проект не задеплоен или устарел:
```powershell
# Убедитесь, что изменения закоммичены
git add .
git commit -m "Обновление кода"

# Задеплойте на Vercel
vercel --prod
```

Или через GitHub:
1. Закоммитьте и запушьте изменения
2. Vercel автоматически задеплоит проект

### 2. Переменные окружения не настроены на Vercel

**ВАЖНО:** Переменные окружения из `.env.local` не автоматически переносятся на Vercel!

**Проверка:**
1. Откройте https://vercel.com/dashboard
2. Выберите проект `find-origin`
3. Перейдите в **Settings** → **Environment Variables**
4. Проверьте наличие всех необходимых переменных:
   - `TELEGRAM_BOT_TOKEN`
   - `OPENROUTER_API_KEY` или `OPENAI_API_KEY`
   - `OPENAI_BASE_URL` (если используется OpenRouter)
   - `GOOGLE_SEARCH_API_KEY` и `GOOGLE_SEARCH_ENGINE_ID` (если используется)
   - `YANDEX_CLOUD_API_KEY` и `YANDEX_FOLDER_ID` (если используется)

**Решение:**
Добавьте все необходимые переменные в Vercel:
1. Settings → Environment Variables
2. Нажмите "Add New"
3. Добавьте каждую переменную:
   - **Name:** `TELEGRAM_BOT_TOKEN`
   - **Value:** ваш токен
   - **Environment:** Production, Preview, Development (выберите все)
4. Повторите для всех переменных

### 3. Проверка логов на Vercel

**Как проверить:**
1. Откройте https://vercel.com/dashboard
2. Выберите проект `find-origin`
3. Перейдите в раздел **Functions**
4. Выберите функцию `/api/webhook`
5. Просмотрите логи:
   - Должны быть запросы от Telegram
   - Должны быть логи обработки
   - Если есть ошибки, они будут видны

### 4. Тестирование webhook

**Проверка доступности:**
```powershell
# Проверьте, что endpoint доступен
Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method GET
```

Должен вернуться JSON с `status: "ok"`

**Проверка обработки запросов:**
1. Отправьте сообщение боту
2. Проверьте логи на Vercel (Functions → /api/webhook)
3. Должны быть логи обработки запроса

## Быстрое решение

### Шаг 1: Добавьте переменные окружения на Vercel

1. Откройте https://vercel.com/dashboard
2. Выберите проект → Settings → Environment Variables
3. Добавьте все переменные из `.env.local`:
   ```
   TELEGRAM_BOT_TOKEN=6436071741:AAFqCJ_EkbFKQQXJN5xCVb0Fh8h0wwSjuyI
   OPENROUTER_API_KEY=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
   OPENAI_BASE_URL=https://openrouter.ai/api/v1
   GOOGLE_SEARCH_API_KEY=ваш_ключ
   GOOGLE_SEARCH_ENGINE_ID=ваш_id
   ```

### Шаг 2: Перезадеплойте проект

После добавления переменных:
1. Перейдите в раздел **Deployments**
2. Нажмите на последний деплой
3. Нажмите **Redeploy** (или задеплойте заново через `vercel --prod`)

### Шаг 3: Проверьте работу

1. Отправьте боту команду `/start`
2. Бот должен ответить
3. Проверьте логи на Vercel, если не отвечает

## Проверка переменных окружения

Можно проверить, какие переменные доступны в функции:

Создайте временный endpoint для проверки (только для отладки!):

```typescript
// app/api/debug-env/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    hasTelegramToken: !!process.env.TELEGRAM_BOT_TOKEN,
    hasOpenRouterKey: !!process.env.OPENROUTER_API_KEY,
    hasOpenAIKey: !!process.env.OPENAI_API_KEY,
    // НЕ возвращайте сами ключи!
  });
}
```

Затем проверьте:
```
https://find-origin.vercel.app/api/debug-env
```

**ВАЖНО:** Удалите этот endpoint после проверки!

## Типичные проблемы

### "TELEGRAM_BOT_TOKEN не установлен"
- Переменная не добавлена на Vercel
- Или добавлена только для Production, а используется Preview

### "OPENAI_API_KEY или OPENROUTER_API_KEY не установлен"
- Переменная не добавлена на Vercel
- Или неправильное имя переменной

### Бот не отвечает вообще
- Проверьте логи на Vercel
- Убедитесь, что проект задеплоен
- Убедитесь, что webhook URL правильный

## После исправления

1. Перезадеплойте проект на Vercel
2. Проверьте логи на Vercel
3. Отправьте сообщение боту
4. Бот должен ответить


