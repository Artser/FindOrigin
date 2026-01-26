# Diagnostic script for webhook issues
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Webhook Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check bot info
Write-Host "1. Checking bot info..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getMe"
    if ($botInfo.ok) {
        Write-Host "   [OK] Bot: @$($botInfo.result.username)" -ForegroundColor Green
    }
} catch {
    Write-Host "   [ERROR] Cannot get bot info" -ForegroundColor Red
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
    }
    
    if ($webhookInfo.result.pending_update_count -gt 0) {
        Write-Host "   [WARNING] There are $($webhookInfo.result.pending_update_count) pending updates!" -ForegroundColor Yellow
        Write-Host "   This might block new messages. Consider deleting webhook and reinstalling." -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Cannot get webhook info" -ForegroundColor Red
}

Write-Host ""

# 3. Check if webhook endpoint is accessible
Write-Host "3. Checking webhook endpoint accessibility..." -ForegroundColor Yellow
$webhookUrl = "https://find-origin.vercel.app/api/webhook"
try {
    $response = Invoke-WebRequest -Uri $webhookUrl -Method GET -ErrorAction Stop
    Write-Host "   [OK] Endpoint is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "   [ERROR] Cannot access endpoint" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
}

Write-Host ""

# 4. Check Vercel environment variables endpoint
Write-Host "4. Checking Vercel environment variables..." -ForegroundColor Yellow
try {
    $envCheck = Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/check-env" -Method GET
    Write-Host "   TELEGRAM_BOT_TOKEN: $(if ($envCheck.hasTelegramToken) { '[OK] Set' } else { '[ERROR] Missing' })" -ForegroundColor $(if ($envCheck.hasTelegramToken) { 'Green' } else { 'Red' })
    
    if (-not $envCheck.hasTelegramToken) {
        Write-Host "   [CRITICAL] TELEGRAM_BOT_TOKEN is not set on Vercel!" -ForegroundColor Red
        Write-Host "   Go to Vercel Dashboard -> Settings -> Environment Variables" -ForegroundColor Yellow
        Write-Host "   Set TELEGRAM_BOT_TOKEN to: $Token" -ForegroundColor Yellow
    } else {
        Write-Host "   [INFO] Token is set, but verify it matches: $Token" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [WARNING] Cannot check environment variables" -ForegroundColor Yellow
}

Write-Host ""

# 5. Recommendations
Write-Host "=== Recommendations ===" -ForegroundColor Cyan
Write-Host ""

if ($webhookInfo.result.pending_update_count -gt 0) {
    Write-Host "1. Delete webhook and reinstall to clear pending updates:" -ForegroundColor Yellow
    Write-Host "   .\setup-msdragon-bot-simple.ps1 `"$Token`"" -ForegroundColor White
    Write-Host ""
}

if (-not $envCheck.hasTelegramToken) {
    Write-Host "2. Set TELEGRAM_BOT_TOKEN on Vercel:" -ForegroundColor Yellow
    Write-Host "   - Go to Vercel Dashboard" -ForegroundColor White
    Write-Host "   - Settings -> Environment Variables" -ForegroundColor White
    Write-Host "   - Add: TELEGRAM_BOT_TOKEN = $Token" -ForegroundColor White
    Write-Host "   - Redeploy project" -ForegroundColor White
    Write-Host ""
}

Write-Host "3. After fixing, test by sending /start to @MsDragonBot" -ForegroundColor Yellow
Write-Host ""

