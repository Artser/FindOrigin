# Исправление ошибки 401 от OpenRouter API

## Проблема

OpenRouter API возвращает ошибку **401: No cookie auth credentials found**.

## Решения

### Решение 1: Проверьте правильность API ключа

1. Убедитесь, что `OPENROUTER_API_KEY` правильный:
   - Ключ должен начинаться с `sk-or-v1-...`
   - Ключ должен быть активным на https://openrouter.ai/keys

2. Проверьте, что ключ не истек и не был отозван

### Решение 2: Убедитесь, что используется `.env.local`

**ВАЖНО:** Next.js читает переменные окружения из `.env.local`, а не из `.env`!

1. Убедитесь, что файл называется именно `.env.local` (не `.env`)
2. Убедитесь, что `OPENROUTER_API_KEY` установлен в `.env.local`
3. Перезапустите сервер после изменения `.env.local`

### Решение 3: Проверьте формат переменных в `.env.local`

Убедитесь, что в `.env.local` правильный формат:

```env
OPENROUTER_API_KEY=sk-or-v1-ваш_ключ_здесь
OPENAI_BASE_URL=https://openrouter.ai/api/v1
```

**Важно:**
- Нет пробелов вокруг знака `=`
- Нет кавычек вокруг значения (или уберите их, если есть)
- Строка не закомментирована (нет `#` в начале)

### Решение 4: Добавьте дополнительные заголовки (уже исправлено в коде)

Код уже обновлен для добавления необходимых заголовков:
- `HTTP-Referer` - URL вашего сайта
- `X-Title` - название приложения

Можно настроить в `.env.local`:
```env
OPENROUTER_REFERER=https://ваш-сайт.com
OPENROUTER_TITLE=FindOrigin Bot
```

### Решение 5: Проверьте баланс на OpenRouter

1. Откройте https://openrouter.ai/
2. Проверьте баланс
3. Убедитесь, что есть средства для использования API

## После исправления

1. **Перезапустите сервер:**
   ```powershell
   # Остановите сервер (Ctrl+C)
   # Затем запустите снова:
   npm run dev
   ```

2. **Проверьте работу:**
   - Откройте `http://localhost:3000`
   - Выполните поиск
   - AI-анализ должен работать

## Проверка API ключа

Можно протестировать API ключ напрямую:

```powershell
$apiKey = "sk-or-v1-ваш_ключ"
$body = @{
    model = "openai/gpt-4o-mini"
    messages = @(
        @{
            role = "user"
            content = "Привет"
        }
    )
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
    "HTTP-Referer" = "https://github.com"
    "X-Title" = "FindOrigin Bot"
}

try {
    $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/chat/completions" -Method POST -Body $body -Headers $headers
    Write-Host "Успешно! API работает" -ForegroundColor Green
    Write-Host $response.choices[0].message.content
} catch {
    Write-Host "Ошибка: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Код ошибки: $statusCode" -ForegroundColor Red
    }
}
```

## Альтернатива: Использовать прямой OpenAI API

Если OpenRouter не работает, можно использовать прямой доступ к OpenAI:

1. Получите API ключ на https://platform.openai.com/api-keys
2. Добавьте в `.env.local`:
   ```env
   OPENAI_API_KEY=sk-ваш_ключ_openai
   OPENAI_BASE_URL=https://api.openai.com/v1
   ```
3. Перезапустите сервер



