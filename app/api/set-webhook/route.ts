/**
 * Endpoint для установки webhook URL
 */

import { NextRequest, NextResponse } from 'next/server';
import { setWebhook } from '@/lib/telegram';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

/**
 * Установка webhook URL
 * GET /api/set-webhook?url=https://your-domain.com/api/webhook
 */
export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const webhookUrl = searchParams.get('url');
    const secretToken = searchParams.get('secret') || process.env.TELEGRAM_WEBHOOK_SECRET;

    if (!webhookUrl) {
      return NextResponse.json(
        { error: 'Параметр url обязателен' },
        { status: 400 }
      );
    }

    await setWebhook(webhookUrl, secretToken || undefined);

    return NextResponse.json({
      success: true,
      message: `Webhook успешно установлен: ${webhookUrl}`,
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


