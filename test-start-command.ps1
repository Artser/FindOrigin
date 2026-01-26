# Script for checking /start command
# Checks webhook, token and logs

Write-Host "=== Checking /start command ===" -ForegroundColor Cyan

# Get token from environment variables
$token = $env:TELEGRAM_BOT_TOKEN
if (-not $token) {
    Write-Host "ERROR: TELEGRAM_BOT_TOKEN is not set in environment variables" -ForegroundColor Red
    Write-Host "Set token: `$env:TELEGRAM_BOT_TOKEN = 'YOUR_TOKEN'" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n1. Checking bot information..." -ForegroundColor Yellow
$botInfoUrl = "https://api.telegram.org/bot$token/getMe"
try {
    $botInfo = Invoke-RestMethod -Uri $botInfoUrl -Method Get
    if ($botInfo.ok) {
        Write-Host "   Bot found: @$($botInfo.result.username)" -ForegroundColor Green
        Write-Host "   Name: $($botInfo.result.first_name)" -ForegroundColor Green
    } else {
        Write-Host "   ERROR: Failed to get bot information" -ForegroundColor Red
    }
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Checking webhook..." -ForegroundColor Yellow
$webhookInfoUrl = "https://api.telegram.org/bot$token/getWebhookInfo"
try {
    $webhookInfo = Invoke-RestMethod -Uri $webhookInfoUrl -Method Get
    if ($webhookInfo.ok) {
        $webhook = $webhookInfo.result
        Write-Host "   URL: $($webhook.url)" -ForegroundColor $(if ($webhook.url) { "Green" } else { "Red" })
        Write-Host "   Pending updates: $($webhook.pending_update_count)" -ForegroundColor $(if ($webhook.pending_update_count -eq 0) { "Green" } else { "Yellow" })
        if ($webhook.last_error_date) {
            $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($webhook.last_error_date).DateTime
            Write-Host "   Last error: $errorDate" -ForegroundColor Red
            Write-Host "   Error message: $($webhook.last_error_message)" -ForegroundColor Red
        }
    } else {
        Write-Host "   ERROR: Failed to get webhook information" -ForegroundColor Red
    }
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Instructions:" -ForegroundColor Yellow
Write-Host "   - Send /start command to bot in Telegram" -ForegroundColor White
Write-Host "   - Check Vercel logs in Deployments -> Functions -> /api/webhook" -ForegroundColor White
Write-Host "   - Look for entries with prefixes [WEBHOOK] and [TELEGRAM]" -ForegroundColor White

Write-Host "`n=== Check completed ===" -ForegroundColor Cyan
