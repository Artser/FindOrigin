/**
 * Поиск источников информации
 */

import axios from 'axios';
import * as cheerio from 'cheerio';
import { ExtractedElements } from './keyElementsExtractor';
import { searchWithYandexGPT } from './yandexGptSearch';

export interface SearchResult {
  title: string;
  url: string;
  snippet: string;
  sourceType: 'official' | 'news' | 'blog' | 'research' | 'unknown';
}

export interface SourceContent {
  url: string;
  title: string;
  text: string;
  sourceType: 'official' | 'news' | 'blog' | 'research' | 'unknown';
}

/**
 * Определение типа источника по URL
 */
function determineSourceType(url: string): 'official' | 'news' | 'blog' | 'research' | 'unknown' {
  try {
    const hostname = new URL(url).hostname.toLowerCase();
  
  // Официальные сайты
  const officialPatterns = [
    /\.gov\./,
    /\.edu\./,
    /\.ac\./,
    /минобрнауки/,
    /минздрав/,
    /правительство/,
    /kremlin\.ru/,
    /government\.ru/,
  ];
  
  // Новостные сайты
  const newsPatterns = [
    /\.ru$/,
    /rbc\.ru/,
    /ria\.ru/,
    /tass\.ru/,
    /interfax\.ru/,
    /lenta\.ru/,
    /gazeta\.ru/,
    /vedomosti\.ru/,
    /kommersant\.ru/,
    /rt\.com/,
  ];
  
  // Исследования и научные публикации
  const researchPatterns = [
    /arxiv\.org/,
    /pubmed/,
    /scholar/,
    /researchgate/,
    /academia\.edu/,
    /springer/,
    /ieee\.org/,
    /nature\.com/,
    /science\.org/,
  ];
  
  // Блоги
  const blogPatterns = [
    /medium\.com/,
    /habr\.com/,
    /livejournal\.com/,
    /blogspot/,
    /wordpress\.com/,
  ];

  if (officialPatterns.some(pattern => pattern.test(hostname))) {
    return 'official';
  }
  
  if (researchPatterns.some(pattern => pattern.test(hostname))) {
    return 'research';
  }
  
  if (newsPatterns.some(pattern => pattern.test(hostname))) {
    return 'news';
  }
  
  if (blogPatterns.some(pattern => pattern.test(hostname))) {
    return 'blog';
  }
  
  return 'unknown';
  } catch {
    return 'unknown';
  }
}

/**
 * Формирование поискового запроса на основе извлеченных элементов
 */
export function buildSearchQuery(elements: ExtractedElements, originalText: string): string {
  const queryParts: string[] = [];
  
  // Добавляем ключевые утверждения (первые 2)
  if (elements.keyStatements.length > 0) {
    const firstStatement = elements.keyStatements[0].split(' ').slice(0, 5).join(' ');
    queryParts.push(`"${firstStatement}"`);
  }
  
  // Добавляем имена (первые 2)
  if (elements.names.length > 0) {
    queryParts.push(...elements.names.slice(0, 2));
  }
  
  // Добавляем даты (первую)
  if (elements.dates.length > 0) {
    queryParts.push(elements.dates[0]);
  }
  
  // Если запрос слишком короткий, добавляем ключевые слова из исходного текста
  if (queryParts.length < 3) {
    const words = originalText
      .split(/\s+/)
      .filter(word => word.length > 4)
      .slice(0, 3);
    queryParts.push(...words);
  }
  
  return queryParts.join(' ');
}

/**
 * Поиск через Google Custom Search API
 */
