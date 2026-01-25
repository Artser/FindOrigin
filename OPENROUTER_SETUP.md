# Настройка OpenRouter для AI-анализа

## Текущая конфигурация

В вашем `.env.local` настроен OpenRouter:

```env
OPENROUTER_API_KEY=sk-or-v1-ваш_ключ
OPENAI_BASE_URL="https://openrouter.ai/api/v1"
```

## Важно: убрать кавычки из OPENAI_BASE_URL

В файле `.env.local` уберите кавычки вокруг URL:

**Было:**
```env
OPENAI_BASE_URL="https://openrouter.ai/api/v1"
```

**Должно быть:**
```env
OPENAI_BASE_URL=https://openrouter.ai/api/v1
```

Кавычки могут вызвать проблемы при чтении переменной окружения.

## Проверка работы

После исправления:

1. **Перезапустите сервер:**
   ```powershell
   # Остановите сервер (Ctrl+C)
   # Затем запустите снова:
   npm run dev
   ```

2. **Проверьте бота:**
   - Отправьте команду `/start`
   - Отправьте любой текст
   - Бот должен выполнить AI-анализ

## Поддерживаемые модели через OpenRouter

По умолчанию используется `gpt-4o-mini`. OpenRouter поддерживает множество моделей:

- `openai/gpt-4o-mini` (по умолчанию)
- `openai/gpt-4o`
- `openai/gpt-3.5-turbo`
- `anthropic/claude-3-haiku`
- И многие другие

Чтобы изменить модель, отредактируйте `lib/openai.ts` и измените значение по умолчанию в функции `callOpenAI`.

## Альтернатива: использование OPENAI_API_KEY

Если хотите использовать прямой доступ к OpenAI (без OpenRouter), измените `.env.local`:

```env
OPENAI_API_KEY=sk-ваш_ключ_openai
OPENAI_BASE_URL=https://api.openai.com/v1
```

Код автоматически определит, какой ключ использовать.

## Устранение неполадок

### "OPENAI_API_KEY или OPENROUTER_API_KEY не установлен"

**Решение:**
- Убедитесь, что `OPENROUTER_API_KEY` установлен в `.env.local`
- Убедитесь, что строка не закомментирована (нет `#` в начале)
- Перезапустите сервер

### "OpenRouter API error (401): Unauthorized"

**Решение:**
- Проверьте правильность `OPENROUTER_API_KEY`
- Убедитесь, что ключ активен на https://openrouter.ai/keys

### "OpenRouter API error (429): Rate limit exceeded"

**Решение:**
- Превышен лимит запросов
- Проверьте баланс на https://openrouter.ai/
- Подождите или пополните баланс

## Дополнительные настройки OpenRouter

При необходимости можно добавить в `.env.local`:

```env
# Опционально: URL вашего сайта для статистики OpenRouter
OPENROUTER_REFERER=https://ваш-сайт.com
```

Это поможет отслеживать использование API в статистике OpenRouter.


