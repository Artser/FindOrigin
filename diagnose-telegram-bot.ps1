<# 
  Telegram bot diagnostics script (FindOrigin)

  Checks:
  1. Bot token (getMe)
  2. Webhook (getWebhookInfo) and expected URL
  3. /api/health endpoint on Vercel
  4. /api/telegram endpoint on Vercel

  Run from project root:

      .\diagnose-telegram-bot.ps1

#>

param(
    [string]$TokenOverride
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Telegram bot diagnostics (FindOrigin) ===" -ForegroundColor Cyan
Write-Host ""

# Config
$expectedDomain = "https://find-origin-nine.vercel.app"
$expectedWebhookPath = "/api/telegram"
$expectedWebhookUrl = "$expectedDomain$expectedWebhookPath"

Write-Host "Expected webhook URL:" -ForegroundColor Yellow
Write-Host "  $expectedWebhookUrl" -ForegroundColor Gray
Write-Host ""

function Get-BotToken {
    param([string]$Override)

    if ($Override) { return $Override }

    if ($env:TELEGRAM_BOT_TOKEN) {
        Write-Host "[OK] TELEGRAM_BOT_TOKEN from environment." -ForegroundColor Green
        return $env:TELEGRAM_BOT_TOKEN
    }

    $envFile = ".env.local"
    if (Test-Path $envFile) {
        $content = Get-Content $envFile -Raw
        $match = [regex]::Match($content, "TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)")
        if ($match.Success) {
            $token = $match.Groups[1].Value.Trim()
            Write-Host "[OK] TELEGRAM_BOT_TOKEN from .env.local." -ForegroundColor Green
            return $token
        }
    }

    Write-Host "[ERROR] TELEGRAM_BOT_TOKEN not found (env or .env.local)." -ForegroundColor Red
    throw "TELEGRAM_BOT_TOKEN not found"
}

try {
    $token = Get-BotToken -Override $TokenOverride
} catch {
    Write-Host ""
    Write-Host "Diagnostics stopped: no bot token." -ForegroundColor Red
    return
}

Write-Host ""
Write-Host "--- 1. Checking bot token (getMe) ---" -ForegroundColor Cyan

try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe" -Method GET
    if ($botInfo.ok) {
        Write-Host "[OK] Token is valid." -ForegroundColor Green
        Write-Host "  Bot username: @$($botInfo.result.username)" -ForegroundColor Gray
        Write-Host "  Bot name    : $($botInfo.result.first_name)" -ForegroundColor Gray
    } else {
        Write-Host "[ERROR] getMe returned error: $($botInfo.description)" -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] getMe request failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "--- 2. Checking webhook (getWebhookInfo) ---" -ForegroundColor Cyan

try {
    $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo" -Method GET

    $currentUrl = $info.result.url
    $pending = $info.result.pending_update_count

    if ([string]::IsNullOrEmpty($currentUrl)) {
        Write-Host "[WARN] Webhook is NOT set." -ForegroundColor Yellow
    } else {
        $color = if ($currentUrl -eq $expectedWebhookUrl) { "Green" } else { "Yellow" }
        Write-Host "Current webhook URL:" -ForegroundColor Gray
        Write-Host "  $currentUrl" -ForegroundColor $color

        if ($currentUrl -eq $expectedWebhookUrl) {
            Write-Host "[OK] Webhook matches expected URL." -ForegroundColor Green
        } else {
            Write-Host "[WARN] Webhook URL is different from expected." -ForegroundColor Yellow
            Write-Host "  Expected: $expectedWebhookUrl" -ForegroundColor Yellow
        }
    }

    Write-Host "Pending updates: $pending" -ForegroundColor Gray

    if ($info.result.last_error_date) {
        $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
        Write-Host "[ERROR] Last webhook error:" -ForegroundColor Red
        Write-Host "  Time   : $errorDate" -ForegroundColor Red
        Write-Host "  Message: $($info.result.last_error_message)" -ForegroundColor Red
    } else {
        Write-Host "[OK] No webhook errors reported by Telegram." -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] getWebhookInfo failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "--- 3. Checking /api/health ---" -ForegroundColor Cyan

try {
    $healthResponse = Invoke-RestMethod -Uri "$expectedDomain/api/health" -Method GET -TimeoutSec 10
    Write-Host "[OK] /api/health is reachable." -ForegroundColor Green
    Write-Host "  Response: $($healthResponse | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "[WARN] /api/health request failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "--- 4. Checking /api/telegram ---" -ForegroundColor Cyan

try {
    $telegramEndpointResponse = Invoke-WebRequest -Uri "$expectedDomain$expectedWebhookPath" -Method GET -TimeoutSec 10 -ErrorAction SilentlyContinue

    if ($telegramEndpointResponse.StatusCode -eq 405 -or $telegramEndpointResponse.StatusCode -eq 404 -or $telegramEndpointResponse.StatusCode -eq 200) {
        Write-Host "[OK] /api/telegram endpoint exists (status: $($telegramEndpointResponse.StatusCode))." -ForegroundColor Green
        Write-Host "  Note: 405/404 for GET is normal, Telegram sends POST." -ForegroundColor Gray
    } else {
        Write-Host "[WARN] /api/telegram returned unexpected status: $($telegramEndpointResponse.StatusCode)." -ForegroundColor Yellow
    }
} catch {
    Write-Host "[ERROR] /api/telegram request failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Diagnostics finished ===" -ForegroundColor Cyan
Write-Host "If bot does not respond:" -ForegroundColor Yellow
Write-Host "  1) Check webhook URL matches expected." -ForegroundColor Gray
Write-Host "  2) Ensure TELEGRAM_BOT_TOKEN is set on Vercel and project is redeployed." -ForegroundColor Gray
Write-Host "  3) Send /start to bot and check Vercel logs for [TELEGRAM]/[WEBHOOK] entries." -ForegroundColor Gray
Write-Host ""
