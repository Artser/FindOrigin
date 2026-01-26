# Setup polling as alternative to webhook
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Setting up Polling (Alternative to Webhook) ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "WARNING: Polling is NOT recommended for production!" -ForegroundColor Yellow
Write-Host "This is a temporary solution to get the bot working." -ForegroundColor Yellow
Write-Host ""

# 1. Delete webhook
Write-Host "1. Deleting webhook..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/deleteWebhook?drop_pending_updates=true" -Method GET | Out-Null
    Write-Host "   [OK] Webhook deleted" -ForegroundColor Green
} catch {
    Write-Host "   [WARNING] Could not delete webhook" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "2. Polling endpoint created at: /api/poll" -ForegroundColor Green
Write-Host ""
Write-Host "=== How to use polling ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Option 1: Manual polling (test)" -ForegroundColor Yellow
Write-Host "  Open in browser: https://find-origin.vercel.app/api/poll" -ForegroundColor White
Write-Host "  This will check for new messages once" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 2: Automated polling (requires external service)" -ForegroundColor Yellow
Write-Host "  Use a cron job service like:" -ForegroundColor White
Write-Host "  - https://cron-job.org" -ForegroundColor Gray
Write-Host "  - https://www.easycron.com" -ForegroundColor Gray
Write-Host "  - Vercel Cron Jobs (if available)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Set up a cron job to call:" -ForegroundColor White
Write-Host "  https://find-origin.vercel.app/api/poll" -ForegroundColor Gray
Write-Host "  Every 5-10 seconds" -ForegroundColor Gray
Write-Host ""
Write-Host "=== Important ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Deploy the changes to Vercel first!" -ForegroundColor Yellow
Write-Host "2. Polling endpoint is at: /api/poll" -ForegroundColor White
Write-Host "3. This is a temporary solution until webhook is fixed" -ForegroundColor Yellow
Write-Host ""

