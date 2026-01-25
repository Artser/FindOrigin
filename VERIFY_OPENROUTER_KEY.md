# Проверка настройки OpenRouter API ключа

## Текущий статус

Ваш API ключ на OpenRouter:
- ✅ **Статус:** Enabled (активен)
- ✅ **Последнее использование:** 2 янв. 2026 г., 17:23 GMT+3
- ✅ **Использовано кредитов:** $0,0186 (ключ работает!)
- ✅ **Лимит:** unlimited

## Проверка настройки в проекте

### 1. Убедитесь, что используется `.env.local` (не `.env`)

**ВАЖНО:** Next.js читает переменные из `.env.local`, а не из `.env`!

Проверьте:
- Файл должен называться `.env.local`
- Не `.env` (этот файл Next.js не читает для локальной разработки)

### 2. Проверьте формат в `.env.local`

Должно быть:
```env
OPENROUTER_API_KEY=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
OPENAI_BASE_URL=https://openrouter.ai/api/v1
```

**Важно:**
- ✅ Нет пробелов вокруг знака `=`
- ✅ Нет кавычек вокруг значения
- ✅ Строка не закомментирована (нет `#` в начале)
- ✅ Полный ключ скопирован (начинается с `sk-or-v1-`)

### 3. Перезапустите сервер

После проверки/изменения `.env.local`:

```powershell
# Остановите сервер (Ctrl+C)
# Затем запустите снова:
npm run dev
```

## Если ошибка 401 сохраняется

### Проверка 1: Полный ключ скопирован?

Убедитесь, что в `.env.local` указан **полный** ключ:
- Начинается с `sk-or-v1-`
- Длина около 60-70 символов
- Заканчивается на `...d14` (согласно скриншоту)

### Проверка 2: Правильный файл?

Убедитесь, что редактируете именно `.env.local`:
- В корне проекта (рядом с `package.json`)
- Название файла: `.env.local` (с точкой в начале)

### Проверка 3: Перезапуск сервера

**Обязательно** перезапустите сервер после изменения `.env.local`:
- Next.js загружает переменные окружения только при запуске
- Изменения в `.env.local` не применяются без перезапуска

## Тестирование API ключа

Можно протестировать ключ напрямую:

```powershell
$apiKey = "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"
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
    Write-Host "✅ Успешно! API работает" -ForegroundColor Green
    Write-Host "Ответ: $($response.choices[0].message.content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Код ошибки: $statusCode" -ForegroundColor Red
    }
}
```

## После исправления

1. Перезапустите сервер
2. Выполните поиск на `http://localhost:3000`
3. AI-анализ должен работать
4. Проверьте логи сервера - должны быть сообщения "Запуск AI-анализа..." и "AI-анализ завершен успешно"


