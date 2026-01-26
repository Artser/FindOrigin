/**
 * Webhook endpoint для Telegram
 */

import { NextRequest, NextResponse } from 'next/server';
import { TelegramUpdate } from '@/lib/telegram';
import { processUserRequest } from '@/lib/processRequest';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

/**
 * Обработка POST запросов от Telegram
 */
export async function POST(request: NextRequest) {
  const startTime = Date.now();
  const timestamp = new Date().toISOString();
  
  // Используем process.stderr.write для гарантированного логирования
  process.stderr.write(`[WEBHOOK] ========================================\n`);
  process.stderr.write(`[WEBHOOK] POST запрос получен в ${timestamp}\n`);
  process.stderr.write(`[WEBHOOK] URL: ${request.url}\n`);
  process.stderr.write(`[WEBHOOK] Method: ${request.method}\n`);
  
  // Также логируем через console (для совместимости)
  console.error('[WEBHOOK] ========================================');
  console.error('[WEBHOOK] POST запрос получен!');
  console.error('[WEBHOOK] Время:', timestamp);
  console.log('[WEBHOOK] ========================================');
  console.log('[WEBHOOK] Получен POST запрос на /api/webhook');
  console.log('[WEBHOOK] Время:', timestamp);
  console.log('[WEBHOOK] URL:', request.url);
  console.log('[WEBHOOK] Method:', request.method);
  
  try {
    // Логируем заголовки
    console.log('[WEBHOOK] Headers:', {
      'content-type': request.headers.get('content-type'),
      'user-agent': request.headers.get('user-agent'),
      'x-telegram-bot-api-secret-token': request.headers.get('x-telegram-bot-api-secret-token') ? 'present' : 'missing',
      'x-forwarded-for': request.headers.get('x-forwarded-for'),
      'x-real-ip': request.headers.get('x-real-ip'),
    });
    
    // Читаем тело запроса
    console.log('[WEBHOOK] Начинаем чтение тела запроса...');
    const bodyText = await request.text();
    console.log('[WEBHOOK] Тело запроса получено, длина:', bodyText.length, 'символов');
    console.log('[WEBHOOK] Первые 200 символов тела:', bodyText.substring(0, 200));
    
    // Парсим JSON
    let body: TelegramUpdate;
    try {
      body = JSON.parse(bodyText) as TelegramUpdate;
      console.log('[WEBHOOK] JSON успешно распарсен');
    } catch (parseError) {
      console.error('[WEBHOOK] Ошибка парсинга JSON:', parseError);
      console.error('[WEBHOOK] Тело запроса:', bodyText);
      throw new Error('Неверный формат JSON в теле запроса');
    }
    
    console.log('[WEBHOOK] Получен webhook от Telegram:', {
      updateId: body.update_id,
      hasMessage: !!body.message,
      hasEditedMessage: !!body.edited_message,
      timestamp: new Date().toISOString(),
    });
    
    // Проверка секретного токена (если установлен)
    const webhookSecret = process.env.TELEGRAM_WEBHOOK_SECRET;
    if (webhookSecret) {
      const secretHeader = request.headers.get('X-Telegram-Bot-Api-Secret-Token');
      if (secretHeader !== webhookSecret) {
        console.warn('Неверный секретный токен webhook');
        return NextResponse.json(
          { error: 'Unauthorized' },
          { status: 401 }
        );
      }
    }

    // Извлечение данных из update
    const message = body.message || body.edited_message;
    
    if (!message) {
      // Это может быть другой тип update (callback_query, inline_query и т.д.)
      console.log('Update без сообщения, пропускаем');
      return NextResponse.json({ ok: true });
    }

    const chatId = message.chat.id;
    const text = message.text;
    
    console.log('Обработка сообщения:', {
      chatId,
      text: text?.substring(0, 50) + (text && text.length > 50 ? '...' : ''),
      isCommand: text?.startsWith('/'),
    });

    // Обработка команд
    if (text?.startsWith('/')) {
      const command = text.split(' ')[0];
      
      if (command === '/start') {
        // Импортируем sendMessage динамически, чтобы избежать циклических зависимостей
        const { sendMessage } = await import('@/lib/telegram');
        await sendMessage({
          chatId,
          text: '👋 Привет! Я бот FindOrigin.\n\nОтправьте мне текст или ссылку на Telegram-пост, и я найду возможные источники этой информации.',
        });
        return NextResponse.json({ ok: true });
      }
      
      if (command === '/help') {
        const { sendMessage } = await import('@/lib/telegram');
        await sendMessage({
          chatId,
          text: '📖 <b>Справка по использованию бота:</b>\n\n' +
                '1. Отправьте текст сообщения\n' +
                '2. Или отправьте ссылку на Telegram-пост\n\n' +
                'Бот проанализирует текст, найдет возможные источники и предоставит оценку уверенности.\n\n' +
                '<b>Команды:</b>\n' +
                '/start - Начать работу\n' +
                '/help - Показать эту справку',
          parseMode: 'HTML',
        });
        return NextResponse.json({ ok: true });
      }
    }

    // Проверка наличия текста
    if (!text || text.trim().length === 0) {
      return NextResponse.json({ ok: true });
    }

    // Запускаем обработку асинхронно (не ждем завершения)
    // Это позволяет быстро вернуть 200 OK
    console.log('[WEBHOOK] Запуск обработки запроса для chatId:', chatId);
    console.log('[WEBHOOK] Текст сообщения:', text?.substring(0, 100));
    
    processUserRequest(chatId, text).catch(async (error) => {
      console.error('Ошибка при асинхронной обработке запроса:', error);
      console.error('Детали ошибки:', {
        message: error instanceof Error ? error.message : 'Неизвестная ошибка',
        stack: error instanceof Error ? error.stack : undefined,
      });
      
      // Пытаемся отправить сообщение об ошибке пользователю
      try {
        const { sendMessage } = await import('@/lib/telegram');
        const errorMessage = error instanceof Error ? error.message : 'Неизвестная ошибка';
        await sendMessage({
          chatId,
          text: `❌ Произошла ошибка при обработке вашего запроса: ${errorMessage}\n\nПопробуйте позже или обратитесь к администратору.`,
        });
        console.log('Сообщение об ошибке отправлено пользователю');
      } catch (sendError) {
        console.error('Не удалось отправить сообщение об ошибке:', sendError);
      }
    });

    // Сразу возвращаем 200 OK
    const duration = Date.now() - startTime;
    console.log(`[WEBHOOK] Запрос обработан за ${duration}ms, возвращаем 200 OK`);
    return NextResponse.json({ ok: true });

  } catch (error) {
    const duration = Date.now() - startTime;
    console.error('[WEBHOOK] Ошибка в webhook обработчике:', error);
    console.error('[WEBHOOK] Детали ошибки:', {
      message: error instanceof Error ? error.message : 'Неизвестная ошибка',
      stack: error instanceof Error ? error.stack : undefined,
      duration: `${duration}ms`,
    });
    
    // Все равно возвращаем 200 OK, чтобы Telegram не повторял запрос
    return NextResponse.json(
      { ok: false, error: 'Internal server error' },
      { status: 200 }
    );
  }
}

/**
 * Обработка GET запросов (для проверки работоспособности)
 */
export async function GET() {
  return NextResponse.json({
    status: 'ok',
    message: 'FindOrigin Telegram Bot Webhook',
    timestamp: new Date().toISOString(),
  });
}

