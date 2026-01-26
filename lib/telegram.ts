/**
 * Утилиты для работы с Telegram Bot API
 */

const TELEGRAM_API_URL = 'https://api.telegram.org/bot';

export interface TelegramMessage {
  message_id: number;
  chat: {
    id: number;
    type: string;
  };
  text?: string;
  entities?: Array<{
    type: string;
    offset: number;
    length: number;
    url?: string;
  }>;
}

export interface TelegramUpdate {
  update_id: number;
  message?: TelegramMessage;
  edited_message?: TelegramMessage;
}

export interface SendMessageParams {
  chatId: number;
  text: string;
  parseMode?: 'HTML' | 'Markdown' | 'MarkdownV2';
  replyToMessageId?: number;
}

/**
 * Отправка сообщения через Telegram Bot API
 */
export async function sendMessage(params: SendMessageParams): Promise<void> {
  const botToken = process.env.TELEGRAM_BOT_TOKEN;
  
  console.log('[TELEGRAM] sendMessage вызван:', {
    chatId: params.chatId,
    textLength: params.text.length,
    parseMode: params.parseMode,
    hasToken: !!botToken,
  });
  
  if (!botToken) {
    const error = new Error('TELEGRAM_BOT_TOKEN не установлен');
    console.error('[TELEGRAM] Ошибка:', error.message);
    throw error;
  }

  const url = `${TELEGRAM_API_URL}${botToken}/sendMessage`;
  
  console.log('[TELEGRAM] Отправка запроса на:', url.replace(botToken, 'TOKEN_HIDDEN'));
  
  try {
    const requestBody = {
      chat_id: params.chatId,
      text: params.text,
      parse_mode: params.parseMode,
      reply_to_message_id: params.replyToMessageId,
    };
    
    console.log('[TELEGRAM] Тело запроса:', {
      chat_id: requestBody.chat_id,
      textLength: requestBody.text.length,
      parse_mode: requestBody.parse_mode,
    });
    
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    console.log('[TELEGRAM] Ответ получен, статус:', response.status);

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      const error = new Error(`Telegram API error: ${response.status} - ${JSON.stringify(errorData)}`);
      console.error('[TELEGRAM] Ошибка API:', error.message);
      console.error('[TELEGRAM] Детали ошибки:', errorData);
      throw error;
    }
    
    const responseData = await response.json().catch(() => ({}));
    console.log('[TELEGRAM] Сообщение успешно отправлено:', {
      messageId: responseData.result?.message_id,
      ok: responseData.ok,
    });
  } catch (error) {
    console.error('[TELEGRAM] Ошибка при отправке сообщения в Telegram:', error);
    console.error('[TELEGRAM] Детали ошибки:', {
      message: error instanceof Error ? error.message : 'Неизвестная ошибка',
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw error;
  }
}

/**
 * Установка webhook URL
 */
export async function setWebhook(webhookUrl: string, secretToken?: string): Promise<void> {
  const botToken = process.env.TELEGRAM_BOT_TOKEN;
  
  if (!botToken) {
    throw new Error('TELEGRAM_BOT_TOKEN не установлен');
  }

  const url = `${TELEGRAM_API_URL}${botToken}/setWebhook`;
  
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        url: webhookUrl,
        secret_token: secretToken,
      }),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(`Ошибка установки webhook: ${response.status} - ${JSON.stringify(errorData)}`);
    }

    const data = await response.json();
    if (!data.ok) {
      throw new Error(`Webhook не установлен: ${data.description}`);
    }
  } catch (error) {
    console.error('Ошибка при установке webhook:', error);
    throw error;
  }
}

/**
 * Получение информации о боте
 */
export async function getMe(): Promise<any> {
  const botToken = process.env.TELEGRAM_BOT_TOKEN;
  
  if (!botToken) {
    throw new Error('TELEGRAM_BOT_TOKEN не установлен');
  }

  const url = `${TELEGRAM_API_URL}${botToken}/getMe`;
  
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`Telegram API error: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Ошибка при получении информации о боте:', error);
    throw error;
  }
}

/**
 * Получение информации о webhook
 */
export async function getWebhookInfo(): Promise<any> {
  const botToken = process.env.TELEGRAM_BOT_TOKEN;
  
  if (!botToken) {
    throw new Error('TELEGRAM_BOT_TOKEN не установлен');
  }

  const url = `${TELEGRAM_API_URL}${botToken}/getWebhookInfo`;
  
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`Telegram API error: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Ошибка при получении информации о webhook:', error);
    throw error;
  }
}



