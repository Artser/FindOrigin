# Test sending message to bot user

# Get token from .env.local or environment variable
$token = $null
$envFile = ".env.local"
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)") {
        $token = $matches[1].Trim()
    }
}
if (-not $token -and $env:TELEGRAM_BOT_TOKEN) {
    $token = $env:TELEGRAM_BOT_TOKEN
}
if (-not $token) {
    Write-Host "ERROR: TELEGRAM_BOT_TOKEN not found!" -ForegroundColor Red
    exit 1
}

Write-Host "=== Test Send Message ===" -ForegroundColor Cyan
Write-Host ""

# Get bot info
Write-Host "1. Getting bot info..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getMe"
    Write-Host "   Bot: @$($botInfo.result.username)" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: Cannot get bot info" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. To test message sending:" -ForegroundColor Yellow
Write-Host "   - Send /start to @$($botInfo.result.username) in Telegram" -ForegroundColor Gray
Write-Host "   - Then run this command with your chat ID:" -ForegroundColor Gray
Write-Host ""
Write-Host "   Example:" -ForegroundColor Yellow
Write-Host "   `$chatId = YOUR_CHAT_ID" -ForegroundColor White
Write-Host "   `$body = @{ chat_id = `$chatId; text = 'Test message' } | ConvertTo-Json" -ForegroundColor White
Write-Host "   Invoke-RestMethod -Uri 'https://api.telegram.org/bot$token/sendMessage' -Method POST -Body `$body -ContentType 'application/json'" -ForegroundColor White
Write-Host ""

# Get updates to find chat ID
Write-Host "3. Getting recent updates (to find your chat ID)..." -ForegroundColor Yellow
try {
    $updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getUpdates"
    if ($updates.result.Count -gt 0) {
        Write-Host "   Found $($updates.result.Count) update(s)" -ForegroundColor Green
        $lastUpdate = $updates.result[-1]
        if ($lastUpdate.message) {
            $chatId = $lastUpdate.message.chat.id
            Write-Host "   Last message from chat ID: $chatId" -ForegroundColor Green
            Write-Host ""
            Write-Host "4. Testing message send to chat ID $chatId..." -ForegroundColor Yellow
            $body = @{
                chat_id = $chatId
                text = "Test message from script. If you see this, bot can send messages!"
            } | ConvertTo-Json
            try {
                $result = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/sendMessage" -Method POST -Body $body -ContentType "application/json"
                if ($result.ok) {
                    Write-Host "   [OK] Message sent successfully!" -ForegroundColor Green
                    Write-Host "   Message ID: $($result.result.message_id)" -ForegroundColor Green
                }
            } catch {
                Write-Host "   [ERROR] Failed to send message" -ForegroundColor Red
                Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "   No messages in updates" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   No updates found. Send /start to bot first." -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ERROR: Cannot get updates" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
