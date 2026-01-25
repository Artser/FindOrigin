# Скрипт для проверки Google Custom Search API
# Замените значения ниже на ваши реальные ключи

# ВАЖНО: Замените эти значения на ваши реальные ключи!
$apiKey = "ВАШ_GOOGLE_API_КЛЮЧ_ЗДЕСЬ"
$engineId = "c3818dfb6fe534e25"
$query = "test"

# Проверка, что ключ не является плейсхолдером
if ($apiKey -eq "ВАШ_GOOGLE_API_КЛЮЧ_ЗДЕСЬ" -or $apiKey -match "ваш.*ключ") {
    Write-Host "ОШИБКА: Замените `$apiKey на ваш реальный Google API ключ!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Как получить API ключ:" -ForegroundColor Yellow
    Write-Host "1. Перейдите в Google Cloud Console: https://console.cloud.google.com/"
    Write-Host "2. APIs & Services -> Credentials"
    Write-Host "3. Найдите или создайте API ключ"
    Write-Host "4. Скопируйте ключ и вставьте в этот скрипт"
    exit 1
}

# Формирование URL
$url = "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$engineId&q=$query"

Write-Host "Проверка Google Custom Search API..." -ForegroundColor Cyan
Write-Host "API Key: $($apiKey.Substring(0, [Math]::Min(10, $apiKey.Length)))..." -ForegroundColor Gray
Write-Host "Engine ID: $engineId" -ForegroundColor Gray
Write-Host "Query: $query" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $url -Method GET -ErrorAction Stop
    $content = $response.Content | ConvertFrom-Json
    
    if ($content.items) {
        Write-Host "✅ УСПЕХ! API работает правильно!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Найдено результатов: $($content.items.Count)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Первые результаты:" -ForegroundColor Cyan
        $content.items | Select-Object -First 3 | ForEach-Object {
            Write-Host "  - $($_.title)" -ForegroundColor White
            Write-Host "    $($_.link)" -ForegroundColor Gray
        }
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
        
        if ($statusCode -eq 400) {
            Write-Host "Возможные причины:" -ForegroundColor Yellow
            Write-Host "1. Неправильный API ключ" -ForegroundColor White
            Write-Host "2. API ключ не имеет доступа к Custom Search API" -ForegroundColor White
            Write-Host "3. Неправильный Search Engine ID" -ForegroundColor White
            Write-Host "4. Custom Search API не включен в проекте" -ForegroundColor White
        } elseif ($statusCode -eq 403) {
            Write-Host "Возможные причины:" -ForegroundColor Yellow
            Write-Host "1. API ключ неверный или истек" -ForegroundColor White
            Write-Host "2. Превышен дневной лимит (100 запросов)" -ForegroundColor White
            Write-Host "3. API ключ имеет ограничения, блокирующие Custom Search API" -ForegroundColor White
        }
    } else {
        Write-Host "Детали ошибки: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Проверьте:" -ForegroundColor Yellow
    Write-Host "1. Правильность API ключа в Google Cloud Console" -ForegroundColor White
    Write-Host "2. Что Custom Search API включен в проекте" -ForegroundColor White
    Write-Host "3. Что Search Engine ID правильный: $engineId" -ForegroundColor White
}


