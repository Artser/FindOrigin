# Скрипт для проверки Google Custom Search API
# Используйте ваш реальный API ключ

Write-Host "Проверка Google Custom Search API..." -ForegroundColor Cyan
Write-Host ""

# ВАЖНО: Замените на ваш реальный API ключ
$apiKey = "ВАШ_API_КЛЮЧ_ЗДЕСЬ"
$engineId = "c3818dfb6fe534e25"
$query = "test"

# Проверка, что ключ не является плейсхолдером
if ($apiKey -eq "ВАШ_API_КЛЮЧ_ЗДЕСЬ" -or $apiKey -match "ваш.*ключ") {
    Write-Host "⚠️ ВНИМАНИЕ: Замените `$apiKey на ваш реальный API ключ!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Как получить API ключ:" -ForegroundColor Cyan
    Write-Host "1. В Google Cloud Console нажмите 'Show key' рядом с вашим API ключом"
    Write-Host "2. Скопируйте ключ"
    Write-Host "3. Вставьте его в этот скрипт вместо 'ВАШ_API_КЛЮЧ_ЗДЕСЬ'"
    Write-Host ""
    Write-Host "Или используйте переменную окружения:" -ForegroundColor Cyan
    Write-Host "  `$apiKey = `$env:GOOGLE_SEARCH_API_KEY"
    exit 1
}

# Формирование URL
$url = "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$engineId&q=$query"

Write-Host "Параметры запроса:" -ForegroundColor Gray
Write-Host "  API Key: $($apiKey.Substring(0, [Math]::Min(20, $apiKey.Length)))..." -ForegroundColor Gray
Write-Host "  Engine ID: $engineId" -ForegroundColor Gray
Write-Host "  Query: $query" -ForegroundColor Gray
Write-Host ""

try {
    Write-Host "Отправка запроса..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri $url -Method GET -ErrorAction Stop
    
    Write-Host "✅ УСПЕХ! API работает правильно!" -ForegroundColor Green
    Write-Host ""
    
    # Парсим JSON ответ
    $json = $response.Content | ConvertFrom-Json
    
    if ($json.items) {
        Write-Host "Найдено результатов: $($json.items.Count)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Первые результаты:" -ForegroundColor Cyan
        Write-Host ""
        
        $json.items | Select-Object -First 3 | ForEach-Object {
            Write-Host "  📄 $($_.title)" -ForegroundColor White
            Write-Host "     🔗 $($_.link)" -ForegroundColor Gray
            if ($_.snippet) {
                Write-Host "     📝 $($_.snippet.Substring(0, [Math]::Min(100, $_.snippet.Length)))..." -ForegroundColor DarkGray
            }
            Write-Host ""
        }
        
        Write-Host "✅ Все работает! Можно использовать в проекте." -ForegroundColor Green
    } else {
        Write-Host "⚠️ API ответил, но результатов не найдено" -ForegroundColor Yellow
        Write-Host "Ответ: $($response.Content)" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "❌ ОШИБКА при запросе к API" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        $statusDescription = $_.Exception.Response.StatusDescription
        
        Write-Host "Код ошибки: $statusCode ($statusDescription)" -ForegroundColor Red
        Write-Host ""
        
        # Получаем детали ошибки
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            $errorJson = $responseBody | ConvertFrom-Json
            
            if ($errorJson.error) {
                Write-Host "Детали ошибки:" -ForegroundColor Yellow
                Write-Host "  Код: $($errorJson.error.code)" -ForegroundColor White
                Write-Host "  Сообщение: $($errorJson.error.message)" -ForegroundColor White
                
                if ($errorJson.error.errors) {
                    Write-Host "  Причина:" -ForegroundColor Yellow
                    $errorJson.error.errors | ForEach-Object {
                        Write-Host "    - $($_.message)" -ForegroundColor White
                    }
                }
            } else {
                Write-Host "Детали ошибки:" -ForegroundColor Yellow
                Write-Host $responseBody
            }
        } catch {
            Write-Host "Не удалось получить детали ошибки" -ForegroundColor Yellow
        }
        
        Write-Host ""
        
        if ($statusCode -eq 400) {
            Write-Host "Возможные причины ошибки 400:" -ForegroundColor Yellow
            Write-Host "  1. Неправильный API ключ" -ForegroundColor White
            Write-Host "  2. Неправильный Search Engine ID" -ForegroundColor White
            Write-Host "  3. Custom Search API не включен в проекте" -ForegroundColor White
        } elseif ($statusCode -eq 403) {
            Write-Host "Возможные причины ошибки 403:" -ForegroundColor Yellow
            Write-Host "  1. API ключ не привязан к Custom Search API" -ForegroundColor White
            Write-Host "  2. Превышен дневной лимит (100 запросов/день)" -ForegroundColor White
            Write-Host "  3. Биллинг не настроен (требуется для некоторых регионов)" -ForegroundColor White
            Write-Host "  4. API ключ имеет ограничения, блокирующие запрос" -ForegroundColor White
        } elseif ($statusCode -eq 429) {
            Write-Host "Превышен лимит запросов!" -ForegroundColor Yellow
            Write-Host "  Подождите до следующего дня или настройте биллинг" -ForegroundColor White
        }
    } else {
        Write-Host "Детали ошибки: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Проверьте:" -ForegroundColor Yellow
    Write-Host "  1. Правильность API ключа в Google Cloud Console" -ForegroundColor White
    Write-Host "  2. Что Custom Search API включен в проекте" -ForegroundColor White
    Write-Host "  3. Что Search Engine ID правильный: $engineId" -ForegroundColor White
    Write-Host "  4. Что API ключ ограничен к Custom Search API (как видно на скриншоте)" -ForegroundColor White
}

Write-Host ""
Write-Host "Для использования в проекте добавьте в .env.local:" -ForegroundColor Cyan
Write-Host "  GOOGLE_SEARCH_API_KEY=$apiKey" -ForegroundColor Gray
Write-Host "  GOOGLE_SEARCH_ENGINE_ID=$engineId" -ForegroundColor Gray


