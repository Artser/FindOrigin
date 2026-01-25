# Детальная диагностика ошибки 403 в Google Custom Search API

## Пошаговая проверка

### Шаг 1: Проверка включения Custom Search API

1. Откройте: https://console.cloud.google.com/apis/library/customsearch.googleapis.com
2. Убедитесь, что статус **"Enabled"** (Включено)
3. Если не включено:
   - Нажмите **"Enable"**
   - Подождите 1-2 минуты

### Шаг 2: Проверка привязки API ключа

1. Откройте: https://console.cloud.google.com/apis/credentials
2. Найдите ваш API ключ
3. Нажмите на него
4. Проверьте раздел **"API restrictions"**:
   - Должно быть выбрано **"Restrict key"**
   - В списке должен быть выбран **"Custom Search API"**
   - Если нет - добавьте и сохраните

### Шаг 3: Проверка биллинга

1. Откройте: https://console.cloud.google.com/billing
2. Проверьте, есть ли привязанный биллинг аккаунт
3. Если нет:
   - Нажмите **"Link a billing account"**
   - Добавьте способ оплаты
   - ⚠️ **Важно:** На бесплатном тарифе деньги не списываются

### Шаг 4: Проверка квот

1. Откройте: https://console.cloud.google.com/apis/api/customsearch.googleapis.com/quotas
2. Проверьте, что не превышен дневной лимит (100 запросов/день)

### Шаг 5: Проверка через браузер

Откройте в браузере (замените на ваш ключ):

```
https://www.googleapis.com/customsearch/v1?key=ваш_google_api_ключ&cx=ваш_search_engine_id&q=test
```

Если в браузере тоже ошибка 403, значит проблема в настройках Google Cloud, а не в PowerShell.

## Возможные причины ошибки 403

### 1. Custom Search API не включен
**Решение:** Включите API в разделе Library

### 2. API ключ не привязан к Custom Search API
**Решение:** В настройках ключа выберите "Restrict key" и добавьте "Custom Search API"

### 3. Биллинг не настроен
**Решение:** Некоторые регионы требуют настройки биллинга даже для бесплатного тарифа

### 4. Превышен лимит запросов
**Решение:** Подождите до следующего дня или настройте биллинг

### 5. Проблемы с доступом в России
**Решение:** Используйте альтернативный API (Bing Search API)

## Альтернативное решение: Bing Search API

Если проблемы с Google API продолжаются, **настоятельно рекомендуется использовать Bing Search API**:

### Преимущества:
- ✅ Работает в России без проблем
- ✅ 3,000 запросов/месяц бесплатно (вместо 100/день)
- ✅ Проще настройка
- ✅ Меньше проблем с ограничениями

### Быстрая настройка:

1. **Создайте Microsoft аккаунт** (если еще нет):
   - https://account.microsoft.com/
   - Создайте аккаунт с email `@outlook.com`

2. **Создайте Azure аккаунт**:
   - https://portal.azure.com/
   - Войдите с Microsoft аккаунтом
   - Создайте бесплатный Azure аккаунт

3. **Создайте ресурс Bing Search**:
   - В Azure Portal: "Create a resource"
   - Найдите "Bing Search v7"
   - Выберите тариф "F1 Free" (3,000 запросов/месяц)
   - Создайте ресурс

4. **Получите API ключ**:
   - Откройте созданный ресурс
   - В разделе "Keys and Endpoint" скопируйте Key 1

5. **Добавьте в `.env.local`**:
   ```env
   BING_SEARCH_API_KEY=ваш_bing_ключ
   ```

6. **Готово!** Проект автоматически будет использовать Bing Search API

## Проверка работы Bing Search API

После настройки проверьте:

```powershell
$apiKey = "ваш_bing_ключ"
$query = "test"
$url = "https://api.bing.microsoft.com/v7.0/search?q=$query&mkt=ru-RU"
$headers = @{"Ocp-Apim-Subscription-Key" = $apiKey}

try {
    $response = Invoke-WebRequest -Uri $url -Headers $headers -ErrorAction Stop
    Write-Host "✅ Успех!" -ForegroundColor Green
    $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Ошибка: $($_.Exception.Message)" -ForegroundColor Red
}
```

## Рекомендация

**Для пользователей в России:** Используйте **Bing Search API** вместо Google Custom Search API:
- Меньше проблем с доступом
- Больше бесплатных запросов
- Проще настройка
- Работает надежно

Инструкция по настройке Bing Search API: см. файл `RUSSIA_ALTERNATIVES.md`


