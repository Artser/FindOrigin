import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

const TELEGRAM_API_URL = 'https://api.telegram.org/bot';

export async function GET() {
  const botToken = process.env.TELEGRAM_BOT_TOKEN;
  
  if (!botToken) {
    return NextResponse.json(
      { error: 'TELEGRAM_BOT_TOKEN not set' },
      { status: 500 }
    );
  }

  try {
    const response = await fetch(
      `${TELEGRAM_API_URL}${botToken}/getUpdates?offset=-1&limit=1&timeout=1`,
      { method: 'GET' }
    );

    if (!response.ok) {
      return NextResponse.json(
        { error: `Telegram API error: ${response.status}` },
        { status: response.status }
      );
    }

    const data = await response.json();

    if (!data.ok || !data.result || data.result.length === 0) {
      return NextResponse.json({
        ok: true,
        message: 'No new updates',
        updates: [],
      });
    }

    const updates = data.result;
    const processedUpdates: number[] = [];

    for (const update of updates) {
      try {
        const message = update.message || update.edited_message;
        
        if (!message) {
          continue;
        }

        const chatId = message.chat.id;
        const text = message.text;

        if (text?.startsWith('/start')) {
          console.log('[POLL] Processing /start command for chatId:', chatId);
          try {
            const { sendMessage } = await import('@/lib/telegram');
            await sendMessage({
              chatId,
              text: '👋 Привет! Я бот FindOrigin.\n\nОтправьте мне текст или ссылку на Telegram-пост, и я найду возможные источники этой информации.\n\n🤖 Сравниваю источники с исходным текстом через AI...',
            });
            console.log('[POLL] Welcome message sent');
          } catch (error) {
            console.error('[POLL] Error sending welcome message:', error);
          }
        } else if (text && text.trim().length > 0) {
          console.log('[POLL] Processing message for chatId:', chatId);
          const { processUserRequest } = await import('@/lib/processRequest');
          processUserRequest(chatId, text).catch((error) => {
            console.error('[POLL] Error processing request:', error);
          });
        }

        processedUpdates.push(update.update_id);
      } catch (error) {
        console.error('[POLL] Error processing update:', error);
      }
    }

    if (processedUpdates.length > 0) {
      const lastUpdateId = Math.max(...processedUpdates);
      try {
        await fetch(
          `${TELEGRAM_API_URL}${botToken}/getUpdates?offset=${lastUpdateId + 1}`,
          { method: 'GET' }
        );
      } catch (error) {
        console.error('[POLL] Error confirming updates:', error);
      }
    }

    return NextResponse.json({
      ok: true,
      processed: processedUpdates.length,
      updates: processedUpdates,
    });

  } catch (error) {
    console.error('[POLL] Error:', error);
    return NextResponse.json(
      {
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

