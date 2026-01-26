# Быстрое исправление webhook
param(
    [string]$VercelUrl = "https://find-origin.vercel.app"
)

Write-Host "=== Исправление Telegram Webhook ===" -ForegroundColor Cyan
Write-Host ""

# Получаем токен из .env.local
$token = $null
if (Test-Path ".env.local") {
    $envContent = Get-Content ".env.local" -Raw
    $match = [regex]::Match($envContent, 'TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)')
    if ($match.Success) {
        $token = $match.Groups[1].Value.Trim()
    }
}

if (-not $token) {
    $token = Read-Host "Введите TELEGRAM_BOT_TOKEN"
}

$webhookUrl = "$VercelUrl/api/webhook"

Write-Host "1. Проверка текущего webhook..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
    Write-Host "   Текущий URL: $($webhookInfo.result.url)" -ForegroundColor Gray
    Write-Host "   Pending updates: $($webhookInfo.result.pending_update_count)" -ForegroundColor Gray
    
    if ($webhookInfo.result.last_error_date) {
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($webhookInfo.result.last_error_date).LocalDateTime
        Write-Host "   [ERROR] Последняя ошибка: $errorDate" -ForegroundColor Red
        Write-Host "   Сообщение: $($webhookInfo.result.last_error_message)" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERROR] Не удалось получить информацию о webhook" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Удаление старого webhook..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET | Out-Null
    Write-Host "   [OK] Старый webhook удален" -ForegroundColor Green
} catch {
    Write-Host "   [WARNING] Не удалось удалить (возможно, его не было)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "3. Установка нового webhook..." -ForegroundColor Yellow
Write-Host "   URL: $webhookUrl" -ForegroundColor Gray
try {
    $setResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$webhookUrl" -Method GET
    if ($setResult.ok) {
        Write-Host "   [OK] Webhook успешно установлен!" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] Ошибка: $($setResult.description)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   [ERROR] Ошибка при установке: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "4. Проверка установленного webhook..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
    if ($webhookInfo.result.url -eq $webhookUrl) {
        Write-Host "   [OK] Webhook установлен правильно!" -ForegroundColor Green
        Write-Host "   URL: $($webhookInfo.result.url)" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] Webhook установлен неправильно!" -ForegroundColor Red
        Write-Host "   Ожидался: $webhookUrl" -ForegroundColor Yellow
        Write-Host "   Получен: $($webhookInfo.result.url)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Не удалось проверить webhook" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Готово ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Теперь отправьте сообщение боту в Telegram и проверьте логи Vercel." -ForegroundColor Yellow
Write-Host "Должны появиться записи с префиксом [WEBHOOK]." -ForegroundColor Yellow

