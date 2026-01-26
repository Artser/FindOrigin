# Check webhook status
$token = "6436071741:AAF8hTxBWoHlXH8F547RFAOdTdHVog6gpi0"

Write-Host "=== Webhook Status ===" -ForegroundColor Cyan
Write-Host ""

$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"

Write-Host "Webhook URL: $($info.result.url)"
Write-Host "Pending updates: $($info.result.pending_update_count)"

if ($info.result.last_error_date) {
    $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
    Write-Host ""
    Write-Host "[ERROR] Last webhook error:" -ForegroundColor Red
    Write-Host "Date: $errorDate" -ForegroundColor Red
    Write-Host "Message: $($info.result.last_error_message)" -ForegroundColor Red
} else {
    Write-Host ""
    Write-Host "[OK] No errors" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Bot Info ===" -ForegroundColor Cyan
$botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
Write-Host "Name: $($botInfo.result.first_name)" -ForegroundColor Green
Write-Host "Username: @$($botInfo.result.username)" -ForegroundColor Green

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Make sure TELEGRAM_BOT_TOKEN is set on Vercel" -ForegroundColor Yellow
Write-Host "2. Make sure project is redeployed after adding variables" -ForegroundColor Yellow
Write-Host "3. Send test message to bot" -ForegroundColor Yellow
Write-Host "4. Check Vercel logs" -ForegroundColor Yellow
