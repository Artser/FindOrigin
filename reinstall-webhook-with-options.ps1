# Reinstall webhook with all possible options
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Reinstalling Webhook with Options ===" -ForegroundColor Cyan
Write-Host ""

# 1. Delete webhook
Write-Host "1. Deleting old webhook..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/deleteWebhook?drop_pending_updates=true" -Method GET | Out-Null
    Write-Host "   [OK] Webhook deleted" -ForegroundColor Green
    Start-Sleep -Seconds 3
} catch {
    Write-Host "   [WARNING] Could not delete webhook" -ForegroundColor Yellow
}

# 2. Install webhook with allowed_updates
Write-Host ""
Write-Host "2. Installing webhook with allowed_updates..." -ForegroundColor Yellow
$webhookUrl = "https://find-origin.vercel.app/api/webhook"
$allowedUpdates = "message,edited_message,message_reaction"
$setUrl = "https://api.telegram.org/bot$Token/setWebhook?url=$webhookUrl&allowed_updates=$allowedUpdates&drop_pending_updates=true"

Write-Host "   URL: $webhookUrl" -ForegroundColor Gray
Write-Host "   Allowed updates: $allowedUpdates" -ForegroundColor Gray

try {
    $result = Invoke-RestMethod -Uri $setUrl -Method GET
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

Start-Sleep -Seconds 2

# 3. Verify webhook
Write-Host ""
Write-Host "3. Verifying webhook..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getWebhookInfo"
    Write-Host "   URL: $($info.result.url)" -ForegroundColor Gray
    Write-Host "   Pending updates: $($info.result.pending_update_count)" -ForegroundColor Gray
    Write-Host "   Allowed updates: $($info.result.allowed_updates -join ', ')" -ForegroundColor Gray
    
    if ($info.result.last_error_date) {
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
        Write-Host "   [ERROR] Last error at: $errorDate" -ForegroundColor Red
        Write-Host "   Error: $($info.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host "   [OK] No errors reported by Telegram" -ForegroundColor Green
    }
} catch {
    Write-Host "   [ERROR] Cannot verify webhook" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Send /start to @MsDragonBot" -ForegroundColor White
Write-Host "2. Check Vercel Logs for [WEBHOOK] entries" -ForegroundColor White
Write-Host "3. If still no logs, the issue is that Telegram is not sending requests" -ForegroundColor Yellow
Write-Host ""