async function searchWithGoogle(query: string): Promise<SearchResult[]> {
  const apiKey = process.env.GOOGLE_SEARCH_API_KEY;
  const engineId = process.env.GOOGLE_SEARCH_ENGINE_ID;
  
  if (!apiKey || !engineId) {
    throw new Error('Google Search API credentials не установлены');
  }

  const url = 'https://www.googleapis.com/customsearch/v1';
  
  try {
    const response = await axios.get(url, {
      params: {
        key: apiKey,
        cx: engineId,
        q: query,
        num: 10, // Максимум результатов
      },
      timeout: 10000,
    });

    if (!response.data.items) {
      return [];
    }

    return response.data.items.map((item: any) => ({
      title: item.title,
      url: item.link,
      snippet: item.snippet || '',
      sourceType: determineSourceType(item.link),
    }));
  } catch (error: any) {
    console.error('Ошибка при поиске через Google:', error);
    
    // Извлекаем детальное сообщение об ошибке из axios
    if (error.response) {
      // Сервер ответил с кодом ошибки
      const status = error.response.status;
      const errorData = error.response.data;
      const errorMessage = errorData?.error?.message || errorData?.error || error.message;
      throw new Error(`Google Search API error (${status}): ${errorMessage}`);
    } else if (error.request) {
      // Запрос был отправлен, но ответа не получено
      throw new Error('Не удалось получить ответ от Google Search API. Проверьте подключение к интернету.');
    } else {
      // Ошибка при настройке запроса
      throw new Error(`Ошибка при запросе к Google Search API: ${error.message}`);
    }
  }
}

/**
 * Поиск через SerpAPI
 */
async function searchWithSerpAPI(query: string): Promise<SearchResult[]> {
  const apiKey = process.env.SERPAPI_KEY;
  
  if (!apiKey) {
    throw new Error('SerpAPI key не установлен');
  }

  const url = 'https://serpapi.com/search';
  
  try {
    const response = await axios.get(url, {
      params: {
        engine: 'google',
        q: query,
        api_key: apiKey,
        num: 10,
        hl: 'ru',
        gl: 'ru',
      },
      timeout: 10000,
    });

    if (!response.data.organic_results) {
      return [];
    }

    return response.data.organic_results.map((item: any) => ({
      title: item.title,
      url: item.link,
      snippet: item.snippet || '',
      sourceType: determineSourceType(item.link),
    }));
  } catch (error: any) {
    console.error('Ошибка при поиске через SerpAPI:', error);
    
    // Извлекаем детальное сообщение об ошибке из axios
    if (error.response) {
      // Сервер ответил с кодом ошибки
      const status = error.response.status;
      const errorData = error.response.data;
      const errorMessage = errorData?.error || error.message;
      throw new Error(`SerpAPI error (${status}): ${errorMessage}`);
    } else if (error.request) {
      // Запрос был отправлен, но ответа не получено
      throw new Error('Не удалось получить ответ от SerpAPI. Проверьте подключение к интернету.');
    } else {
      // Ошибка при настройке запроса
      throw new Error(`Ошибка при запросе к SerpAPI: ${error.message}`);
    }
  }
}

/**
 * Поиск через Yandex Search API
 */
async function searchWithYandex(query: string): Promise<SearchResult[]> {
  const apiKey = process.env.YANDEX_SEARCH_API_KEY;
  
  if (!apiKey) {
    throw new Error('Yandex Search API key не установлен');
  }

  const url = 'https://yandex.com/search/xml';
  
  try {
    const response = await axios.get(url, {
      params: {
        user: apiKey,
        key: apiKey,
        query: query,
        lr: 213, // Регион: Москва (можно изменить)
        page: 0,
        groupby: 'attr=d.mode=deep.groups-on-page=10.docs-in-group=1',
      },
      timeout: 10000,
    });

    // Yandex XML API возвращает XML, нужно парсить
    // Для упрощения используем JSON API если доступен
    // Или парсим XML ответ
    
    // Временная заглушка - Yandex XML API требует специальной обработки
    throw new Error('Yandex XML API требует специальной обработки XML. Используйте Yandex JSON API или другой сервис.');
  } catch (error) {
    console.error('Ошибка при поиске через Yandex:', error);
    throw error;
  }
}

/**
 * Поиск через Bing Search API
 */
