# Complete webhook fix script
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Complete Webhook Fix ===" -ForegroundColor Cyan
Write-Host ""

# 1. Delete webhook completely
Write-Host "1. Deleting webhook completely..." -ForegroundColor Yellow
try {
    $deleteResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/deleteWebhook?drop_pending_updates=true" -Method GET
    Write-Host "   [OK] Webhook deleted" -ForegroundColor Green
    Start-Sleep -Seconds 3
} catch {
    Write-Host "   [WARNING] Could not delete webhook: $_" -ForegroundColor Yellow
}

# 2. Verify webhook is deleted
Write-Host ""
Write-Host "2. Verifying webhook is deleted..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getWebhookInfo"
    if ($info.result.url -eq "") {
        Write-Host "   [OK] Webhook is deleted" -ForegroundColor Green
    } else {
        Write-Host "   [WARNING] Webhook still exists: $($info.result.url)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Cannot verify webhook deletion" -ForegroundColor Red
}

# 3. Test endpoint accessibility
Write-Host ""
Write-Host "3. Testing endpoint accessibility..." -ForegroundColor Yellow
$webhookUrl = "https://find-origin.vercel.app/api/webhook"
try {
    $testResponse = Invoke-WebRequest -Uri $webhookUrl -Method GET -ErrorAction Stop
    Write-Host "   [OK] Endpoint is accessible (Status: $($testResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Endpoint is not accessible" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    exit 1
}

# 4. Install webhook
Write-Host ""
Write-Host "4. Installing webhook..." -ForegroundColor Yellow
Write-Host "   URL: $webhookUrl" -ForegroundColor Gray
try {
    $setResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/setWebhook?url=$webhookUrl&drop_pending_updates=true" -Method GET
    if ($setResult.ok) {
        Write-Host "   [OK] Webhook installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] Failed to install webhook" -ForegroundColor Red
        Write-Host "   Error: $($setResult.description)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   [ERROR] Failed to install webhook" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 2

# 5. Verify webhook
Write-Host ""
Write-Host "5. Verifying webhook..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getWebhookInfo"
    Write-Host "   URL: $($info.result.url)" -ForegroundColor Gray
    Write-Host "   Pending updates: $($info.result.pending_update_count)" -ForegroundColor Gray
    
    if ($info.result.last_error_date) {
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
        Write-Host "   [ERROR] Last error at: $errorDate" -ForegroundColor Red
        Write-Host "   Error: $($info.result.last_error_message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "   This is the problem! Telegram cannot reach your webhook." -ForegroundColor Red
        Write-Host "   Possible causes:" -ForegroundColor Yellow
        Write-Host "   - Vercel endpoint is not responding correctly" -ForegroundColor Yellow
        Write-Host "   - SSL certificate issue" -ForegroundColor Yellow
        Write-Host "   - Timeout (endpoint takes too long to respond)" -ForegroundColor Yellow
    } else {
        Write-Host "   [OK] No errors reported by Telegram" -ForegroundColor Green
    }
    
    if ($info.result.url -ne $webhookUrl) {
        Write-Host "   [ERROR] Webhook URL mismatch!" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERROR] Cannot verify webhook" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Send /start to @MsDragonBot in Telegram" -ForegroundColor White
Write-Host "2. Immediately check Vercel Logs for [WEBHOOK] entries" -ForegroundColor White
Write-Host "3. If no logs appear, check getWebhookInfo again for errors" -ForegroundColor White
Write-Host ""

