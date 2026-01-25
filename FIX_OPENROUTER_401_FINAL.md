# Финальное исправление ошибки 401 OpenRouter

## Проблема из логов

Из логов видно:
- ✅ `hasOpenAI: true, hasOpenRouter: true` - оба ключа найдены
- ❌ Но все равно ошибка 401: "No cookie auth credentials found"

## Причина

Код использует первый найденный ключ (`OPENAI_API_KEY || OPENROUTER_API_KEY`), но если `OPENAI_API_KEY` установлен (даже неправильно), он будет использован вместо `OPENROUTER_API_KEY`.

## Решение

Код обновлен для приоритета `OPENROUTER_API_KEY`:
- Если установлен `OPENROUTER_API_KEY` → используется он
- Иначе используется `OPENAI_API_KEY`

## Что нужно сделать

### 1. Убедитесь, что в `.env.local` правильный формат

```env
OPENROUTER_API_KEY=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
OPENAI_BASE_URL=https://openrouter.ai/api/v1
```

**Важно:**
- Если у вас есть и `OPENAI_API_KEY`, и `OPENROUTER_API_KEY`, `OPENROUTER_API_KEY` будет использован первым
- Если хотите использовать только OpenRouter, закомментируйте `OPENAI_API_KEY`:
  ```env
  # OPENAI_API_KEY=sk-...
  OPENROUTER_API_KEY=sk-or-v1-...
  ```

### 2. Перезапустите сервер

```powershell
# Остановите сервер (Ctrl+C)
# Затем запустите снова:
npm run dev
```

### 3. Проверьте логи

После перезапуска в логах должны быть сообщения:
```
OpenAI API конфигурация: { hasOpenRouterKey: true, hasOpenAIKey: true, isOpenRouter: true, usingKey: 'OPENROUTER_API_KEY' }
OpenAI API URL: https://openrouter.ai/api/v1
Отправка запроса к OpenAI API: { url: '...', model: 'openai/gpt-4o-mini', isOpenRouter: true }
```

Если видите `isOpenRouter: false` или `usingKey: 'OPENAI_API_KEY'` → проблема в логике выбора ключа.

### 4. Если ошибка сохраняется

Проверьте в логах:
- Какой ключ используется (`usingKey`)
- Какой URL используется (`OpenAI API URL`)
- Детали запроса (`Детали запроса`)
- Ответ сервера (`Ответ сервера`)

## Альтернативное решение

Если проблема сохраняется, временно отключите `OPENAI_API_KEY`:

1. Откройте `.env.local`
2. Закомментируйте `OPENAI_API_KEY`:
   ```env
   # OPENAI_API_KEY=sk-...
   OPENROUTER_API_KEY=sk-or-v1-...
   ```
3. Перезапустите сервер

Это гарантирует, что будет использован только `OPENROUTER_API_KEY`.


