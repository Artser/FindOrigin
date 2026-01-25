# Скрипт для проверки работы бота

Write-Host "=== Проверка бота FindOrigin ===" -ForegroundColor Cyan
Write-Host ""

# Проверка 1: Сервер запущен?
Write-Host "1. Проверка сервера..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/webhook" -Method GET -TimeoutSec 2 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] Сервер запущен на http://localhost:3000" -ForegroundColor Green
    }
} catch {
    Write-Host "   [ОШИБКА] Сервер НЕ запущен" -ForegroundColor Red
    Write-Host "   Запустите сервер: npm run dev" -ForegroundColor Yellow
    exit 1
}

# Проверка 2: Переменные окружения
Write-Host ""
Write-Host "2. Проверка переменных окружения..." -ForegroundColor Yellow
if (Test-Path ".env.local") {
    $content = Get-Content ".env.local" -Raw
    
    # Проверка TELEGRAM_BOT_TOKEN
    if ($content -match "TELEGRAM_BOT_TOKEN\s*=\s*([^\s#`"]+)") {
        Write-Host "   [OK] TELEGRAM_BOT_TOKEN установлен" -ForegroundColor Green
        $token = $matches[1]
    } else {
        Write-Host "   [ОШИБКА] TELEGRAM_BOT_TOKEN не найден" -ForegroundColor Red
        $token = $null
    }
    
    # Проверка API ключа
    if ($content -match "OPENROUTER_API_KEY\s*=\s*([^\s#`"]+)") {
        Write-Host "   [OK] OPENROUTER_API_KEY установлен" -ForegroundColor Green
    } elseif ($content -match "OPENAI_API_KEY\s*=\s*([^\s#`"]+)") {
        Write-Host "   [OK] OPENAI_API_KEY установлен" -ForegroundColor Green
    } else {
        Write-Host "   [ОШИБКА] API ключ не найден (нужен OPENROUTER_API_KEY или OPENAI_API_KEY)" -ForegroundColor Red
    }
    
    # Проверка поискового API
    $searchApiFound = $false
    if ($content -match "GOOGLE_SEARCH_API_KEY\s*=\s*([^\s#`"]+)") {
        Write-Host "   [OK] GOOGLE_SEARCH_API_KEY установлен" -ForegroundColor Green
        $searchApiFound = $true
    }
    if ($content -match "YANDEX_CLOUD_API_KEY\s*=\s*([^\s#`"]+)") {
        Write-Host "   [OK] YANDEX_CLOUD_API_KEY установлен" -ForegroundColor Green
        $searchApiFound = $true
    }
    if ($content -match "BING_SEARCH_API_KEY\s*=\s*([^\s#`"]+)") {
        Write-Host "   [OK] BING_SEARCH_API_KEY установлен" -ForegroundColor Green
        $searchApiFound = $true
    }
    if ($content -match "SERPAPI_KEY\s*=\s*([^\s#`"]+)") {
        Write-Host "   [OK] SERPAPI_KEY установлен" -ForegroundColor Green
        $searchApiFound = $true
    }
    
    if (-not $searchApiFound) {
        Write-Host "   [ПРЕДУПРЕЖДЕНИЕ] Не найден ни один поисковый API" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [ОШИБКА] Файл .env.local не найден" -ForegroundColor Red
    $token = $null
}

# Проверка 3: Webhook
Write-Host ""
Write-Host "3. Проверка webhook..." -ForegroundColor Yellow
if ($token) {
    try {
        $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo" -ErrorAction Stop
        if ($webhookInfo.ok) {
            if ($webhookInfo.result.url) {
                Write-Host "   [OK] Webhook настроен: $($webhookInfo.result.url)" -ForegroundColor Green
                if ($webhookInfo.result.pending_update_count -gt 0) {
                    Write-Host "   [ПРЕДУПРЕЖДЕНИЕ] Есть $($webhookInfo.result.pending_update_count) необработанных обновлений" -ForegroundColor Yellow
                }
                if ($webhookInfo.result.last_error_message) {
                    Write-Host "   [ОШИБКА] Последняя ошибка: $($webhookInfo.result.last_error_message)" -ForegroundColor Red
                }
            } else {
                Write-Host "   [ОШИБКА] Webhook НЕ настроен" -ForegroundColor Red
                Write-Host "   Настройте webhook через ngrok или Vercel" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "   [ОШИБКА] Не удалось проверить webhook: $_" -ForegroundColor Red
    }
} else {
    Write-Host "   [ПРОПУЩЕНО] Токен не найден" -ForegroundColor Yellow
}

# Проверка 4: Тест API
Write-Host ""
Write-Host "4. Тест API поиска..." -ForegroundColor Yellow
try {
    $testBody = @{ query = "тест" } | ConvertTo-Json
    $testResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/search" -Method POST -Body $testBody -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
    if ($testResponse.StatusCode -eq 200) {
        Write-Host "   [OK] API поиска работает" -ForegroundColor Green
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "   [ОШИБКА] API поиска вернул ошибку: $statusCode" -ForegroundColor Red
    try {
        $errorContent = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "   Сообщение: $($errorContent.error)" -ForegroundColor Yellow
    } catch {
        Write-Host "   Детали: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Готово ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Следующие шаги:" -ForegroundColor Cyan
Write-Host "1. Проверьте логи сервера в терминале, где запущен npm run dev" -ForegroundColor Yellow
Write-Host "2. Откройте http://localhost:3000 в браузере для тестирования" -ForegroundColor Yellow
Write-Host "3. Отправьте команду /start боту в Telegram" -ForegroundColor Yellow

