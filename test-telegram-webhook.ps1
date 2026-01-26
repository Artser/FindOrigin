# Complete test of Telegram webhook functionality
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Complete Telegram Webhook Test ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check bot
Write-Host "1. Bot status..." -ForegroundColor Yellow
$botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getMe"
Write-Host "   Bot: @$($botInfo.result.username)" -ForegroundColor Green

# 2. Check webhook
Write-Host ""
Write-Host "2. Webhook status..." -ForegroundColor Yellow
$webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getWebhookInfo"
Write-Host "   URL: $($webhookInfo.result.url)" -ForegroundColor Gray
Write-Host "   Pending: $($webhookInfo.result.pending_update_count)" -ForegroundColor Gray

if ($webhookInfo.result.last_error_message) {
    Write-Host "   [ERROR] $($webhookInfo.result.last_error_message)" -ForegroundColor Red
} else {
    Write-Host "   [OK] No errors" -ForegroundColor Green
}

# 3. Test endpoint
Write-Host ""
Write-Host "3. Testing endpoint..." -ForegroundColor Yellow
$testUpdate = @{
    update_id = 999999
    message = @{
        message_id = 1
        from = @{
            id = 123456789
            is_bot = $false
            first_name = "Test"
            username = "testuser"
        }
        chat = @{
            id = 123456789
            type = "private"
            first_name = "Test"
            username = "testuser"
        }
        date = [int][double]::Parse((Get-Date -UFormat %s))
        text = "/start"
    }
} | ConvertTo-Json -Depth 10

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method POST -Body $testUpdate -ContentType "application/json" -TimeoutSec 10
    $stopwatch.Stop()
    Write-Host "   [OK] Endpoint responds in $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Green
    Write-Host "   Response: $($response | ConvertTo-Json)" -ForegroundColor Gray
} catch {
    Write-Host "   [ERROR] Endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Instructions
Write-Host ""
Write-Host "=== IMPORTANT: Manual Test Required ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now do this:" -ForegroundColor Yellow
Write-Host "1. Open Telegram" -ForegroundColor White
Write-Host "2. Send '/start' to @$($botInfo.result.username)" -ForegroundColor White
Write-Host "3. Wait 5 seconds" -ForegroundColor White
Write-Host "4. Run this command again to check for errors:" -ForegroundColor White
Write-Host "   .\test-telegram-webhook.ps1 `"$Token`"" -ForegroundColor Gray
Write-Host ""
Write-Host "If you see an error in step 2, that's the problem!" -ForegroundColor Yellow
Write-Host "If no error but bot doesn't respond, check Vercel Logs for [WEBHOOK] entries." -ForegroundColor Yellow
Write-Host ""

