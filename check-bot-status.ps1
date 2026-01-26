# Check if bot is accessible and not blocked
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Bot Status Check ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check bot info
Write-Host "1. Checking bot info..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getMe"
    if ($botInfo.ok) {
        Write-Host "   [OK] Bot is active" -ForegroundColor Green
        Write-Host "   Name: $($botInfo.result.first_name)" -ForegroundColor Gray
        Write-Host "   Username: @$($botInfo.result.username)" -ForegroundColor Gray
        Write-Host "   ID: $($botInfo.result.id)" -ForegroundColor Gray
        Write-Host "   Can join groups: $($botInfo.result.can_join_groups)" -ForegroundColor Gray
        Write-Host "   Can read all group messages: $($botInfo.result.can_read_all_group_messages)" -ForegroundColor Gray
    } else {
        Write-Host "   [ERROR] Cannot get bot info" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   [ERROR] Failed to get bot info" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Check webhook status
Write-Host "2. Checking webhook status..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getWebhookInfo"
    Write-Host "   URL: $($webhookInfo.result.url)" -ForegroundColor Gray
    Write-Host "   Pending updates: $($webhookInfo.result.pending_update_count)" -ForegroundColor Gray
    
    if ($webhookInfo.result.last_error_date) {
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($webhookInfo.result.last_error_date).LocalDateTime
        Write-Host "   [ERROR] Last error at: $errorDate" -ForegroundColor Red
        Write-Host "   Error: $($webhookInfo.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host "   [OK] No errors reported by Telegram" -ForegroundColor Green
    }
} catch {
    Write-Host "   [ERROR] Cannot get webhook info" -ForegroundColor Red
}

Write-Host ""

# 3. Instructions for manual check
Write-Host "=== Manual Check Instructions ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To check if bot is blocked in Telegram:" -ForegroundColor Yellow
Write-Host "1. Open Telegram app" -ForegroundColor White
Write-Host "2. Search for @$($botInfo.result.username)" -ForegroundColor White
Write-Host "3. Open chat with the bot" -ForegroundColor White
Write-Host "4. Try to send a message (e.g., '/start')" -ForegroundColor White
Write-Host "5. If message sends successfully, bot is NOT blocked" -ForegroundColor Green
Write-Host "6. If you see an error or cannot send, bot might be blocked" -ForegroundColor Red
Write-Host ""
Write-Host "Note: API cannot detect if YOU have blocked the bot." -ForegroundColor Yellow
Write-Host "This can only be checked manually in Telegram app." -ForegroundColor Yellow
Write-Host ""

