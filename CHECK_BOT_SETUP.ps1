# Скрипт для проверки настройки Telegram-бота

Write-Host "=== Проверка настройки Telegram-бота ===" -ForegroundColor Cyan
Write-Host ""

# Проверка наличия .env.local
if (Test-Path ".env.local") {
    Write-Host "✅ Файл .env.local найден" -ForegroundColor Green
} else {
    Write-Host "❌ Файл .env.local НЕ найден!" -ForegroundColor Red
    Write-Host "   Создайте файл .env.local на основе env.example" -ForegroundColor Yellow
    exit 1
}

# Проверка переменных окружения
Write-Host ""
Write-Host "Проверка переменных окружения:" -ForegroundColor Cyan

$envFile = Get-Content ".env.local" -Raw

$requiredVars = @(
    "TELEGRAM_BOT_TOKEN",
    "OPENAI_API_KEY"
)

$searchVars = @(
    "GOOGLE_SEARCH_API_KEY",
    "BING_SEARCH_API_KEY",
    "SERPAPI_KEY",
    "YANDEX_CLOUD_API_KEY"
)

$allVarsOk = $true

foreach ($var in $requiredVars) {
    if ($envFile -match "$var\s*=") {
        $value = ($envFile -split "$var\s*=")[1] -split "`n" | Select-Object -First 1
        if ($value -and $value.Trim() -ne "" -and $value.Trim() -notmatch "^your_|^#") {
            Write-Host "  ✅ $var установлен" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $var не установлен или содержит placeholder" -ForegroundColor Red
            $allVarsOk = $false
        }
    } else {
        Write-Host "  ❌ $var не найден в .env.local" -ForegroundColor Red
        $allVarsOk = $false
    }
}

Write-Host ""
Write-Host "Проверка поисковых API:" -ForegroundColor Cyan
$searchApiFound = $false
foreach ($var in $searchVars) {
    if ($envFile -match "$var\s*=") {
        $value = ($envFile -split "$var\s*=")[1] -split "`n" | Select-Object -First 1
        if ($value -and $value.Trim() -ne "" -and $value.Trim() -notmatch "^your_|^#") {
            Write-Host "  ✅ $var установлен" -ForegroundColor Green
            $searchApiFound = $true
        }
    }
}

if (-not $searchApiFound) {
    Write-Host "  ⚠️  Не найден ни один поисковый API!" -ForegroundColor Yellow
    Write-Host "     Настройте хотя бы один: GOOGLE_SEARCH_API_KEY, BING_SEARCH_API_KEY, SERPAPI_KEY или YANDEX_CLOUD_API_KEY" -ForegroundColor Yellow
}

# Проверка Yandex Cloud (если используется)
if ($envFile -match "YANDEX_CLOUD_API_KEY") {
    if ($envFile -match "YANDEX_FOLDER_ID\s*=") {
        $value = ($envFile -split "YANDEX_FOLDER_ID\s*=")[1] -split "`n" | Select-Object -First 1
        if ($value -and $value.Trim() -ne "" -and $value.Trim() -notmatch "^your_|^#") {
            Write-Host "  ✅ YANDEX_FOLDER_ID установлен" -ForegroundColor Green
        } else {
            Write-Host "  ❌ YANDEX_FOLDER_ID не установлен (требуется для Yandex GPT)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "=== Проверка сервера ===" -ForegroundColor Cyan

# Проверка, запущен ли сервер
$serverRunning = $false
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/webhook" -Method GET -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Сервер запущен на http://localhost:3000" -ForegroundColor Green
        $serverRunning = $true
    }
} catch {
    Write-Host "❌ Сервер НЕ запущен на http://localhost:3000" -ForegroundColor Red
    Write-Host "   Запустите сервер: npm run dev" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Рекомендации ===" -ForegroundColor Cyan

if (-not $allVarsOk) {
    Write-Host "1. Убедитесь, что все обязательные переменные установлены в .env.local" -ForegroundColor Yellow
}

if (-not $searchApiFound) {
    Write-Host "2. Настройте хотя бы один поисковый API" -ForegroundColor Yellow
}

if (-not $serverRunning) {
    Write-Host "3. Запустите сервер разработки: npm run dev" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "4. Настройте webhook для Telegram-бота:" -ForegroundColor Yellow
Write-Host "   Откройте в браузере: http://localhost:3000/api/set-webhook" -ForegroundColor Yellow
Write-Host "   Или используйте ngrok для публичного URL:" -ForegroundColor Yellow
Write-Host "   ngrok http 3000" -ForegroundColor Yellow
Write-Host "   Затем: http://ваш-ngrok-url.ngrok.io/api/set-webhook" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== Готово ===" -ForegroundColor Cyan

