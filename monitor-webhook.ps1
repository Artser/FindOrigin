# Monitor webhook status in real-time
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Webhook Monitor ===" -ForegroundColor Cyan
Write-Host "Monitoring webhook status. Send /start to @MsDragonBot now!" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

$webhookUrl = "https://find-origin.vercel.app/api/webhook"
$checkCount = 0

while ($true) {
    $checkCount++
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    try {
        $info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getWebhookInfo" -ErrorAction Stop
        
        Write-Host "[$timestamp] Check #$checkCount" -ForegroundColor Cyan
        Write-Host "  URL: $($info.result.url)" -ForegroundColor Gray
        Write-Host "  Pending updates: $($info.result.pending_update_count)" -ForegroundColor $(if ($info.result.pending_update_count -gt 0) { 'Yellow' } else { 'Green' })
        
        if ($info.result.last_error_date) {
            $errorDate = [DateTimeOffset]::FromUnixTimeSeconds($info.result.last_error_date).LocalDateTime
            Write-Host "  [ERROR] Last error at: $errorDate" -ForegroundColor Red
            Write-Host "  Error: $($info.result.last_error_message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "  This means Telegram tried to send a request but failed!" -ForegroundColor Red
            break
        } else {
            Write-Host "  [OK] No errors" -ForegroundColor Green
        }
        
        Write-Host ""
    } catch {
        Write-Host "[$timestamp] [ERROR] Cannot check webhook: $_" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 5
}

