/**
 * Тестовый endpoint для проверки логирования на Vercel
 */

import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export async function GET() {
  const timestamp = new Date().toISOString();
  
  // Логируем через разные методы
  console.log('[TEST-LOG] GET запрос получен через console.log');
  console.error('[TEST-LOG] GET запрос получен через console.error');
  console.warn('[TEST-LOG] GET запрос получен через console.warn');
  
  return NextResponse.json({
    success: true,
    message: 'Тестовый endpoint работает',
    timestamp,
    note: 'Проверьте логи Vercel - должны быть записи с префиксом [TEST-LOG]',
  });
}

export async function POST() {
  const timestamp = new Date().toISOString();
  
  // Логируем через разные методы
  console.log('[TEST-LOG] POST запрос получен через console.log');
  console.error('[TEST-LOG] POST запрос получен через console.error');
  console.warn('[TEST-LOG] POST запрос получен через console.warn');
  
  return NextResponse.json({
    success: true,
    message: 'Тестовый POST endpoint работает',
    timestamp,
    note: 'Проверьте логи Vercel - должны быть записи с префиксом [TEST-LOG]',
  });
}

