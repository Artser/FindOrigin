# Детальное исправление ошибки 403 Yandex GPT API

## Проблема сохраняется после привязки облака

Если вы привязали облако к биллинг-аккаунту и добавили роли, но ошибка 403 все еще возникает, проверьте следующие моменты:

## Проверка 1: Правильность API ключа

### Тип ключа

API ключ должен быть **API ключ сервисного аккаунта**, а не:
- ❌ IAM токен
- ❌ OAuth токен
- ❌ SSH ключ

**Правильный формат:**
- Начинается с `AQVN...` или `AQAAA...`
- Длина около 40-50 символов

### Как проверить:

1. Откройте https://console.cloud.yandex.ru/
2. Перейдите в **"Сервисные аккаунты"**
3. Выберите ваш сервисный аккаунт
4. Перейдите на вкладку **"Ключи"**
5. Убедитесь, что ключ имеет тип **"API ключ"** (не "IAM токен")

## Проверка 2: Правильность YANDEX_FOLDER_ID

`YANDEX_FOLDER_ID` должен указывать на **каталог** в привязанном облаке.

### Как найти правильный ID:

1. Откройте https://console.cloud.yandex.ru/
2. Выберите ваше облако
3. Перейдите в **"Каталоги"**
4. Выберите нужный каталог
5. В URL или в настройках каталога найдите **ID каталога** (формат: `b1g...`)

**Важно:** ID каталога должен быть из того же облака, которое привязано к биллинг-аккаунту!

## Проверка 3: Права сервисного аккаунта

Сервисный аккаунт должен иметь права на использование Yandex GPT.

### Необходимые роли:

1. **На уровне каталога:**
   - `ai.languageModels.user` (минимум)
   - Или `editor` / `admin` (больше прав)

2. **На уровне облака:**
   - `ai.languageModels.user` или выше

### Как проверить и добавить:

1. Откройте https://console.cloud.yandex.ru/
2. Выберите ваше облако
3. Перейдите в **"Каталоги"** → выберите ваш каталог
4. Перейдите в **"Управление доступом"**
5. Найдите ваш сервисный аккаунт
6. Если его нет, нажмите **"Назначить роли"**
7. Добавьте роль `ai.languageModels.user` или `editor`

## Проверка 4: Активность биллинг-аккаунта

Убедитесь, что биллинг-аккаунт действительно активен:

1. Откройте https://console.cloud.yandex.ru/billing
2. Проверьте статус биллинг-аккаунта:
   - ✅ Должен быть зеленый значок **"Active"**
   - ❌ Если статус другой - активируйте аккаунт

## Проверка 5: Привязка облака к биллинг-аккаунту

Убедитесь, что облако действительно привязано:

1. Откройте https://console.cloud.yandex.ru/billing
2. Выберите ваш биллинг-аккаунт
3. В разделе **"Привязанные облака и сервисы"** должно быть ваше облако
4. Если облака нет - привяжите его (см. `YANDEX_BILLING_LINK_CLOUD.md`)

## Альтернативное решение: Использовать другой поисковый API

Если проблема с Yandex GPT API сохраняется, лучше использовать другой поисковый API:

### Вариант 1: Google Custom Search API (рекомендуется)

1. Получите API ключ и Search Engine ID (см. `GOOGLE_API_SETUP.md`)
2. Добавьте в `.env.local`:
   ```env
   GOOGLE_SEARCH_API_KEY=ваш_ключ
   GOOGLE_SEARCH_ENGINE_ID=ваш_id
   ```
3. Google API будет использоваться в первую очередь

### Вариант 2: Bing Search API

1. Получите API ключ (см. `RUSSIA_ALTERNATIVES.md`)
2. Добавьте в `.env.local`:
   ```env
   BING_SEARCH_API_KEY=ваш_ключ
   ```

### Вариант 3: SerpAPI

1. Зарегистрируйтесь на https://serpapi.com/
2. Получите API ключ
3. Добавьте в `.env.local`:
   ```env
   SERPAPI_KEY=ваш_ключ
   ```

## Тестирование Yandex GPT API напрямую

Проверьте, работает ли API напрямую:

```powershell
# Замените значения на ваши
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
} | ConvertTo-Json -Depth 10

$headers = @{
    "Authorization" = "Api-Key $apiKey"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "https://llm.api.cloud.yandex.net/foundationModels/v1/completion" -Method POST -Body $body -Headers $headers
    Write-Host "Успешно! API работает" -ForegroundColor Green
    Write-Host $response.result.alternatives[0].message.text
} catch {
    Write-Host "Ошибка: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Код ошибки: $statusCode" -ForegroundColor Red
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Ответ сервера: $responseBody" -ForegroundColor Yellow
    }
}
```

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
   - Ошибка должна исчезнуть

## Рекомендация

Если после всех проверок ошибка 403 сохраняется, **лучше использовать Google Custom Search API или Bing Search API** для поиска. Они более надежны и не требуют такой сложной настройки.

Yandex GPT можно оставить для будущего использования, но для поиска источников лучше использовать специализированные поисковые API.


