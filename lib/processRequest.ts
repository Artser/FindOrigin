/**
 * Обработка запроса пользователя
 */

import { extractText } from './textParser';
import { searchSources, filterResultsBySourceType, getSourcesContent } from './searchSources';
import { sendMessage } from './telegram';
import { SourceContent } from './searchSources';
import { compareTextsWithAI } from './openai';

/**
 * Обработка запроса пользователя
 */
export async function processUserRequest(chatId: number, input: string): Promise<void> {
  try {
    // Отправляем сообщение о начале обработки
    await sendMessage({
      chatId,
      text: '🔍 Анализирую ваш запрос...',
    });

    // Шаг 1: Извлечение текста
    const text = await extractText(input);
    
    if (!text || text.trim().length === 0) {
      await sendMessage({
        chatId,
        text: '❌ Не удалось извлечь текст из вашего сообщения. Пожалуйста, отправьте текст или ссылку на Telegram-пост.',
      });
      return;
    }

    // Шаг 2: Поиск источников (используем исходный текст напрямую)
    await sendMessage({
      chatId,
      text: '🌐 Ищу возможные источники...',
    });

    const searchResults = await searchSources(text);
    
    if (searchResults.length === 0) {
      await sendMessage({
        chatId,
        text: '❌ Не найдено источников по вашему запросу. Попробуйте переформулировать запрос.',
      });
      return;
    }

    // Шаг 3: Фильтрация результатов
    const filteredResults = filterResultsBySourceType(searchResults, ['official', 'news', 'research']);

    // Шаг 4: Получение контента из источников
    await sendMessage({
      chatId,
      text: '📄 Получаю контент из источников...',
    });

    const sourcesContent = await getSourcesContent(filteredResults, 3);

    // Шаг 5: AI-анализ и сравнение смысла
    await sendMessage({
      chatId,
      text: '🤖 Анализирую источники с помощью AI...',
    });

    let aiAnalysis: { matches: Array<{ sourceIndex: number; confidence: number; explanation: string }>; summary: string } | null = null;
    try {
      // Проверяем наличие API ключа и контента перед AI-анализом
      const hasApiKey = !!(process.env.OPENAI_API_KEY || process.env.OPENROUTER_API_KEY);
      const validSources = sourcesContent.filter(s => 
        s.text && 
        s.text.trim().length > 0 && 
        s.text !== 'Контент недоступен для загрузки'
      );
      
      if (hasApiKey && validSources.length > 0) {
        aiAnalysis = await compareTextsWithAI(
          text,
          validSources.map(s => ({
            title: s.title,
            url: s.url,
            text: s.text,
            sourceType: s.sourceType,
          }))
        );
      } else {
        console.log('AI-анализ пропущен:', {
          hasApiKey,
          validSourcesCount: validSources.length,
        });
      }
    } catch (error) {
      console.error('Ошибка при AI-анализе:', error);
      // Не прерываем выполнение, продолжаем без AI-анализа
      aiAnalysis = null;
    }

    // Шаг 6: Формирование ответа с AI-анализом
    const responseText = formatResponse(text, sourcesContent, aiAnalysis);

    // Шаг 8: Отправка результата
    await sendMessage({
      chatId,
      text: responseText,
      parseMode: 'HTML',
    });

  } catch (error) {
    console.error('Ошибка при обработке запроса:', error);
    
    const errorMessage = error instanceof Error ? error.message : 'Неизвестная ошибка';
    
    // Пытаемся отправить сообщение об ошибке пользователю
    try {
      await sendMessage({
        chatId,
        text: `❌ Произошла ошибка при обработке вашего запроса: ${errorMessage}\n\nПопробуйте позже или обратитесь к администратору.`,
      });
    } catch (sendError) {
      console.error('Не удалось отправить сообщение об ошибке пользователю:', sendError);
      // Если не удалось отправить сообщение, логируем ошибку
      console.error('Исходная ошибка:', error);
    }
  }
}

/**
 * Форматирование ответа с AI-анализом
 */
function formatResponse(
  originalText: string,
  sources: SourceContent[],
  aiAnalysis: { matches: Array<{ sourceIndex: number; confidence: number; explanation: string }>; summary: string } | null
): string {
  let response = '📋 <b>Найденные источники:</b>\n\n';
  
  if (sources.length === 0) {
    return '❌ Не удалось получить контент из источников.';
  }

  sources.forEach((source, index) => {
    const sourceTypeEmoji = {
      official: '🏛️',
      news: '📰',
      blog: '✍️',
      research: '🔬',
      unknown: '📄',
    }[source.sourceType];

    const sourceTypeName = {
      official: 'Официальный источник',
      news: 'Новостной сайт',
      blog: 'Блог',
      research: 'Исследование',
      unknown: 'Другой источник',
    }[source.sourceType];

    // Находим AI-анализ для этого источника
    const match = aiAnalysis?.matches.find(m => m.sourceIndex === index);
    const confidence = match ? match.confidence : null;

    response += `${index + 1}. ${sourceTypeEmoji} <b>${source.title}</b>\n`;
    response += `   Тип: ${sourceTypeName}\n`;
    
    if (confidence !== null) {
      const confidenceEmoji = confidence >= 70 ? '✅' : confidence >= 40 ? '⚠️' : '❌';
      response += `   ${confidenceEmoji} Уверенность: ${confidence}%\n`;
      if (match?.explanation) {
        response += `   ${match.explanation.substring(0, 150)}${match.explanation.length > 150 ? '...' : ''}\n`;
      }
    }
    
    response += `   <a href="${source.url}">${source.url}</a>\n`;
    
    if (source.text && source.text.length > 0) {
      const preview = source.text.substring(0, 200);
      response += `   ${preview}${source.text.length > 200 ? '...' : ''}\n`;
    }
    
    response += '\n';
  });

  if (aiAnalysis?.summary) {
    response += '\n📊 <b>AI-анализ:</b>\n';
    response += `${aiAnalysis.summary}\n`;
  }

  return response;
}

