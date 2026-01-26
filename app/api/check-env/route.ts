/**
 * Endpoint для проверки переменных окружения на Vercel
 */

import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export async function GET() {
  return NextResponse.json({
    hasTelegramToken: !!process.env.TELEGRAM_BOT_TOKEN,
    hasOpenRouterKey: !!process.env.OPENROUTER_API_KEY,
    hasOpenAIKey: !!process.env.OPENAI_API_KEY,
    hasBaseUrl: !!process.env.OPENAI_BASE_URL,
    hasBingKey: !!process.env.BING_SEARCH_API_KEY,
    hasGoogleKey: !!process.env.GOOGLE_SEARCH_API_KEY,
    hasGoogleEngineId: !!process.env.GOOGLE_SEARCH_ENGINE_ID,
    hasSerpApiKey: !!process.env.SERPAPI_KEY,
    hasWebhookSecret: !!process.env.TELEGRAM_WEBHOOK_SECRET,
    timestamp: new Date().toISOString(),
  });
}




