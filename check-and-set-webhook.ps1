# Скрипт для проверки и установки Telegram webhook
# Использование: .\check-and-set-webhook.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$BotToken,
    
    [Parameter(Mandatory=$false)]
    [string]$VercelUrl = "https://find-origin.vercel.app"
)

# Попытка получить значения из .env.local
if (-not $BotToken) {
    Write-Host "Попытка прочитать TELEGRAM_BOT_TOKEN из .env.local..." -ForegroundColor Yellow
    
    if (Test-Path ".env.local") {
        $envContent = Get-Content ".env.local" -Raw
        $match = [regex]::Match($envContent, 'TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)')
        if ($match.Success) {
            $BotToken = $match.Groups[1].Value.Trim()
            Write-Host "Токен найден в .env.local" -ForegroundColor Green
        }
    }
}

if (-not $BotToken) {
    $BotToken = Read-Host "Введите TELEGRAM_BOT_TOKEN"
}

Write-Host ""
Write-Host "=== Проверка и установка Telegram Webhook ===" -ForegroundColor Cyan
Write-Host ""

# 1. Проверка информации о webhook
Write-Host "1. Проверка текущего webhook..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/getWebhookInfo"
    $currentUrl = $webhookInfo.result.url
    $expectedUrl = "$VercelUrl/api/webhook"
    
    Write-Host "   Текущий URL: $currentUrl" -ForegroundColor $(if ($currentUrl -eq $expectedUrl) { "Green" } else { "Yellow" })
    Write-Host "   Ожидаемый URL: $expectedUrl" -ForegroundColor Gray
    Write-Host "   Pending updates: $($webhookInfo.result.pending_update_count)" -ForegroundColor $(if ($webhookInfo.result.pending_update_count -eq 0) { "Green" } else { "Yellow" })
    
    if ($webhookInfo.result.last_error_date) {
        Write-Host "   ❌ Последняя ошибка webhook:" -ForegroundColor Red
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($webhookInfo.result.last_error_date).LocalDateTime
        Write-Host "      Дата: $errorDate" -ForegroundColor Red
        Write-Host "      Сообщение: $($webhookInfo.result.last_error_message)" -ForegroundColor Red
    }
    
    if ($currentUrl -ne $expectedUrl -or $currentUrl -eq "") {
        Write-Host ""
        Write-Host "   ⚠️ Webhook установлен неправильно или не установлен" -ForegroundColor Yellow
        Write-Host "   Установка правильного webhook..." -ForegroundColor Yellow
        
        # Удаляем старый webhook и pending updates
        Write-Host "   Удаление старого webhook..." -ForegroundColor Gray
        try {
            Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/deleteWebhook?drop_pending_updates=true" -Method GET | Out-Null
            Write-Host "   ✅ Старый webhook удален" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️ Не удалось удалить старый webhook (возможно, его не было)" -ForegroundColor Yellow
        }
        
        # Устанавливаем новый webhook
        Write-Host "   Установка нового webhook: $expectedUrl" -ForegroundColor Gray
        try {
            $setResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/setWebhook?url=$expectedUrl" -Method GET
            if ($setResult.ok) {
                Write-Host "   ✅ Webhook успешно установлен!" -ForegroundColor Green
                Write-Host "   URL: $expectedUrl" -ForegroundColor Green
            } else {
                Write-Host "   ❌ Ошибка установки webhook: $($setResult.description)" -ForegroundColor Red
                exit 1
            }
        } catch {
            Write-Host "   ❌ Ошибка при установке webhook: $_" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "   ✅ Webhook установлен правильно" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Ошибка при проверке webhook: $_" -ForegroundColor Red
    Write-Host "   Возможно, токен неправильный" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 2. Проверка доступности endpoint
Write-Host "2. Проверка доступности webhook endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$VercelUrl/api/webhook" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Endpoint доступен (статус: $($response.StatusCode))" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "   Ответ: $($content.message)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Endpoint недоступен или не отвечает" -ForegroundColor Red
    Write-Host "   Ошибка: $_" -ForegroundColor Yellow
    Write-Host "   Убедитесь, что проект развернут на Vercel" -ForegroundColor Yellow
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
Write-Host "=== Рекомендации ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Отправьте тестовое сообщение боту в Telegram" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Проверьте логи Vercel:" -ForegroundColor Yellow
Write-Host "   - Откройте Vercel Dashboard" -ForegroundColor Gray
Write-Host "   - Перейдите в ваш проект" -ForegroundColor Gray
Write-Host "   - Откройте последний деплой" -ForegroundColor Gray
Write-Host "   - Перейдите в раздел 'Logs'" -ForegroundColor Gray
Write-Host "   - Ищите записи с префиксом [WEBHOOK]" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Если логи не появляются:" -ForegroundColor Yellow
Write-Host "   - Убедитесь, что TELEGRAM_BOT_TOKEN установлен на Vercel" -ForegroundColor Gray
Write-Host "   - Переразверните проект после добавления переменных" -ForegroundColor Gray
Write-Host "   - Проверьте, что webhook URL правильный: $VercelUrl/api/webhook" -ForegroundColor Gray
Write-Host ""
Write-Host "=== Конец проверки ===" -ForegroundColor Cyan

