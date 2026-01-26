# Скрипт для проверки настроек API

Write-Host "Проверка настроек API для FindOrigin..." -ForegroundColor Cyan
Write-Host ""

# Проверка наличия файла .env.local
$envFile = ".env.local"
if (-not (Test-Path $envFile)) {
    Write-Host "⚠️ Файл .env.local не найден!" -ForegroundColor Yellow
    Write-Host "Создайте файл .env.local на основе env.example" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "✅ Файл .env.local найден" -ForegroundColor Green
    Write-Host ""
}

# Проверка переменных окружения (если они загружены)
Write-Host "Проверка переменных окружения:" -ForegroundColor Cyan
Write-Host ""

$apis = @(
    @{Name="Google Custom Search API"; Key="GOOGLE_SEARCH_API_KEY"; Engine="GOOGLE_SEARCH_ENGINE_ID"},
    @{Name="Bing Search API"; Key="BING_SEARCH_API_KEY"; Engine=$null},
    @{Name="SerpAPI"; Key="SERPAPI_KEY"; Engine=$null},
    @{Name="Yandex Cloud API"; Key="YANDEX_CLOUD_API_KEY"; Engine=$null}
)

$foundApi = $false

foreach ($api in $apis) {
    $key = [Environment]::GetEnvironmentVariable($api.Key, "Process")
    
    if ($key) {
        Write-Host "✅ $($api.Name):" -ForegroundColor Green
        Write-Host "   Ключ установлен: $($key.Substring(0, [Math]::Min(10, $key.Length)))..." -ForegroundColor Gray
        
        if ($api.Engine) {
            $engine = [Environment]::GetEnvironmentVariable($api.Engine, "Process")
            if ($engine) {
                Write-Host "   Engine ID установлен: $engine" -ForegroundColor Gray
                $foundApi = $true
            } else {
                Write-Host "   ⚠️ Engine ID не установлен!" -ForegroundColor Yellow
            }
        } else {
            $foundApi = $true
        }
        Write-Host ""
    } else {
        Write-Host "❌ $($api.Name): не настроен" -ForegroundColor Red
        Write-Host ""
    }
}

if (-not $foundApi) {
    Write-Host "⚠️ ВНИМАНИЕ: Не настроен ни один поисковый API!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Добавьте в файл .env.local хотя бы один из следующих:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "# Вариант 1: Google Custom Search API" -ForegroundColor Cyan
    Write-Host "GOOGLE_SEARCH_API_KEY=ваш_ключ" -ForegroundColor White
    Write-Host "GOOGLE_SEARCH_ENGINE_ID=ваш_engine_id" -ForegroundColor White
    Write-Host ""
    Write-Host "# Вариант 2: Bing Search API" -ForegroundColor Cyan
    Write-Host "BING_SEARCH_API_KEY=ваш_ключ" -ForegroundColor White
    Write-Host ""
    Write-Host "# Вариант 3: SerpAPI" -ForegroundColor Cyan
    Write-Host "SERPAPI_KEY=ваш_ключ" -ForegroundColor White
    Write-Host ""
    Write-Host "После добавления перезапустите сервер: npm run dev" -ForegroundColor Yellow
} else {
    Write-Host "✅ Настроен хотя бы один API" -ForegroundColor Green
    Write-Host ""
    Write-Host "Если ошибка все еще возникает:" -ForegroundColor Yellow
    Write-Host "1. Проверьте правильность API ключей" -ForegroundColor White
    Write-Host "2. Убедитесь, что биллинг настроен (для Google/Yandex)" -ForegroundColor White
    Write-Host "3. Проверьте логи сервера в терминале" -ForegroundColor White
    Write-Host "4. Проверьте консоль браузера (F12)" -ForegroundColor White
}

Write-Host ""
Write-Host "Проверка завершена." -ForegroundColor Cyan





