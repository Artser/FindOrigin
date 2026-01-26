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
  
  if (!botToken) {
    throw new Error('TELEGRAM_BOT_TOKEN не установлен');
  }

  const url = `${TELEGRAM_API_URL}${botToken}/sendMessage`;
  
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        chat_id: params.chatId,
        text: params.text,
        parse_mode: params.parseMode,
        reply_to_message_id: params.replyToMessageId,
      }),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(`Telegram API error: ${response.status} - ${JSON.stringify(errorData)}`);
    }
  } catch (error) {
    console.error('Ошибка при отправке сообщения в Telegram:', error);
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



