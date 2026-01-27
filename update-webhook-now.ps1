# Quick script to update webhook URL to new domain

# Get token from .env.local
$envFile = ".env.local"
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)") {
        $token = $matches[1].Trim()
        Write-Host "[OK] Token loaded from .env.local" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] TELEGRAM_BOT_TOKEN not found in .env.local" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[ERROR] .env.local file not found" -ForegroundColor Red
    exit 1
}

$newWebhookUrl = "https://find-origin-nine.vercel.app/api/telegram"

Write-Host ""
Write-Host "=== Updating Telegram Webhook ===" -ForegroundColor Cyan
Write-Host "New URL: $newWebhookUrl" -ForegroundColor Yellow
Write-Host ""

# Delete old webhook first
Write-Host "Step 1: Deleting old webhook..." -ForegroundColor Yellow
try {
    $deleteResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET
    if ($deleteResult.ok) {
        Write-Host "  [OK] Old webhook deleted" -ForegroundColor Green
    }
} catch {
    Write-Host "  [WARN] Error deleting webhook: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 2: Setting new webhook..." -ForegroundColor Yellow
try {
    $setResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$newWebhookUrl" -Method GET
    if ($setResult.ok) {
        Write-Host "  [OK] Webhook set successfully!" -ForegroundColor Green
        Write-Host "  URL: $newWebhookUrl" -ForegroundColor Gray
    } else {
        Write-Host "  [ERROR] Failed to set webhook" -ForegroundColor Red
        Write-Host "  Response: $($setResult | ConvertTo-Json)" -ForegroundColor Gray
        exit 1
    }
} catch {
    Write-Host "  [ERROR] Error setting webhook: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 3: Verifying webhook..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
    Write-Host "  Current URL: $($info.result.url)" -ForegroundColor $(if ($info.result.url -eq $newWebhookUrl) { "Green" } else { "Yellow" })
    if ($info.result.url -eq $newWebhookUrl) {
        Write-Host "  [OK] Webhook URL matches!" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Webhook URL doesn't match expected" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [ERROR] Error verifying webhook: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Cyan
Write-Host "Run 'npm run diagnose-bot' to verify." -ForegroundColor Yellow
