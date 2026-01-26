# Script to check Vercel environment variables setup

Write-Host "=== Vercel Environment Variables Check ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: This script cannot directly check Vercel." -ForegroundColor Yellow
Write-Host "You need to check manually in Vercel Dashboard." -ForegroundColor Yellow
Write-Host ""
Write-Host "=== Required Environment Variables ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. TELEGRAM_BOT_TOKEN" -ForegroundColor Yellow
Write-Host "   Value: 6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k" -ForegroundColor Gray
Write-Host "   Status: Check in Vercel Dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "2. OPENROUTER_API_KEY" -ForegroundColor Yellow
Write-Host "   Status: Check in Vercel Dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "3. YANDEX_CLOUD_API_KEY" -ForegroundColor Yellow
Write-Host "   Status: Check in Vercel Dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "4. YANDEX_FOLDER_ID" -ForegroundColor Yellow
Write-Host "   Status: Check in Vercel Dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "=== Steps to Fix ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Go to: https://vercel.com/dashboard" -ForegroundColor Yellow
Write-Host "2. Select project: find-origin" -ForegroundColor Yellow
Write-Host "3. Go to: Settings -> Environment Variables" -ForegroundColor Yellow
Write-Host "4. Add TELEGRAM_BOT_TOKEN if missing:" -ForegroundColor Yellow
Write-Host "   Name: TELEGRAM_BOT_TOKEN" -ForegroundColor Gray
Write-Host "   Value: 6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k" -ForegroundColor Gray
Write-Host "   Environment: Production, Preview, Development" -ForegroundColor Gray
Write-Host ""
Write-Host "5. CRITICAL: Redeploy the project after adding variables!" -ForegroundColor Red
Write-Host "   - Go to Deployments" -ForegroundColor Yellow
Write-Host "   - Click on latest deployment" -ForegroundColor Yellow
Write-Host "   - Click three dots (...) -> Redeploy" -ForegroundColor Yellow
Write-Host ""
Write-Host "6. Test the bot:" -ForegroundColor Yellow
Write-Host "   - Send /start to bot in Telegram" -ForegroundColor Gray
Write-Host "   - Check Vercel logs for [WEBHOOK] entries" -ForegroundColor Gray
Write-Host ""
