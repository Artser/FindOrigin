/**
 * Endpoint для автоматической настройки webhook
 * GET /api/setup-webhook
 */

import { NextRequest, NextResponse } from 'next/server';
import { setWebhook } from '@/lib/telegram';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  try {
    const botToken = process.env.TELEGRAM_BOT_TOKEN;
    
    if (!botToken) {
      return NextResponse.json(
        { 
          error: 'TELEGRAM_BOT_TOKEN не установлен',
          message: 'Установите переменную окружения TELEGRAM_BOT_TOKEN'
        },
        { status: 500 }
      );
    }

    // Получаем URL из переменной окружения или из параметра запроса
    const webhookUrl = process.env.WEBHOOK_URL || 
                       request.nextUrl.searchParams.get('url') ||
                       `${request.nextUrl.origin}/api/telegram`;

    const secretToken = process.env.TELEGRAM_WEBHOOK_SECRET;

    await setWebhook(webhookUrl, secretToken || undefined);

    return NextResponse.json({
      success: true,
      message: 'Webhook успешно установлен',
      webhookUrl,
      botToken: botToken.substring(0, 10) + '...', // Показываем только начало токена
    });

  } catch (error) {
    console.error('Ошибка при установке webhook:', error);
    
    return NextResponse.json(
      {
        error: 'Ошибка при установке webhook',
        message: error instanceof Error ? error.message : 'Неизвестная ошибка',
      },
      { status: 500 }
    );
  }
}
