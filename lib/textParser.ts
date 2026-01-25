/**
 * Парсинг текста и извлечение данных из Telegram-постов
 */

import axios from 'axios';

/**
 * Извлечение текста из обычного сообщения
 */
export function extractTextFromMessage(text: string | undefined): string {
  if (!text) {
    return '';
  }
  return text.trim();
}

/**
 * Проверка, является ли строка ссылкой на Telegram-пост
 */
export function isTelegramLink(url: string): boolean {
  const telegramPatterns = [
    /^https?:\/\/(t\.me|telegram\.me|telegram\.org)\//,
    /^@[\w]+/,
  ];
  
  return telegramPatterns.some(pattern => pattern.test(url));
}

/**
 * Извлечение текста из ссылки на Telegram-пост
 * Примечание: Telegram не предоставляет публичный API для получения содержимого постов
 * Это упрощенная реализация, которая может потребовать дополнительной настройки
 */
export async function extractTextFromTelegramPost(url: string): Promise<string> {
  try {
    // Нормализация URL
    let normalizedUrl = url.trim();
    
    // Обработка различных форматов ссылок
    if (normalizedUrl.startsWith('@')) {
      // Это упрощенный случай, реальная реализация потребует парсинга HTML страницы
      throw new Error('Прямые ссылки на каналы через @username требуют специальной обработки');
    }

    // Попытка получить HTML страницы
    const response = await axios.get(normalizedUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 10000,
    });

    // Простой парсинг HTML для извлечения текста поста
    // В реальности это может быть сложнее из-за динамической загрузки контента
    const html = response.data;
    
    // Попытка найти текст поста в HTML
    // Это упрощенная версия, может потребоваться более сложный парсинг
    const textMatch = html.match(/<div[^>]*class="[^"]*tgme_widget_message_text[^"]*"[^>]*>([\s\S]*?)<\/div>/);
    
    if (textMatch) {
      // Удаление HTML тегов
      const text = textMatch[1]
        .replace(/<[^>]+>/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
      return text;
    }

    // Если не удалось найти структурированный текст, возвращаем пустую строку
    return '';
  } catch (error) {
    console.error('Ошибка при извлечении текста из Telegram-поста:', error);
    throw new Error(`Не удалось извлечь текст из поста: ${error instanceof Error ? error.message : 'Неизвестная ошибка'}`);
  }
}

/**
 * Извлечение текста из сообщения или ссылки
 */
export async function extractText(input: string): Promise<string> {
  // Проверяем, является ли ввод ссылкой
  if (isTelegramLink(input)) {
    return await extractTextFromTelegramPost(input);
  }
  
  // Иначе возвращаем текст как есть
  return extractTextFromMessage(input);
}

