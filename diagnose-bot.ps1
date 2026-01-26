# Full bot diagnosis script
Write-Host "=== Full Telegram Bot Diagnosis ===" -ForegroundColor Cyan
Write-Host ""

# Get token from .env.local
$token = $null
if (Test-Path ".env.local") {
    $envContent = Get-Content ".env.local" -Raw
    $match = [regex]::Match($envContent, 'TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)')
    if ($match.Success) {
        $token = $match.Groups[1].Value.Trim()
    }
}

if (-not $token) {
    Write-Host "[ERROR] TELEGRAM_BOT_TOKEN not found in .env.local" -ForegroundColor Red
    Write-Host "Please add TELEGRAM_BOT_TOKEN to .env.local" -ForegroundColor Yellow
    exit 1
}

Write-Host "Token found (first 20 chars): $($token.Substring(0, [Math]::Min(20, $token.Length)))..." -ForegroundColor Gray
Write-Host ""

# 1. Check bot info
Write-Host "1. Checking bot info..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
    Write-Host "   [OK] Bot is active" -ForegroundColor Green
    Write-Host "   Name: $($botInfo.result.first_name)" -ForegroundColor Gray
    Write-Host "   Username: @$($botInfo.result.username)" -ForegroundColor Gray
} catch {
    Write-Host "   [ERROR] Failed to get bot info: $_" -ForegroundColor Red
    Write-Host "   This means the token is invalid!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Check webhook status
Write-Host "2. Checking webhook status..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
    $expectedUrl = "https://find-origin.vercel.app/api/webhook"
    
    Write-Host "   URL: $($info.result.url)" -ForegroundColor $(if ($info.result.url -eq $expectedUrl) { "Green" } else { "Red" })
    Write-Host "   Expected: $expectedUrl" -ForegroundColor Gray
    Write-Host "   Pending updates: $($info.result.pending_update_count)" -ForegroundColor Gray
    
    if ($info.result.url -ne $expectedUrl -and $info.result.url -ne "") {
        Write-Host "   [WARNING] Webhook URL mismatch!" -ForegroundColor Yellow
        Write-Host "   Webhook is set to different URL" -ForegroundColor Yellow
    }
    
    if ($info.result.last_error_date) {
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
        Write-Host ""
        Write-Host "   [CRITICAL] Last webhook error:" -ForegroundColor Red
        Write-Host "   Date: $errorDate" -ForegroundColor Red
        Write-Host "   Message: $($info.result.last_error_message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "   [SOLUTION] Reinstall webhook:" -ForegroundColor Yellow
        Write-Host "   .\reinstall-webhook.ps1 -Token `"$token`"" -ForegroundColor Gray
    } else {
        Write-Host "   [OK] No errors" -ForegroundColor Green
    }
} catch {
    Write-Host "   [ERROR] Failed to get webhook info: $_" -ForegroundColor Red
}

Write-Host ""

# 3. Check endpoint availability
Write-Host "3. Checking endpoint availability..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method GET -TimeoutSec 10
    Write-Host "   [OK] Endpoint is accessible, status: $($response.StatusCode)" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "   Response: $($content.message)" -ForegroundColor Gray
} catch {
    Write-Host "   [ERROR] Endpoint is not accessible: $_" -ForegroundColor Red
    Write-Host "   [SOLUTION] Check Vercel deployment status" -ForegroundColor Yellow
}

Write-Host ""

# 4. Test webhook endpoint
Write-Host "4. Testing webhook endpoint..." -ForegroundColor Yellow
$testBody = '{"update_id":999999,"message":{"message_id":1,"from":{"id":123456789,"is_bot":false,"first_name":"Test"},"chat":{"id":123456789,"type":"private"},"date":1738000000,"text":"/start"}}'
try {
    $response = Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method POST -Body $testBody -ContentType "application/json" -TimeoutSec 15
    Write-Host "   [OK] POST request sent, status: $($response.StatusCode)" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "   Response: $($content | ConvertTo-Json -Compress)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   [INFO] Check Vercel logs - should see [WEBHOOK] entries" -ForegroundColor Yellow
} catch {
    Write-Host "   [ERROR] Failed to send POST request: $_" -ForegroundColor Red
}

Write-Host ""

# 5. Recommendations
Write-Host "=== Recommendations ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check Vercel Environment Variables:" -ForegroundColor Yellow
Write-Host "   - Vercel Dashboard -> your project -> Settings -> Environment Variables" -ForegroundColor Gray
Write-Host "   - Make sure TELEGRAM_BOT_TOKEN is set" -ForegroundColor Gray
Write-Host "   - Make sure token value matches the token used for webhook" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Redeploy project on Vercel:" -ForegroundColor Yellow
Write-Host "   - Deployments -> last deployment -> ... -> Redeploy" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Reinstall webhook if needed:" -ForegroundColor Yellow
Write-Host "   .\reinstall-webhook.ps1 -Token `"$token`"" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Send test message to bot:" -ForegroundColor Yellow
Write-Host "   - Open Telegram" -ForegroundColor Gray
Write-Host "   - Find bot @$($botInfo.result.username)" -ForegroundColor Gray
Write-Host "   - Send /start or any message" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Check Vercel logs:" -ForegroundColor Yellow
Write-Host "   - Deployments -> last deployment -> Logs" -ForegroundColor Gray
Write-Host "   - Look for [WEBHOOK] entries or errors" -ForegroundColor Gray

