import { NextRequest, NextResponse } from 'next/server';
import { sendMessage } from '@/lib/telegram';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

/**
 * Тестовый endpoint для проверки отправки сообщения
 * Использование: GET /api/test-send-message?chatId=YOUR_CHAT_ID
 */
export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const chatIdParam = searchParams.get('chatId');
    
    if (!chatIdParam) {
      return NextResponse.json(
        { error: 'chatId parameter is required. Usage: /api/test-send-message?chatId=YOUR_CHAT_ID' },
        { status: 400 }
      );
    }
    
    const chatId = parseInt(chatIdParam, 10);
    
    if (isNaN(chatId)) {
      return NextResponse.json(
        { error: 'chatId must be a number' },
        { status: 400 }
      );
    }
    
    console.log('[TEST-SEND] Attempting to send test message to chatId:', chatId);
    
    // Проверяем наличие токена
    const botToken = process.env.TELEGRAM_BOT_TOKEN;
    if (!botToken) {
      console.error('[TEST-SEND] TELEGRAM_BOT_TOKEN is not set');
      return NextResponse.json(
        { error: 'TELEGRAM_BOT_TOKEN is not set' },
        { status: 500 }
      );
    }
    
    console.log('[TEST-SEND] Token is present, length:', botToken.length);
    
    // Пытаемся отправить сообщение
    try {
      await sendMessage({
        chatId,
        text: '✅ Тестовое сообщение от бота FindOrigin!\n\nЕсли вы видите это сообщение, значит отправка работает корректно.',
      });
      
      console.log('[TEST-SEND] Message sent successfully');
      
      return NextResponse.json({
        success: true,
        message: 'Test message sent successfully',
        chatId,
        timestamp: new Date().toISOString(),
      });
    } catch (sendError) {
      console.error('[TEST-SEND] Error sending message:', sendError);
      
      return NextResponse.json(
        {
          error: 'Failed to send message',
          details: sendError instanceof Error ? sendError.message : 'Unknown error',
          chatId,
        },
        { status: 500 }
      );
    }
  } catch (error) {
    console.error('[TEST-SEND] Unexpected error:', error);
    
    return NextResponse.json(
      {
        error: 'Unexpected error',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}


