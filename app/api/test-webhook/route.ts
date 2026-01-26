/**
 * Тестовый endpoint для проверки получения запросов от Telegram
 */

import { NextRequest, NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  const timestamp = new Date().toISOString();
  
  // Логируем все что можем
  console.log('='.repeat(50));
  console.log('[TEST-WEBHOOK] POST запрос получен!');
  console.log('[TEST-WEBHOOK] Время:', timestamp);
  console.log('[TEST-WEBHOOK] URL:', request.url);
  
  try {
    const body = await request.text();
    console.log('[TEST-WEBHOOK] Тело запроса получено, длина:', body.length);
    console.log('[TEST-WEBHOOK] Тело:', body.substring(0, 500));
    
    return NextResponse.json({
      ok: true,
      message: 'Test webhook received',
      timestamp,
      bodyLength: body.length,
    });
  } catch (error) {
    console.error('[TEST-WEBHOOK] Ошибка:', error);
    return NextResponse.json({
      ok: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    }, { status: 500 });
  }
}

export async function GET() {
  return NextResponse.json({
    status: 'ok',
    message: 'Test webhook endpoint is working',
    timestamp: new Date().toISOString(),
  });
}
