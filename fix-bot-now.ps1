# Comprehensive bot diagnosis and fix script

# Get token from .env.local or environment variable
$token = $null
$envFile = ".env.local"
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)") {
        $token = $matches[1].Trim()
        Write-Host "Token loaded from .env.local" -ForegroundColor Green
    }
}
if (-not $token -and $env:TELEGRAM_BOT_TOKEN) {
    $token = $env:TELEGRAM_BOT_TOKEN
    Write-Host "Token loaded from environment variable" -ForegroundColor Green
}
if (-not $token) {
    Write-Host "ERROR: TELEGRAM_BOT_TOKEN not found in .env.local or environment variables!" -ForegroundColor Red
    Write-Host "Set TELEGRAM_BOT_TOKEN in .env.local or as environment variable" -ForegroundColor Yellow
    exit 1
}

$correctWebhookUrl = "https://find-origin-nine.vercel.app/api/telegram"

Write-Host "=== Bot Diagnosis ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check bot token
Write-Host "1. Checking bot token..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
    Write-Host "   [OK] Token is valid" -ForegroundColor Green
    Write-Host "   Bot name: $($botInfo.result.first_name)" -ForegroundColor Green
    Write-Host "   Username: @$($botInfo.result.username)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Token is invalid or expired!" -ForegroundColor Red
    Write-Host "   Get new token from @BotFather" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 2. Check current webhook
Write-Host "2. Checking current webhook..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
    $currentUrl = $info.result.url
    
    if ([string]::IsNullOrEmpty($currentUrl)) {
        Write-Host "   [PROBLEM] Webhook is not set!" -ForegroundColor Red
        $needsSetup = $true
    } elseif ($currentUrl -ne $correctWebhookUrl) {
        Write-Host "   [PROBLEM] Wrong webhook URL!" -ForegroundColor Red
        Write-Host "   Current: $currentUrl" -ForegroundColor Yellow
        Write-Host "   Should be: $correctWebhookUrl" -ForegroundColor Yellow
        $needsSetup = $true
    } else {
        Write-Host "   [OK] Webhook is set correctly" -ForegroundColor Green
        Write-Host "   URL: $currentUrl" -ForegroundColor Green
        $needsSetup = $false
    }
    
    Write-Host "   Pending updates: $($info.result.pending_update_count)" -ForegroundColor $(if ($info.result.pending_update_count -gt 0) { "Yellow" } else { "Green" })
    
    if ($info.result.last_error_date) {
        Write-Host "   [ERROR] Last webhook error:" -ForegroundColor Red
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
        Write-Host "   Date: $errorDate" -ForegroundColor Red
        Write-Host "   Message: $($info.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host "   [OK] No webhook errors" -ForegroundColor Green
    }
} catch {
    Write-Host "   [ERROR] Failed to get webhook info" -ForegroundColor Red
    $needsSetup = $true
}

Write-Host ""

# 3. Check endpoint accessibility
Write-Host "3. Checking endpoint accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $correctWebhookUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   [OK] Endpoint is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    try {
        $content = $response.Content | ConvertFrom-Json
        Write-Host "   Response: $($content | ConvertTo-Json -Compress)" -ForegroundColor Gray
    } catch {
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "   [PROBLEM] Endpoint is not accessible!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Check if project is deployed on Vercel" -ForegroundColor Yellow
}

Write-Host ""

# 4. Setup/reinstall webhook
if ($needsSetup) {
    Write-Host "4. Setting up webhook..." -ForegroundColor Yellow
    
    # Delete old webhook
    Write-Host "   Deleting old webhook..." -ForegroundColor Gray
    try {
        $deleteResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET
        Write-Host "   Old webhook deleted" -ForegroundColor Green
        Start-Sleep -Seconds 2
    } catch {
        Write-Host "   Warning: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Set new webhook
    Write-Host "   Setting new webhook..." -ForegroundColor Gray
    try {
        $setResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$correctWebhookUrl" -Method GET
        if ($setResult.ok) {
            Write-Host "   [OK] Webhook set successfully!" -ForegroundColor Green
            Write-Host "   URL: $correctWebhookUrl" -ForegroundColor Green
        } else {
            Write-Host "   [ERROR] Failed to set webhook" -ForegroundColor Red
            Write-Host "   Response: $($setResult | ConvertTo-Json -Compress)" -ForegroundColor Red
        }
    } catch {
        Write-Host "   [ERROR] Error setting webhook" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "4. Webhook is already set correctly, no reinstall needed" -ForegroundColor Green
}

Write-Host ""

# 5. Recommendations
Write-Host "=== Recommendations ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Check environment variables on Vercel:" -ForegroundColor Yellow
Write-Host "   - Go to Vercel Dashboard -> Your project -> Settings -> Environment Variables" -ForegroundColor Gray
Write-Host "   - Make sure this variable is set:" -ForegroundColor Gray
Write-Host "     Name: TELEGRAM_BOT_TOKEN" -ForegroundColor White
Write-Host "     Value: $token" -ForegroundColor White
Write-Host ""

Write-Host "2. If variable was added/changed:" -ForegroundColor Yellow
Write-Host "   - Redeploy project on Vercel" -ForegroundColor Gray
Write-Host "   - Or wait for automatic redeployment" -ForegroundColor Gray
Write-Host ""

Write-Host "3. Check Vercel logs:" -ForegroundColor Yellow
Write-Host "   - Go to Vercel Dashboard -> Your project -> Deployments -> Logs" -ForegroundColor Gray
Write-Host "   - Send /start to bot in Telegram" -ForegroundColor Gray
Write-Host "   - Look for [WEBHOOK] entries in logs" -ForegroundColor Gray
Write-Host ""

Write-Host "4. If no [WEBHOOK] entries in logs:" -ForegroundColor Yellow
Write-Host "   - Telegram is not sending requests to your endpoint" -ForegroundColor Gray
Write-Host "   - Check that webhook is set correctly (see above)" -ForegroundColor Gray
Write-Host "   - Try reinstalling webhook: .\setup-webhook.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "5. If there are errors in logs:" -ForegroundColor Yellow
Write-Host "   - Copy error text" -ForegroundColor Gray
Write-Host "   - Check that all environment variables are set" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Done! ===" -ForegroundColor Cyan
Write-Host "Send /start to bot in Telegram and check Vercel logs" -ForegroundColor Yellow
