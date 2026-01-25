# Исправление ошибки 403 от Yandex GPT API

## Проблема

Yandex GPT API возвращает ошибку **403 Forbidden**. Это означает проблему с доступом или биллингом.

## Решения

### Решение 1: Привяжите облако к биллинг-аккаунту (ВАЖНО!)

**Проблема:** Биллинг-аккаунт активен, но облако не привязано к нему.

**Как привязать:**

1. Откройте https://console.cloud.yandex.ru/
2. Выберите ваше облако (например, "Облако 1")
3. Перейдите в раздел **"Биллинг"** (в меню слева)
4. Нажмите **"Привязать платёжный аккаунт"**
5. Выберите ваш биллинг-аккаунт (например, "account-766")
6. Подтвердите привязку

**Требования:**
- В биллинг-аккаунте: роль `billing.accounts.owner` или `billing.accounts.editor`
- В облаке: роль `owner`

**Подробная инструкция:** См. `YANDEX_BILLING_LINK_CLOUD.md`

### Решение 2: Проверьте биллинг-аккаунт в Yandex Cloud

**ВАЖНО:** Даже для бесплатного использования нужен активный биллинг-аккаунт!

1. Откройте https://console.cloud.yandex.ru/billing
2. Убедитесь, что биллинг-аккаунт:
   - ✅ Создан
   - ✅ **Активирован** (зеленый значок "Active")
   - ✅ **Привязан к облаку** (см. Решение 1)

**Без активного биллинг-аккаунта И привязки к облаку API будет возвращать 403!**

### Решение 2: Проверьте права API ключа

1. Откройте https://console.cloud.yandex.ru/
2. Перейдите в **"Сервисные аккаунты"**
3. Выберите ваш сервисный аккаунт
4. Перейдите на вкладку **"Права"**
5. Убедитесь, что аккаунт имеет роль:
   - `ai.languageModels.user` (для использования Yandex GPT)
   - Или `editor` / `admin` на уровне каталога

### Решение 3: Используйте другой поисковый API

Вместо Yandex GPT для поиска можно использовать:

**Вариант A: Google Custom Search API**

Добавьте в `.env.local`:
```env
GOOGLE_SEARCH_API_KEY=ваш_ключ
GOOGLE_SEARCH_ENGINE_ID=ваш_id
```

**Вариант B: Bing Search API**

Добавьте в `.env.local`:
```env
BING_SEARCH_API_KEY=ваш_ключ
```

**Вариант C: SerpAPI**

Добавьте в `.env.local`:
```env
SERPAPI_KEY=ваш_ключ
```

**Приоритет поисковых API:**
1. Google Custom Search (если настроен)
2. Bing Search (если настроен)
3. SerpAPI (если настроен)
4. Yandex GPT (если настроен, но с обработкой ошибок)

### Решение 4: Временно отключите Yandex GPT для поиска

Если хотите использовать Yandex GPT только для AI-анализа (не для поиска), закомментируйте в `.env.local`:

```env
# YANDEX_CLOUD_API_KEY=ваш_yandex_cloud_api_ключ
# YANDEX_FOLDER_ID=b1g...
# YANDEX_AUTH_TYPE=Api-Key
```

И настройте другой поисковый API (Google, Bing или SerpAPI).

## Проверка после исправления

1. **Перезапустите сервер:**
   ```powershell
   # Остановите сервер (Ctrl+C)
   # Затем запустите снова:
   npm run dev
   ```

2. **Проверьте работу:**
   - Откройте `http://localhost:3000`
   - Выполните поиск
   - Ошибка 403 должна исчезнуть

## Детальная диагностика

### Проверка биллинг-аккаунта

1. Откройте https://console.cloud.yandex.ru/billing
2. Проверьте статус биллинг-аккаунта:
   - ✅ **Активен** - должно работать
   - ❌ **Неактивен** - нужно активировать
   - ❌ **Отсутствует** - нужно создать

### Проверка API ключа

Убедитесь, что:
- Ключ начинается с `AQVN...` или `AQAAA...`
- Ключ не истек
- Ключ имеет правильный тип (`Api-Key`, не `IAM` токен)

### Проверка через API напрямую

Можно протестировать Yandex GPT API напрямую:

```powershell
$apiKey = "ваш_yandex_cloud_api_ключ"
$folderId = "b1g..."
$body = @{
    modelUri = "gpt://$folderId/yandexgpt/latest"
    completionOptions = @{
        stream = $false
        temperature = 0.6
        maxTokens = 100
    }
    messages = @(
        @{
            role = "user"
            text = "Привет"
        }
    )
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Api-Key $apiKey"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "https://llm.api.cloud.yandex.net/foundationModels/v1/completion" -Method POST -Body $body -Headers $headers
    Write-Host "Успешно! API работает" -ForegroundColor Green
} catch {
    Write-Host "Ошибка: $_" -ForegroundColor Red
}
```

## Рекомендация

Если Yandex GPT API продолжает возвращать 403, **лучше использовать Google Custom Search API или Bing Search API** для поиска источников. Они более надежны и не требуют сложной настройки биллинга.

Yandex GPT можно оставить только для AI-анализа (если нужно), но для поиска лучше использовать специализированные поисковые API.

