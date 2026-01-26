# Проверка настройки webhook для Telegram бота
# Использование: .\test-webhook-setup.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$BotToken,
    
    [Parameter(Mandatory=$false)]
    [string]$VercelUrl
)

# Попытка получить значения из .env.local
if (-not $BotToken -or -not $VercelUrl) {
    Write-Host "Попытка прочитать значения из .env.local..." -ForegroundColor Yellow
    
    if (Test-Path ".env.local") {
        $envContent = Get-Content ".env.local" -Raw
        if (-not $BotToken) {
            $match = [regex]::Match($envContent, 'TELEGRAM_BOT_TOKEN\s*=\s*([^\r\n]+)')
            if ($match.Success) {
                $BotToken = $match.Groups[1].Value.Trim()
            }
        }
    }
    
    # Если Vercel URL не указан, спросим у пользователя
    if (-not $VercelUrl) {
        $VercelUrl = Read-Host "Введите URL вашего проекта на Vercel (например: https://find-origin.vercel.app)"
    }
}

if (-not $BotToken) {
    $BotToken = Read-Host "Введите TELEGRAM_BOT_TOKEN"
}

Write-Host ""
Write-Host "=== Проверка настройки Telegram Webhook ===" -ForegroundColor Cyan
Write-Host ""

# 1. Проверка информации о webhook
Write-Host "1. Проверка текущего webhook..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/getWebhookInfo"
    $currentUrl = $webhookInfo.result.url
    $expectedUrl = "$VercelUrl/api/webhook"
    
    Write-Host "   Текущий URL: $currentUrl" -ForegroundColor $(if ($currentUrl -eq $expectedUrl) { "Green" } else { "Yellow" })
    Write-Host "   Ожидаемый URL: $expectedUrl" -ForegroundColor Gray
    
    if ($currentUrl -eq $expectedUrl) {
        Write-Host "   ✅ Webhook установлен правильно" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Webhook установлен неправильно" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   Установка правильного webhook..." -ForegroundColor Yellow
        try {
            $setResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/setWebhook?url=$expectedUrl" -Method GET
            if ($setResult.ok) {
                Write-Host "   ✅ Webhook успешно установлен" -ForegroundColor Green
            } else {
                Write-Host "   ❌ Ошибка установки webhook: $($setResult.description)" -ForegroundColor Red
            }
        } catch {
            Write-Host "   ❌ Ошибка при установке webhook: $_" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "   Pending updates: $($webhookInfo.result.pending_update_count)" -ForegroundColor $(if ($webhookInfo.result.pending_update_count -eq 0) { "Green" } else { "Yellow" })
    
    if ($webhookInfo.result.pending_update_count -gt 0) {
        Write-Host "   ⚠️ Есть pending updates. Рекомендуется удалить их." -ForegroundColor Yellow
        Write-Host ""
        $delete = Read-Host "   Удалить pending updates? (y/n)"
        if ($delete -eq "y" -or $delete -eq "Y") {
            try {
                $deleteResult = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/deleteWebhook?drop_pending_updates=true" -Method GET
                if ($deleteResult.ok) {
                    Write-Host "   ✅ Pending updates удалены" -ForegroundColor Green
                    Write-Host "   Установка webhook заново..." -ForegroundColor Yellow
                    Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/setWebhook?url=$expectedUrl" -Method GET | Out-Null
                    Write-Host "   ✅ Webhook переустановлен" -ForegroundColor Green
                }
            } catch {
                Write-Host "   ❌ Ошибка при удалении pending updates: $_" -ForegroundColor Red
            }
        }
    }
    
    if ($webhookInfo.result.last_error_date) {
        Write-Host ""
        Write-Host "   ❌ Последняя ошибка webhook:" -ForegroundColor Red
        Write-Host "      Дата: $(Get-Date -UnixTimeSeconds $webhookInfo.result.last_error_date)" -ForegroundColor Red
        Write-Host "      Сообщение: $($webhookInfo.result.last_error_message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "   ❌ Ошибка при проверке webhook: $_" -ForegroundColor Red
    Write-Host "   Возможно, токен неправильный" -ForegroundColor Yellow
}

Write-Host ""

# 2. Проверка доступности endpoint
Write-Host "2. Проверка доступности webhook endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$VercelUrl/api/webhook" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Endpoint доступен (статус: $($response.StatusCode))" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "   Ответ: $($content.message)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Endpoint недоступен или не отвечает" -ForegroundColor Red
    Write-Host "   Ошибка: $_" -ForegroundColor Yellow
}

Write-Host ""

# 3. Проверка информации о боте
Write-Host "3. Проверка информации о боте..." -ForegroundColor Yellow
try {
    $botInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/getMe"
    Write-Host "   ✅ Бот активен" -ForegroundColor Green
    Write-Host "   Имя: $($botInfo.result.first_name)" -ForegroundColor Gray
    Write-Host "   Username: @$($botInfo.result.username)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Ошибка при проверке бота" -ForegroundColor Red
    Write-Host "   Возможно, токен неправильный" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Рекомендации ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Убедитесь, что на Vercel добавлены все переменные окружения:" -ForegroundColor Yellow
Write-Host "   - TELEGRAM_BOT_TOKEN" -ForegroundColor Gray
Write-Host "   - OPENROUTER_API_KEY (или OPENAI_API_KEY)" -ForegroundColor Gray
Write-Host "   - OPENAI_BASE_URL" -ForegroundColor Gray
Write-Host "   - Хотя бы один поисковый API (BING_SEARCH_API_KEY, GOOGLE_SEARCH_API_KEY, и т.д.)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. После добавления переменных на Vercel обязательно переразверните проект" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Проверьте логи Vercel после отправки сообщения боту" -ForegroundColor Yellow
Write-Host "   Vercel Dashboard → Deployments → последний деплой → Logs" -ForegroundColor Gray
Write-Host ""
Write-Host "=== Конец проверки ===" -ForegroundColor Cyan




