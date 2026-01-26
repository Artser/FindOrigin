# Manual webhook test - simulate Telegram request
param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "=== Manual Webhook Test ===" -ForegroundColor Cyan
Write-Host ""

# Simulate a Telegram update
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

Write-Host "Sending test update to webhook..." -ForegroundColor Yellow
Write-Host "Update: $testUpdate" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/webhook" -Method POST -Body $testUpdate -ContentType "application/json"
    Write-Host "[OK] Webhook responded:" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "[ERROR] Webhook failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Check Vercel logs for [WEBHOOK] entries" -ForegroundColor Yellow

