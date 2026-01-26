# Script to test if Telegram is sending webhook requests

$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$webhookUrl = "https://find-origin.vercel.app/api/webhook"

Write-Host "=== Testing Webhook Delivery ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check webhook info
Write-Host "1. Checking webhook configuration..." -ForegroundColor Yellow
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
Write-Host "   Webhook URL: $($info.result.url)" -ForegroundColor $(if ($info.result.url -eq $webhookUrl) { "Green" } else { "Red" })
Write-Host "   Pending updates: $($info.result.pending_update_count)" -ForegroundColor Yellow

if ($info.result.last_error_date) {
    Write-Host "   [ERROR] Last error:" -ForegroundColor Red
    $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
    Write-Host "   Date: $errorDate" -ForegroundColor Red
    Write-Host "   Message: $($info.result.last_error_message)" -ForegroundColor Red
}

Write-Host ""

# 2. Test endpoint accessibility
Write-Host "2. Testing endpoint accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method GET -TimeoutSec 10
    Write-Host "   Endpoint is accessible" -ForegroundColor Green
    Write-Host "   Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "   ERROR: Cannot access endpoint" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 3. Check for pending updates
if ($info.result.pending_update_count -gt 0) {
    Write-Host "3. WARNING: There are $($info.result.pending_update_count) pending updates!" -ForegroundColor Yellow
    Write-Host "   This means Telegram tried to send updates but endpoint didn't respond correctly" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Solution: Delete and reinstall webhook" -ForegroundColor Yellow
    Write-Host "   Run: .\setup-webhook.ps1" -ForegroundColor Yellow
} else {
    Write-Host "3. No pending updates - good sign" -ForegroundColor Green
}

Write-Host ""

# 4. Recommendations
Write-Host "=== Recommendations ===" -ForegroundColor Cyan
Write-Host ""

if ($info.result.url -ne $webhookUrl) {
    Write-Host "1. Webhook URL is wrong!" -ForegroundColor Red
    Write-Host "   Run: .\setup-webhook.ps1" -ForegroundColor Yellow
    Write-Host ""
}

if ($info.result.last_error_date) {
    Write-Host "2. Webhook has errors!" -ForegroundColor Red
    Write-Host "   Check Vercel logs" -ForegroundColor Yellow
    Write-Host "   Make sure TELEGRAM_BOT_TOKEN is set on Vercel" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "3. If webhook is correct but bot doesn't respond:" -ForegroundColor Yellow
Write-Host "   a) Check Vercel Dashboard -> Deployments -> Logs" -ForegroundColor Gray
Write-Host "   b) Send /start to bot and immediately check logs" -ForegroundColor Gray
Write-Host "   c) Look for [WEBHOOK] entries in logs" -ForegroundColor Gray
Write-Host "   d) If no [WEBHOOK] entries - Telegram is not sending requests" -ForegroundColor Gray
Write-Host ""

Write-Host "4. Try deleting and reinstalling webhook:" -ForegroundColor Yellow
Write-Host "   $token = '$token'" -ForegroundColor Gray
Write-Host "   Invoke-RestMethod -Uri 'https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true' -Method GET" -ForegroundColor Gray
Write-Host "   Start-Sleep -Seconds 2" -ForegroundColor Gray
Write-Host "   Invoke-RestMethod -Uri 'https://api.telegram.org/bot$token/setWebhook?url=$webhookUrl' -Method GET" -ForegroundColor Gray
Write-Host ""
