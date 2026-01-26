# Setup script for @MsDragonBot
# This script helps configure the bot token and webhook

param(
    [Parameter(Mandatory=$false)]
    [string]$Token
)

Write-Host "=== @MsDragonBot Setup ===" -ForegroundColor Cyan
Write-Host ""

# If token not provided, ask for it
if (-not $Token) {
    Write-Host "Please provide the bot token for @MsDragonBot" -ForegroundColor Yellow
    Write-Host "You can get it from @BotFather in Telegram" -ForegroundColor Gray
    Write-Host ""
    $Token = Read-Host "Enter bot token"
}

if (-not $Token) {
    Write-Host "[ERROR] Token is required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "1. Checking bot info..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getMe"
    if ($botInfo.ok) {
        $botUsername = $botInfo.result.username
        Write-Host "   [OK] Bot found" -ForegroundColor Green
        Write-Host "   Name: $($botInfo.result.first_name)" -ForegroundColor Gray
        Write-Host "   Username: @$botUsername" -ForegroundColor Gray
        
        if ($botUsername -ne "MsDragonBot") {
            Write-Host ""
            Write-Host "   [WARNING] Bot username is @$botUsername, expected @MsDragonBot" -ForegroundColor Yellow
            $continue = Read-Host "   Continue anyway? (y/n)"
            if ($continue -ne "y") {
                exit 1
            }
        }
    } else {
        Write-Host "   [ERROR] Invalid token" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   [ERROR] Failed to get bot info" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Checking current webhook..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getWebhookInfo"
    if ($webhookInfo.ok) {
        $currentUrl = $webhookInfo.result.url
        Write-Host "   Current webhook URL: $currentUrl" -ForegroundColor Gray
        Write-Host "   Pending updates: $($webhookInfo.result.pending_update_count)" -ForegroundColor Gray
        
        if ($webhookInfo.result.last_error_date) {
            $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($webhookInfo.result.last_error_date).LocalDateTime
            Write-Host ""
            Write-Host "   [WARNING] Last webhook error:" -ForegroundColor Yellow
            Write-Host "   Date: $errorDate" -ForegroundColor Yellow
            Write-Host "   Message: $($webhookInfo.result.last_error_message)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   [WARNING] Could not get webhook info" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "3. Setting up webhook..." -ForegroundColor Yellow
$webhookUrl = "https://find-origin.vercel.app/api/webhook"
Write-Host "   Target URL: $webhookUrl" -ForegroundColor Gray

# Delete old webhook first
Write-Host "   Deleting old webhook..." -ForegroundColor Gray
try {
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/deleteWebhook?drop_pending_updates=true" -Method GET | Out-Null
    Write-Host "   [OK] Old webhook deleted" -ForegroundColor Green
} catch {
    Write-Host "   [WARNING] Could not delete old webhook (may not exist)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# Set new webhook
Write-Host "   Installing new webhook..." -ForegroundColor Gray
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
    } else {
        Write-Host "   [ERROR] Webhook URL mismatch!" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERROR] Could not verify webhook" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Next steps:" -ForegroundColor Yellow
Write-Host "1. Go to Vercel Dashboard -> Your Project -> Settings -> Environment Variables" -ForegroundColor White
Write-Host "2. Set TELEGRAM_BOT_TOKEN to: $Token" -ForegroundColor White
Write-Host "   (Make sure there are NO quotes around the token)" -ForegroundColor Gray
Write-Host "3. Redeploy the project on Vercel" -ForegroundColor White
Write-Host "4. Send /start command to @MsDragonBot in Telegram" -ForegroundColor White
Write-Host ""
Write-Host "Bot token (save this for Vercel):" -ForegroundColor Cyan
Write-Host $Token -ForegroundColor Green


