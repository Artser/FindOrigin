# Reinstall webhook with token from Vercel
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Reinstalling Webhook ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Checking bot info..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getMe"
    Write-Host "   [OK] Bot is active" -ForegroundColor Green
    Write-Host "   Name: $($botInfo.result.first_name)" -ForegroundColor Gray
    Write-Host "   Username: @$($botInfo.result.username)" -ForegroundColor Gray
} catch {
    Write-Host "   [ERROR] Invalid token or bot not found" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Deleting old webhook..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/deleteWebhook?drop_pending_updates=true" -Method GET | Out-Null
    Write-Host "   [OK] Old webhook deleted" -ForegroundColor Green
} catch {
    Write-Host "   [WARNING] Could not delete old webhook (may not exist)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "3. Installing new webhook..." -ForegroundColor Yellow
$webhookUrl = "https://find-origin.vercel.app/api/webhook"
Write-Host "   URL: $webhookUrl" -ForegroundColor Gray

try {
    $result = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/setWebhook?url=$webhookUrl" -Method GET
    if ($result.ok) {
        Write-Host "   [OK] Webhook installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] Failed to install webhook" -ForegroundColor Red
        Write-Host "   Error: $($result.description)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   [ERROR] Failed to install webhook" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "4. Verifying webhook..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getWebhookInfo"
    if ($info.result.url -eq $webhookUrl) {
        Write-Host "   [OK] Webhook verified!" -ForegroundColor Green
        Write-Host "   URL: $($info.result.url)" -ForegroundColor Gray
        Write-Host "   Pending updates: $($info.result.pending_update_count)" -ForegroundColor Gray
        
        if ($info.result.last_error_date) {
            $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
            Write-Host ""
            Write-Host "   [WARNING] Last error:" -ForegroundColor Yellow
            Write-Host "   Date: $errorDate" -ForegroundColor Yellow
            Write-Host "   Message: $($info.result.last_error_message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   [ERROR] Webhook URL mismatch!" -ForegroundColor Red
        Write-Host "   Expected: $webhookUrl" -ForegroundColor Yellow
        Write-Host "   Got: $($info.result.url)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Could not verify webhook" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Make sure TELEGRAM_BOT_TOKEN on Vercel matches this token" -ForegroundColor Gray
Write-Host "2. Make sure project is redeployed on Vercel" -ForegroundColor Gray
Write-Host "3. Send a test message to the bot" -ForegroundColor Gray

