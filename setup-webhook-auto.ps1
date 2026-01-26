# Automatic webhook setup script
# This script sets up webhook using the setup-webhook API endpoint

$webhookUrl = "https://find-origin.vercel.app/api/webhook"

Write-Host "=== Automatic Webhook Setup ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Method 1: Using setup-webhook API endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/setup-webhook" -Method GET -TimeoutSec 30
    if ($response.success) {
        Write-Host "Webhook set successfully via API!" -ForegroundColor Green
        Write-Host "Webhook URL: $($response.webhookUrl)" -ForegroundColor Green
    } else {
        Write-Host "Error: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "API endpoint not available or error occurred" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Method 2: Using direct Telegram API..." -ForegroundColor Yellow
    
    $token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
    
    # Delete old webhook
    Write-Host "Deleting old webhook..." -ForegroundColor Gray
    try {
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET | Out-Null
    } catch {
        # Ignore errors
    }
    
    Start-Sleep -Seconds 2
    
    # Set new webhook
    Write-Host "Setting new webhook..." -ForegroundColor Gray
    $result = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$webhookUrl" -Method GET
    
    if ($result.ok) {
        Write-Host "Webhook set successfully!" -ForegroundColor Green
        Write-Host "URL: $webhookUrl" -ForegroundColor Green
    } else {
        Write-Host "Error setting webhook" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Verification ===" -ForegroundColor Cyan
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"

Write-Host "Webhook URL: $($info.result.url)" -ForegroundColor $(if ($info.result.url -eq $webhookUrl) { "Green" } else { "Yellow" })
Write-Host "Pending updates: $($info.result.pending_update_count)" -ForegroundColor Yellow

if ($info.result.last_error_date) {
    Write-Host "ERROR: $($info.result.last_error_message)" -ForegroundColor Red
} else {
    Write-Host "No errors - webhook is ready!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Cyan
Write-Host "Send /start to bot in Telegram to test." -ForegroundColor Yellow
