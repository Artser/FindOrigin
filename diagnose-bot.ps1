# Script for diagnosing bot issues

$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$webhookUrl = "https://find-origin.vercel.app/api/telegram"

Write-Host "=== Bot Diagnosis ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check bot info
Write-Host "1. Checking bot info..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
    Write-Host "   Bot name: $($botInfo.result.first_name)" -ForegroundColor Green
    Write-Host "   Username: @$($botInfo.result.username)" -ForegroundColor Green
    Write-Host "   Bot ID: $($botInfo.result.id)" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: Cannot get bot info - token may be invalid" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Check webhook status
Write-Host "2. Checking webhook status..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
    Write-Host "   Webhook URL: $($info.result.url)" -ForegroundColor $(if ($info.result.url -eq $webhookUrl) { "Green" } else { "Red" })
    Write-Host "   Pending updates: $($info.result.pending_update_count)" -ForegroundColor Yellow
    
    if ($info.result.last_error_date) {
        Write-Host "   [ERROR] Last webhook error:" -ForegroundColor Red
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
        Write-Host "   Date: $errorDate" -ForegroundColor Red
        Write-Host "   Message: $($info.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host "   No errors in webhook" -ForegroundColor Green
    }
} catch {
    Write-Host "   ERROR: Cannot get webhook info" -ForegroundColor Red
}

Write-Host ""

# 3. Check if endpoint is accessible
Write-Host "3. Checking endpoint accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $webhookUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   Endpoint is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
        $content = $response.Content | ConvertFrom-Json
        Write-Host "   Response: $($content | ConvertTo-Json -Compress)" -ForegroundColor Gray
    } else {
        Write-Host "   Endpoint returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ERROR: Cannot access endpoint" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 4. Recommendations
Write-Host "=== Recommendations ===" -ForegroundColor Cyan
Write-Host ""

if ($info.result.url -ne $webhookUrl) {
    Write-Host "1. Webhook URL is not set correctly!" -ForegroundColor Red
    Write-Host "   Current: $($info.result.url)" -ForegroundColor Yellow
    Write-Host "   Expected: $webhookUrl" -ForegroundColor Yellow
    Write-Host "   Run: .\setup-webhook.ps1" -ForegroundColor Yellow
    Write-Host ""
}

if ($info.result.last_error_date) {
    Write-Host "2. Webhook has errors!" -ForegroundColor Red
    Write-Host "   Check Vercel logs for details" -ForegroundColor Yellow
    Write-Host "   Make sure TELEGRAM_BOT_TOKEN is set on Vercel" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "3. Check Vercel deployment:" -ForegroundColor Yellow
Write-Host "   - Go to Vercel Dashboard" -ForegroundColor Gray
Write-Host "   - Check if project is deployed" -ForegroundColor Gray
Write-Host "   - Check Environment Variables (TELEGRAM_BOT_TOKEN must be set)" -ForegroundColor Gray
Write-Host "   - Check deployment logs" -ForegroundColor Gray
Write-Host ""

Write-Host "4. Test the bot:" -ForegroundColor Yellow
Write-Host "   - Send /start to the bot in Telegram" -ForegroundColor Gray
Write-Host "   - Check Vercel logs for [WEBHOOK] entries" -ForegroundColor Gray
Write-Host ""
