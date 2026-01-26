/**
 * Endpoint для получения информации о webhook
 */

import { NextResponse } from 'next/server';
import { getWebhookInfo } from '@/lib/telegram';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

/**
 * Получение информации о webhook
 * GET /api/webhook-info
 */
export async function GET() {
  try {
    const webhookInfo = await getWebhookInfo();
    
    return NextResponse.json({
      success: true,
      webhookInfo: webhookInfo.result,
    });

  } catch (error) {
    console.error('Ошибка при получении информации о webhook:', error);
    
    return NextResponse.json(
      {
        error: 'Ошибка при получении информации о webhook',
        message: error instanceof Error ? error.message : 'Неизвестная ошибка',
      },
      { status: 500 }
    );
  }
}

