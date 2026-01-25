# Как создать новый API ключ OpenRouter

## ⚠️ ВАЖНО: Безопасность

**НИКОГДА не добавляйте API ключи в публичные репозитории!**
- ❌ Не коммитьте `.env.local` в Git
- ❌ Не добавляйте ключи в документацию
- ❌ Не публикуйте ключи в коде
- ✅ Используйте только `.env.local` (уже в `.gitignore`)
- ✅ Для Vercel используйте Environment Variables в настройках проекта

## Пошаговая инструкция

### Шаг 1: Войдите на OpenRouter

1. Откройте https://openrouter.ai/
2. Войдите в свой аккаунт (или зарегистрируйтесь)

### Шаг 2: Перейдите в раздел API Keys

1. Нажмите на ваш профиль (правый верхний угол)
2. Выберите **"Keys"** или перейдите напрямую: https://openrouter.ai/keys

### Шаг 3: Создайте новый ключ

1. Нажмите кнопку **"Create Key"** или **"Создать ключ"**
2. Введите название ключа (например: "FindOrigin Bot")
3. Нажмите **"Create"** или **"Создать"**

### Шаг 4: Скопируйте ключ

1. **ВАЖНО:** Ключ показывается только один раз!
2. Скопируйте весь ключ (начинается с `sk-or-v1-`)
3. Сохраните его в безопасном месте

### Шаг 5: Добавьте ключ в проект

**ТОЛЬКО в файл `.env.local` (не в `.env` и не в Git!):**

```powershell
# Откройте .env.local в редакторе
notepad .env.local
```

Добавьте или обновите строки:

```env
OPENROUTER_API_KEY=ваш_новый_ключ_здесь
OPENAI_BASE_URL=https://openrouter.ai/api/v1
```

**Важно:**
- ✅ Файл должен называться `.env.local` (с точкой в начале)
- ✅ Нет пробелов вокруг знака `=`
- ✅ Нет кавычек вокруг значения
- ✅ Полный ключ скопирован

### Шаг 6: Добавьте ключ на Vercel

Если проект развернут на Vercel:

1. Откройте https://vercel.com
2. Выберите ваш проект `FindOrigin`
3. Перейдите в **Settings** → **Environment Variables**
4. Найдите `OPENROUTER_API_KEY`
5. Нажмите **Edit** и вставьте новый ключ
6. Сохраните изменения
7. **Переразверните проект** (Redeploy)

### Шаг 7: Перезапустите локальный сервер

```powershell
# Остановите сервер (Ctrl+C)
# Затем запустите снова:
npm run dev
```

## Проверка работы нового ключа

После добавления ключа проверьте:

1. **Веб-интерфейс:**
   - Откройте `http://localhost:3000`
   - Выполните поиск
   - AI-анализ должен работать

2. **Telegram бот:**
   - Отправьте сообщение боту
   - Бот должен ответить с AI-анализом

3. **Логи сервера:**
   - Должны быть сообщения "Запуск AI-анализа..."
   - Не должно быть ошибок 401

## Тестирование ключа через PowerShell

Можно протестировать новый ключ напрямую:

```powershell
# Замените на ваш новый ключ
$apiKey = "ваш_новый_openrouter_ключ"
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
    Write-Host "✅ Успешно! Новый ключ работает" -ForegroundColor Green
    Write-Host "Ответ: $($response.choices[0].message.content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Код ошибки: $statusCode" -ForegroundColor Red
    }
}
```

## Что делать со старым ключом

Старый ключ уже автоматически отключен OpenRouter, поэтому:
- ✅ Не нужно его удалять вручную
- ✅ Просто создайте новый ключ и используйте его
- ✅ Старый ключ больше не будет работать

## Безопасность в будущем

Чтобы избежать подобных проблем:

1. **Проверьте `.gitignore`:**
   - Убедитесь, что `.env.local` в `.gitignore`
   - Убедитесь, что `.env` в `.gitignore`

2. **Перед коммитом проверяйте:**
   ```powershell
   git status
   git diff
   ```
   - Убедитесь, что `.env.local` не в списке изменений

3. **Используйте `env.example`:**
   - В `env.example` используйте только плейсхолдеры
   - Никогда не добавляйте реальные ключи

4. **Проверяйте документацию:**
   - В файлах `.md` используйте только примеры
   - Никогда не добавляйте реальные ключи в документацию

## Полезные ссылки

- **OpenRouter Keys:** https://openrouter.ai/keys
- **OpenRouter Docs:** https://openrouter.ai/docs
- **Vercel Environment Variables:** https://vercel.com/docs/concepts/projects/environment-variables

