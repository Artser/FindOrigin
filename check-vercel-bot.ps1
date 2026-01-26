# Диагностика Telegram бота на Vercel
# Использование: .\check-vercel-bot.ps1 -BotToken "YOUR_TOKEN" -VercelUrl "https://your-app.vercel.app"

param(
    [Parameter(Mandatory=$true)]
    [string]$BotToken,
    
    [Parameter(Mandatory=$true)]
    [string]$VercelUrl
)

Write-Host "=== Диагностика Telegram бота на Vercel ===" -ForegroundColor Cyan
Write-Host ""

# 1. Проверка webhook
Write-Host "1. Проверка webhook..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/getWebhookInfo"
    $webhookUrl = $webhookInfo.result.url
    $pendingCount = $webhookInfo.result.pending_update_count
    $lastError = $webhookInfo.result.last_error_date
    
    if ($webhookUrl -like "*$VercelUrl*") {
        Write-Host "   ✅ Webhook URL правильный: $webhookUrl" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Webhook URL неправильный: $webhookUrl" -ForegroundColor Red
        Write-Host "   Ожидается: $VercelUrl/api/webhook" -ForegroundColor Yellow
    }
    
    if ($pendingCount -eq 0) {
        Write-Host "   ✅ Нет pending updates" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Есть $pendingCount pending updates" -ForegroundColor Yellow
        Write-Host "   Рекомендуется: удалить pending updates" -ForegroundColor Yellow
    }
    
    if ($lastError) {
        Write-Host "   ❌ Последняя ошибка:" -ForegroundColor Red
        Write-Host "      Дата: $(Get-Date -UnixTimeSeconds $lastError)" -ForegroundColor Red
        Write-Host "      Сообщение: $($webhookInfo.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host "   ✅ Ошибок нет" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Ошибка при проверке webhook: $_" -ForegroundColor Red
}

Write-Host ""

# 2. Проверка доступности endpoint
Write-Host "2. Проверка доступности webhook endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$VercelUrl/api/webhook" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Endpoint доступен (статус: $($response.StatusCode))" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "   Ответ: $($content | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Endpoint недоступен или не отвечает" -ForegroundColor Red
    Write-Host "   Ошибка: $_" -ForegroundColor Yellow
}

Write-Host ""

# 3. Проверка информации о боте
Write-Host "3. Проверка информации о боте..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/getMe"
    Write-Host "   ✅ Бот активен" -ForegroundColor Green
    Write-Host "   Имя: $($botInfo.result.first_name)" -ForegroundColor Gray
    Write-Host "   Username: @$($botInfo.result.username)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Ошибка при проверке бота" -ForegroundColor Red
    Write-Host "   Возможно, токен неправильный" -ForegroundColor Yellow
}

Write-Host ""

# 4. Рекомендации
Write-Host "=== Рекомендации ===" -ForegroundColor Cyan

if (-not ($webhookUrl -like "*$VercelUrl*")) {
    Write-Host "1. Установите webhook:" -ForegroundColor Yellow
    Write-Host "   Invoke-RestMethod -Uri `"https://api.telegram.org/bot$BotToken/setWebhook?url=$VercelUrl/api/webhook`" -Method GET" -ForegroundColor Gray
    Write-Host ""
}

if ($pendingCount -gt 0) {
    Write-Host "2. Удалите pending updates:" -ForegroundColor Yellow
    Write-Host "   Invoke-RestMethod -Uri `"https://api.telegram.org/bot$BotToken/deleteWebhook?drop_pending_updates=true`" -Method GET" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "3. Проверьте переменные окружения на Vercel:" -ForegroundColor Yellow
Write-Host "   - TELEGRAM_BOT_TOKEN" -ForegroundColor Gray
Write-Host "   - OPENROUTER_API_KEY или OPENAI_API_KEY" -ForegroundColor Gray
Write-Host "   - OPENAI_BASE_URL" -ForegroundColor Gray
Write-Host "   - Хотя бы один поисковый API (BING_SEARCH_API_KEY, GOOGLE_SEARCH_API_KEY, и т.д.)" -ForegroundColor Gray
Write-Host ""

Write-Host "4. После добавления переменных переразверните проект на Vercel" -ForegroundColor Yellow
Write-Host ""

Write-Host "=== Конец диагностики ===" -ForegroundColor Cyan