async function searchWithBing(query: string): Promise<SearchResult[]> {
  const apiKey = process.env.BING_SEARCH_API_KEY;
  
  if (!apiKey) {
    throw new Error('Bing Search API key не установлен');
  }

  const url = 'https://api.bing.microsoft.com/v7.0/search';
  
  try {
    const response = await axios.get(url, {
      params: {
        q: query,
        count: 10,
        mkt: 'ru-RU', // Рынок: Россия
      },
      headers: {
        'Ocp-Apim-Subscription-Key': apiKey,
      },
      timeout: 10000,
    });

    if (!response.data.webPages || !response.data.webPages.value) {
      return [];
    }

    return response.data.webPages.value.map((item: any) => ({
      title: item.name,
      url: item.url,
      snippet: item.snippet || '',
      sourceType: determineSourceType(item.url),
    }));
  } catch (error: any) {
    console.error('Ошибка при поиске через Bing:', error);
    
    // Извлекаем детальное сообщение об ошибке из axios
    if (error.response) {
      // Сервер ответил с кодом ошибки
      const status = error.response.status;
      const errorData = error.response.data;
      const errorMessage = errorData?.error?.message || errorData?.error || error.message;
      throw new Error(`Bing Search API error (${status}): ${errorMessage}`);
    } else if (error.request) {
      // Запрос был отправлен, но ответа не получено
      throw new Error('Не удалось получить ответ от Bing Search API. Проверьте подключение к интернету.');
    } else {
      // Ошибка при настройке запроса
      throw new Error(`Ошибка при запросе к Bing Search API: ${error.message}`);
    }
  }
}

/**
 * Поиск источников
 */
export async function searchSources(query: string): Promise<SearchResult[]> {
  // Пробуем использовать доступный API в порядке приоритета
  // 1. Google Custom Search (если доступен)
  if (process.env.GOOGLE_SEARCH_API_KEY && process.env.GOOGLE_SEARCH_ENGINE_ID) {
    return await searchWithGoogle(query);
  }
  
  // 2. Bing Search API (работает в России)
  if (process.env.BING_SEARCH_API_KEY) {
    return await searchWithBing(query);
  }
  
  // 3. SerpAPI (если доступен)
  if (process.env.SERPAPI_KEY) {
    return await searchWithSerpAPI(query);
  }
  
  // 4. Yandex GPT API (для поиска через AI) - с обработкой ошибок
  if (process.env.YANDEX_CLOUD_API_KEY && process.env.YANDEX_FOLDER_ID) {
    try {
      return await searchWithYandexGPT(query);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Неизвестная ошибка';
      // Если ошибка 403 или другая критическая, пробуем другие API или выбрасываем понятную ошибку
      if (errorMessage.includes('403') || errorMessage.includes('Forbidden')) {
        console.error('Yandex GPT API вернул 403. Проверьте биллинг и права доступа.');
        // Пробуем другие API, если они есть
        if (process.env.SERPAPI_KEY) {
          console.log('Пробуем SerpAPI как альтернативу...');
          return await searchWithSerpAPI(query);
        }
        throw new Error('Yandex GPT API вернул ошибку 403 (Forbidden). Проверьте биллинг-аккаунт в Yandex Cloud и права доступа API ключа. Или настройте другой поисковый API (Google, Bing, SerpAPI).');
      }
      // Для других ошибок просто пробрасываем дальше
      throw error;
    }
  }
  
  throw new Error('Не настроен ни один поисковый API. Настройте GOOGLE_SEARCH_API_KEY (с GOOGLE_SEARCH_ENGINE_ID), BING_SEARCH_API_KEY, SERPAPI_KEY или YANDEX_CLOUD_API_KEY (с YANDEX_FOLDER_ID)');
}

/**
 * Фильтрация результатов по типам источников
 */
export function filterResultsBySourceType(
  results: SearchResult[],
  preferredTypes: ('official' | 'news' | 'blog' | 'research')[] = ['official', 'news', 'research']
): SearchResult[] {
  // Сначала сортируем по приоритету типов
  const typePriority: Record<string, number> = {
    official: 4,
    research: 3,
    news: 2,
    blog: 1,
    unknown: 0,
  };

  return results
    .filter(result => {
      if (result.sourceType === 'unknown') return true;
      return preferredTypes.includes(result.sourceType as 'official' | 'news' | 'blog' | 'research');
    })
    .sort((a, b) => {
      const priorityDiff = typePriority[b.sourceType] - typePriority[a.sourceType];
      if (priorityDiff !== 0) {
        return priorityDiff;
      }
      // Если приоритет одинаковый, сортируем по длине snippet (более информативные выше)
      return b.snippet.length - a.snippet.length;
    });
}

/**
 * Извлечение текста со страницы источника
 */
