# Script for setting up Telegram webhook
# Использует токен из .env.local

# Попытка прочитать токен из .env.local
$envFile = ".env.local"
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)") {
        $token = $matches[1].Trim()
        Write-Host "Токен загружен из .env.local" -ForegroundColor Green
    } else {
        Write-Host "Токен не найден в .env.local" -ForegroundColor Yellow
        if ($env:TELEGRAM_BOT_TOKEN) {
            $token = $env:TELEGRAM_BOT_TOKEN
            Write-Host "Используется токен из переменной окружения TELEGRAM_BOT_TOKEN" -ForegroundColor Green
        } else {
            Write-Host "ОШИБКА: Токен не найден ни в .env.local, ни в переменных окружения!" -ForegroundColor Red
            Write-Host "Установите TELEGRAM_BOT_TOKEN в .env.local или через переменную окружения" -ForegroundColor Yellow
            exit 1
        }
    }
} else {
    Write-Host "Файл .env.local не найден" -ForegroundColor Yellow
    if ($env:TELEGRAM_BOT_TOKEN) {
        $token = $env:TELEGRAM_BOT_TOKEN
        Write-Host "Используется токен из переменной окружения TELEGRAM_BOT_TOKEN" -ForegroundColor Green
    } else {
        Write-Host "ОШИБКА: Токен не найден ни в .env.local, ни в переменных окружения!" -ForegroundColor Red
        Write-Host "Установите TELEGRAM_BOT_TOKEN в .env.local или через переменную окружения" -ForegroundColor Yellow
        exit 1
    }
}

$webhookUrl = "https://find-origin-nine.vercel.app/api/telegram"

Write-Host "=== Deleting old webhook ===" -ForegroundColor Cyan
try {
    $deleteResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET
    Write-Host "Old webhook deleted" -ForegroundColor Green
    Write-Host "Result: $($deleteResult | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "Error deleting webhook: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Setting up new webhook ===" -ForegroundColor Cyan
try {
    $setResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$webhookUrl" -Method GET
    if ($setResult.ok) {
        Write-Host "Webhook set successfully" -ForegroundColor Green
    } else {
        Write-Host "Error setting webhook" -ForegroundColor Red
    }
    Write-Host "Result: $($setResult | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "Error setting webhook: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Checking webhook status ===" -ForegroundColor Cyan
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
    
    Write-Host "Webhook URL: " -NoNewline
    Write-Host "$($info.result.url)" -ForegroundColor Green
    
    Write-Host "Pending updates: " -NoNewline
    Write-Host "$($info.result.pending_update_count)" -ForegroundColor Yellow
    
    if ($info.result.last_error_date) {
        Write-Host ""
        Write-Host "[ERROR] Last error:" -ForegroundColor Red
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
        Write-Host "  Date: $errorDate" -ForegroundColor Red
        Write-Host "  Message: $($info.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host ""
        Write-Host "Webhook set successfully and working without errors!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "=== Bot information ===" -ForegroundColor Cyan
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
    Write-Host "Bot name: $($botInfo.result.first_name)" -ForegroundColor Green
    Write-Host "Username: @$($botInfo.result.username)" -ForegroundColor Green
    
} catch {
    Write-Host "Error checking status: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Cyan
Write-Host "Now send /start command to the bot in Telegram to test." -ForegroundColor Yellow
