# Решение ошибки 403 (Forbidden) в Google Custom Search API

## Возможные причины ошибки 403

### 1. Custom Search API не включен в проекте

**Решение:**
1. Перейдите в [Google Cloud Console](https://console.cloud.google.com/)
2. Выберите ваш проект
3. Перейдите в **APIs & Services** → **Library**
4. Найдите **"Custom Search API"**
5. Убедитесь, что статус **"Enabled"** (Включено)
6. Если не включено, нажмите **"Enable"**

### 2. API ключ имеет ограничения

**Решение:**
1. В Google Cloud Console перейдите в **APIs & Services** → **Credentials**
2. Найдите ваш API ключ и нажмите на него
3. Проверьте раздел **"API restrictions"**:
   - Если выбрано **"Restrict key"**, убедитесь, что **"Custom Search API"** включен в списке разрешенных API
   - Или временно выберите **"Don't restrict key"** для тестирования

### 3. Превышен дневной лимит

**Решение:**
- Бесплатный лимит: **100 запросов в день**
- Если превышен, подождите до следующего дня
- Или настройте биллинг для увеличения лимита

### 4. Неправильный API ключ

**Решение:**
1. Убедитесь, что используете правильный API ключ из нужного проекта
2. Проверьте, что ключ скопирован полностью, без пробелов
3. Создайте новый API ключ, если старый не работает

### 5. Биллинг не настроен (для некоторых регионов)

**Решение:**
1. Перейдите в **Billing** (Биллинг) в Google Cloud Console
2. Если биллинг не настроен, настройте его:
   - Нажмите **"Link a billing account"**
   - Добавьте способ оплаты
   - ⚠️ **Важно:** На бесплатном тарифе деньги не списываются

## Пошаговая проверка

### Шаг 1: Проверка включения API

```powershell
# Проверьте в браузере:
# https://console.cloud.google.com/apis/library/customsearch.googleapis.com
# Статус должен быть "Enabled"
```

### Шаг 2: Проверка ограничений API ключа

1. Перейдите в: https://console.cloud.google.com/apis/credentials
2. Найдите ваш API ключ
3. Нажмите на него
4. Проверьте раздел **"API restrictions"**

### Шаг 3: Тест с новым API ключом

1. Создайте новый API ключ:
   - **APIs & Services** → **Credentials** → **Create Credentials** → **API key**
2. Временно снимите все ограничения
3. Протестируйте с новым ключом

### Шаг 4: Проверка через браузер

Откройте в браузере (замените на ваши значения):

```
https://www.googleapis.com/customsearch/v1?key=ваш_google_api_ключ&cx=ваш_search_engine_id&q=test
```

Если в браузере работает, а в PowerShell нет - проблема в коде запроса.

## Альтернативное решение: Использовать Bing Search API

Если проблемы с Google API продолжаются, используйте **Bing Search API**:

1. Создайте Microsoft аккаунт (см. `AZURE_ACCOUNT_FIX.md`)
2. Создайте ресурс Bing Search в Azure
3. Получите API ключ
4. Добавьте в `.env.local`:
   ```env
   BING_SEARCH_API_KEY=ваш_bing_ключ
   ```

**Преимущества Bing Search API:**
- ✅ Работает в России
- ✅ 3,000 запросов в месяц бесплатно (вместо 100 в день)
- ✅ Проще настройка
- ✅ Меньше проблем с ограничениями

## Быстрая диагностика

Выполните эту команду для получения детальной информации об ошибке:

```powershell
$apiKey = "ваш_google_api_ключ"
$engineId = "ваш_search_engine_id"
$query = "test"
$url = "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$engineId&q=$query"

try {
    $response = Invoke-WebRequest -Uri $url -ErrorAction Stop
    Write-Host "✅ Успех!" -ForegroundColor Green
    $response.Content
} catch {
    Write-Host "❌ Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Детали ошибки:" -ForegroundColor Yellow
        Write-Host $responseBody
    }
}
```

Это покажет детальное сообщение об ошибке от Google API.