export async function extractSourceContent(url: string): Promise<SourceContent> {
  try {
    // Валидация URL
    try {
      new URL(url);
    } catch {
      throw new Error(`Некорректный URL: ${url}`);
    }

    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'Accept-Encoding': 'gzip, deflate, br',
        'Referer': 'https://www.google.com/',
      },
      timeout: 15000,
      maxRedirects: 5,
      validateStatus: (status) => status < 500, // Не выбрасывать ошибку для 4xx
    });

    // Проверяем статус ответа
    if (response.status === 403) {
      throw new Error(`Доступ запрещен (403) для ${url}. Сайт блокирует автоматические запросы.`);
    }
    if (response.status === 404) {
      throw new Error(`Страница не найдена (404) для ${url}.`);
    }
    if (response.status >= 400) {
      throw new Error(`HTTP ошибка ${response.status} для ${url}.`);
    }

    const $ = cheerio.load(response.data);
    
    // Удаляем скрипты и стили
    $('script, style, nav, footer, header, aside').remove();
    
    // Извлекаем заголовок
    const title = $('title').text().trim() || 
                  $('h1').first().text().trim() || 
                  $('meta[property="og:title"]').attr('content') || 
                  'Без названия';
    
    // Извлекаем основной текст
    // Пробуем найти основной контент по различным селекторам
    const contentSelectors = [
      'article',
      'main',
      '.content',
      '.post-content',
      '.article-content',
      '#content',
      'p',
    ];
    
    let text = '';
    for (const selector of contentSelectors) {
      const elements = $(selector);
      if (elements.length > 0) {
        text = elements
          .map((_, el) => $(el).text())
          .get()
          .join(' ')
          .replace(/\s+/g, ' ')
          .trim();
        
        if (text.length > 200) {
          break;
        }
      }
    }
    
    // Если не нашли контент, берем все параграфы
    if (text.length < 200) {
      text = $('p')
        .map((_, el) => $(el).text())
        .get()
        .join(' ')
        .replace(/\s+/g, ' ')
        .trim();
    }
    
    // Ограничиваем длину текста
    if (text.length > 5000) {
      text = text.substring(0, 5000) + '...';
    }

    return {
      url,
      title,
      text: text || 'Не удалось извлечь текст',
      sourceType: determineSourceType(url),
    };
  } catch (error) {
    // Логируем только краткую информацию об ошибке, без полного stack trace
    if (error instanceof Error) {
      const errorMessage = error.message;
      if (errorMessage.includes('403') || errorMessage.includes('Forbidden')) {
        console.warn(`[403] Доступ запрещен для ${url}`);
      } else if (errorMessage.includes('404') || errorMessage.includes('Not Found')) {
        console.warn(`[404] Страница не найдена: ${url}`);
      } else if (errorMessage.includes('timeout') || errorMessage.includes('ETIMEDOUT')) {
        console.warn(`[Timeout] Превышено время ожидания для ${url}`);
      } else {
        console.warn(`[Error] Не удалось загрузить ${url}: ${errorMessage}`);
      }
    } else {
      console.warn(`[Error] Не удалось загрузить ${url}`);
    }
    
    // Возвращаем минимальную информацию даже при ошибке
    return {
      url,
      title: 'Не удалось загрузить',
      text: '',
      sourceType: determineSourceType(url),
    };
  }
}

/**
 * Получение контента из нескольких источников
 */
export async function getSourcesContent(results: SearchResult[], limit: number = 3): Promise<SourceContent[]> {
  const topResults = results.slice(0, limit);
  
  const contentPromises = topResults.map(async (result) => {
    try {
      const content = await extractSourceContent(result.url);
      // Если текст не загрузился, используем snippet
      if (!content.text || content.text.trim().length === 0 || content.title === 'Не удалось загрузить') {
        return {
          url: result.url,
          title: result.title || content.title,
          text: result.snippet || 'Контент недоступен для загрузки',
          sourceType: result.sourceType,
        };
      }
      return content;
    } catch (error) {
      // Ошибка уже обработана в extractSourceContent, здесь просто возвращаем fallback
      return {
        url: result.url,
        title: result.title,
        text: result.snippet || 'Контент недоступен для загрузки',
        sourceType: result.sourceType,
      };
    }
  });
  
  return await Promise.all(contentPromises);
}

