/**
 * Endpoint для совместимости с инструкцией
 * Использует ту же логику, что и /api/webhook
 */

import { NextRequest, NextResponse } from 'next/server';
import { TelegramUpdate } from '@/lib/telegram';
import { processUserRequest } from '@/lib/processRequest';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  const startTime = Date.now();
  const timestamp = new Date().toISOString();
  
  console.log('[TELEGRAM] POST запрос получен на /api/telegram');
  console.log('[TELEGRAM] Время:', timestamp);
  
  try {
    const bodyText = await request.text();
    const body = JSON.parse(bodyText) as TelegramUpdate;
    
    console.log('[TELEGRAM] Получен update:', {
      updateId: body.update_id,
      hasMessage: !!body.message,
    });
    
    const message = body.message || body.edited_message;
    
    if (!message) {
      return NextResponse.json({ ok: true });
    }

    const chatId = message.chat.id;
    const text = message.text;
    
    // Обработка команд
    if (text?.startsWith('/start')) {
      console.log('[TELEGRAM] Обработка команды /start для chatId:', chatId);
      try {
        const { sendMessage } = await import('@/lib/telegram');
        await sendMessage({
          chatId,
          text: '👋 Привет! Я бот FindOrigin.\n\nОтправьте текст или ссылку на Telegram-пост — найду возможные источники.\n🤖 Сравниваю источники с исходным текстом через AI.\n\n📱 Веб-интерфейс: кнопка меню под полем ввода.',
        });
        return NextResponse.json({ ok: true });
      } catch (error) {
        console.error('[TELEGRAM] Ошибка при отправке приветственного сообщения:', error);
        return NextResponse.json({ ok: false, error: 'Failed to send welcome message' });
      }
    }
    
    if (!text || text.trim().length === 0) {
      return NextResponse.json({ ok: true });
    }

    // Обработка запроса асинхронно
    processUserRequest(chatId, text).catch((error) => {
      console.error('[TELEGRAM] Ошибка при обработке запроса:', error);
    });

    return NextResponse.json({ ok: true });
  } catch (error) {
    console.error('[TELEGRAM] Ошибка:', error);
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : 'Unknown error' },
      { status: 200 }
    );
  }
}

export async function GET() {
  return NextResponse.json({
    status: 'ok',
    message: 'Telegram webhook endpoint',
    timestamp: new Date().toISOString(),
  });
}
