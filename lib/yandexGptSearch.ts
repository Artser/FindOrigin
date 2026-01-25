/**
 * Поиск через Yandex GPT API
 * 
 * Yandex GPT используется для поиска источников информации через AI-анализ запроса.
 */

import axios from 'axios';
import { SearchResult } from './searchSources';

/**
 * Определение типа источника по URL (упрощенная версия)
 */
function determineSourceTypeFromUrl(url: string): 'official' | 'news' | 'blog' | 'research' | 'unknown' {
  try {
    const hostname = new URL(url).hostname.toLowerCase();
    
    if (/\.gov\.|\.edu\.|kremlin\.ru|government\.ru/.test(hostname)) {
      return 'official';
    }
    if (/rbc\.ru|ria\.ru|tass\.ru|interfax\.ru|lenta\.ru|gazeta\.ru/.test(hostname)) {
      return 'news';
    }
    if (/arxiv\.org|pubmed|scholar|researchgate|academia\.edu/.test(hostname)) {
      return 'research';
    }
    if (/medium\.com|habr\.com|livejournal\.com|blogspot/.test(hostname)) {
      return 'blog';
    }
    return 'unknown';
  } catch {
    return 'unknown';
  }
}

/**
 * Поиск источников через Yandex GPT API
 * 
 * Yandex GPT анализирует запрос и предлагает релевантные источники информации.
 */
export async function searchWithYandexGPT(query: string): Promise<SearchResult[]> {
  const apiKey = process.env.YANDEX_CLOUD_API_KEY;
  const folderId = process.env.YANDEX_FOLDER_ID;
  const authType = process.env.YANDEX_AUTH_TYPE || 'Api-Key';
  
  if (!apiKey || !folderId) {
    throw new Error('Yandex Cloud API credentials не установлены (нужны YANDEX_CLOUD_API_KEY и YANDEX_FOLDER_ID)');
  }

  const url = 'https://llm.api.cloud.yandex.net/foundationModels/v1/completion';
  
  try {
    // Формируем промпт для поиска источников информации
    const prompt = `Найди релевантные источники информации в интернете по запросу: "${query}".

Требования:
1. Найди 3-5 наиболее релевантных источников
2. Для каждого источника укажи:
   - Название источника
   - Полный URL (https://...)
   - Краткое описание содержимого
3. Приоритет отдавай официальным сайтам, новостным источникам и научным публикациям

Формат ответа (JSON):
{
  "sources": [
    {
      "title": "Название источника",
      "url": "https://example.com/page",
      "description": "Краткое описание"
    }
  ]
}`;

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    // Добавляем заголовок авторизации в зависимости от типа
    if (authType === 'Api-Key') {
      headers['Authorization'] = `Api-Key ${apiKey}`;
    } else if (authType === 'IAM') {
      headers['Authorization'] = `Bearer ${apiKey}`;
    }

    const response = await axios.post(url, {
      modelUri: `gpt://${folderId}/yandexgpt/latest`,
      completionOptions: {
        stream: false,
        temperature: 0.7,
        maxTokens: 3000,
      },
      messages: [
        {
          role: 'user',
          text: prompt,
        },
      ],
    }, {
      headers,
      timeout: 30000,
    });
    
    const gptResponse = response.data.result?.alternatives?.[0]?.message?.text || '';
    
    if (!gptResponse) {
      throw new Error('Yandex GPT не вернул ответ');
    }

    // Парсим JSON ответ от Yandex GPT
    try {
      const jsonMatch = gptResponse.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        if (parsed.sources && Array.isArray(parsed.sources)) {
          return parsed.sources.map((source: any) => ({
            title: source.title || 'Без названия',
            url: source.url || '',
            snippet: source.description || '',
            sourceType: determineSourceTypeFromUrl(source.url || '') as 'official' | 'news' | 'blog' | 'research' | 'unknown',
          })).filter((result: any) => result.url && result.url.startsWith('http'));
        }
      }
    } catch (parseError) {
      console.warn('Не удалось распарсить JSON от Yandex GPT, пытаемся извлечь URL из текста');
    }

    // Fallback: извлекаем URL из текстового ответа
    const urlPattern = /https?:\/\/[^\s<>"{}|\\^`\[\]]+/gi;
    const urls = gptResponse.match(urlPattern) || [];
    
    if (urls.length > 0) {
      return urls.slice(0, 5).map((url: string, index: number) => {
        const urlIndex = gptResponse.indexOf(url);
        const context = gptResponse.substring(Math.max(0, urlIndex - 150), urlIndex + url.length + 150);
        const titleMatch = context.match(/(?:название|источник|сайт|ресурс|title)[:：]\s*([^\n\.]+)/i);
        const title = titleMatch ? titleMatch[1].trim() : `Источник ${index + 1}`;
        
        return {
          title: title.substring(0, 100),
          url: url,
          snippet: context.substring(0, 300),
          sourceType: determineSourceTypeFromUrl(url) as 'official' | 'news' | 'blog' | 'research' | 'unknown',
        };
      });
    }

    throw new Error('Yandex GPT не вернул источники с URL. Попробуйте переформулировать запрос или используйте другой поисковый API.');

  } catch (error: any) {
    console.error('Ошибка при поиске через Yandex GPT:', error);
    
    if (error.response) {
      const status = error.response.status;
      const errorData = error.response.data;
      const errorMessage = errorData?.message || error.message;
      throw new Error(`Yandex GPT API error (${status}): ${errorMessage}`);
    } else if (error.request) {
      throw new Error('Не удалось получить ответ от Yandex GPT API. Проверьте подключение к интернету.');
    } else {
      throw new Error(`Ошибка при запросе к Yandex GPT API: ${error.message}`);
    }
  }
}

