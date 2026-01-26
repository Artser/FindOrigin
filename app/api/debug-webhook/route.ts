/**
 * Debug endpoint для проверки работы webhook и логирования
 */

import { NextRequest, NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  const timestamp = new Date().toISOString();
  
  // Пробуем все способы логирования
  console.log('[DEBUG-WEBHOOK] POST запрос получен через console.log');
  console.error('[DEBUG-WEBHOOK] POST запрос получен через console.error');
  console.warn('[DEBUG-WEBHOOK] POST запрос получен через console.warn');
  process.stdout.write('[DEBUG-WEBHOOK] POST запрос через process.stdout.write\n');
  process.stderr.write('[DEBUG-WEBHOOK] POST запрос через process.stderr.write\n');
  
  // Читаем тело запроса
  let bodyText = '';
  try {
    bodyText = await request.text();
    console.log('[DEBUG-WEBHOOK] Тело запроса получено, длина:', bodyText.length);
  } catch (error) {
    console.error('[DEBUG-WEBHOOK] Ошибка чтения тела:', error);
  }
  
  // Возвращаем информацию в ответе (для отладки)
  return NextResponse.json({
    success: true,
    timestamp,
    message: 'Debug endpoint работает',
    requestInfo: {
      method: request.method,
      url: request.url,
      headers: {
        'content-type': request.headers.get('content-type'),
        'user-agent': request.headers.get('user-agent'),
      },
      bodyLength: bodyText.length,
      bodyPreview: bodyText.substring(0, 200),
    },
    note: 'Проверьте логи Vercel - должны быть записи с префиксом [DEBUG-WEBHOOK]',
  });
}

export async function GET() {
  const timestamp = new Date().toISOString();
  
  console.log('[DEBUG-WEBHOOK] GET запрос получен');
  console.error('[DEBUG-WEBHOOK] GET запрос через console.error');
  process.stderr.write('[DEBUG-WEBHOOK] GET запрос через process.stderr.write\n');
  
  return NextResponse.json({
    success: true,
    timestamp,
    message: 'Debug endpoint работает (GET)',
    note: 'Проверьте логи Vercel',
  });
}

