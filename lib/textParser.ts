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
  // Нормализация URL (вынесено перед try для доступа в catch)
  const normalizedUrl = url.trim();
  
  try {
    
    // Обработка различных форматов ссылок
    if (normalizedUrl.startsWith('@')) {
      // Это упрощенный случай, реальная реализация потребует парсинга HTML страницы
      throw new Error('Прямые ссылки на каналы через @username требуют специальной обработки');
    }

    // Попытка получить HTML страницы
    const response = await axios.get(normalizedUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
      },
      timeout: 10000,
      validateStatus: (status) => status < 500,
    });

    // Проверяем статус ответа
    if (response.status === 403) {
      throw new Error(`Доступ запрещен (403) для ${normalizedUrl}`);
    }
    if (response.status === 404) {
      throw new Error(`Страница не найдена (404) для ${normalizedUrl}`);
    }
    if (response.status >= 400) {
      throw new Error(`HTTP ошибка ${response.status} для ${normalizedUrl}`);
    }

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
    // Логируем только краткую информацию об ошибке
    if (error instanceof Error) {
      const errorMessage = error.message;
      if (errorMessage.includes('403') || errorMessage.includes('Forbidden')) {
        console.warn(`[403] Доступ запрещен для Telegram-поста: ${normalizedUrl}`);
      } else if (errorMessage.includes('404') || errorMessage.includes('Not Found')) {
        console.warn(`[404] Telegram-пост не найден: ${normalizedUrl}`);
      } else if (errorMessage.includes('timeout') || errorMessage.includes('ETIMEDOUT')) {
        console.warn(`[Timeout] Превышено время ожидания для Telegram-поста: ${normalizedUrl}`);
      } else {
        console.warn(`[Error] Не удалось извлечь текст из Telegram-поста: ${errorMessage}`);
      }
    } else {
      console.warn(`[Error] Не удалось извлечь текст из Telegram-поста`);
    }
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

