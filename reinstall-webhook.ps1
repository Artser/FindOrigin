# Script to reinstall webhook (delete and set again)

$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$webhookUrl = "https://find-origin.vercel.app/api/telegram"

Write-Host "=== Reinstalling Webhook ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Delete webhook
Write-Host "Step 1: Deleting old webhook..." -ForegroundColor Yellow
try {
    $deleteResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET
    if ($deleteResult.ok) {
        Write-Host "   Webhook deleted successfully" -ForegroundColor Green
    } else {
        Write-Host "   Warning: Delete result: $($deleteResult | ConvertTo-Json -Compress)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Error deleting webhook: $_" -ForegroundColor Red
}

Write-Host ""

# Step 2: Wait
Write-Host "Step 2: Waiting 3 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Write-Host "   Done" -ForegroundColor Green
Write-Host ""

# Step 3: Set new webhook
Write-Host "Step 3: Setting new webhook..." -ForegroundColor Yellow
try {
    $setResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$webhookUrl" -Method GET
    if ($setResult.ok) {
        Write-Host "   Webhook set successfully!" -ForegroundColor Green
        Write-Host "   URL: $webhookUrl" -ForegroundColor Green
    } else {
        Write-Host "   ERROR: Failed to set webhook" -ForegroundColor Red
        Write-Host "   Result: $($setResult | ConvertTo-Json -Compress)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ERROR: Exception setting webhook: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 4: Verify
Write-Host "Step 4: Verifying webhook..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
    
    if ($info.result.url -eq $webhookUrl) {
        Write-Host "   Webhook URL is correct" -ForegroundColor Green
    } else {
        Write-Host "   WARNING: Webhook URL mismatch!" -ForegroundColor Red
        Write-Host "   Expected: $webhookUrl" -ForegroundColor Yellow
        Write-Host "   Got: $($info.result.url)" -ForegroundColor Yellow
    }
    
    Write-Host "   Pending updates: $($info.result.pending_update_count)" -ForegroundColor Yellow
    
    if ($info.result.last_error_date) {
        Write-Host "   [ERROR] Last error:" -ForegroundColor Red
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
        Write-Host "   Date: $errorDate" -ForegroundColor Red
        Write-Host "   Message: $($info.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host "   No errors" -ForegroundColor Green
    }
} catch {
    Write-Host "   ERROR: Cannot verify webhook: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Make sure TELEGRAM_BOT_TOKEN is set on Vercel" -ForegroundColor Gray
Write-Host "2. Redeploy project on Vercel if you just added variables" -ForegroundColor Gray
Write-Host "3. Send /start to bot in Telegram" -ForegroundColor Gray
Write-Host "4. Check Vercel logs for [WEBHOOK] entries" -ForegroundColor Gray
Write-Host ""
