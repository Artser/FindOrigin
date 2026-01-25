/**
 * API endpoint для веб-поиска источников
 */

import { NextRequest, NextResponse } from 'next/server';
import { extractText } from '@/lib/textParser';
import { searchSources, filterResultsBySourceType, getSourcesContent } from '@/lib/searchSources';
import { SourceContent } from '@/lib/searchSources';
import { compareTextsWithAI } from '@/lib/openai';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

/**
 * Обработка POST запросов для поиска источников
 */
export async function POST(request: NextRequest) {
  try {
    let body;
    try {
      body = await request.json();
    } catch (jsonError) {
      return NextResponse.json(
        { error: 'Неверный формат JSON в запросе' },
        { status: 400 }
      );
    }

    const { query } = body || {};

    if (!query || typeof query !== 'string' || query.trim().length === 0) {
      return NextResponse.json(
        { error: 'Запрос не может быть пустым' },
        { status: 400 }
      );
    }

    // Шаг 1: Извлечение текста
    const text = await extractText(query);
    
    if (!text || text.trim().length === 0) {
      return NextResponse.json(
        { error: 'Не удалось извлечь текст из вашего запроса' },
        { status: 400 }
      );
    }

    // Шаг 2: Поиск источников (используем исходный текст напрямую)
    const searchResults = await searchSources(text);
    
    if (searchResults.length === 0) {
      return NextResponse.json(
        { error: 'Не найдено источников по вашему запросу' },
        { status: 404 }
      );
    }

    // Шаг 3: Фильтрация результатов
    const filteredResults = filterResultsBySourceType(searchResults, ['official', 'news', 'research']);

    // Шаг 4: Получение контента из источников
    const sourcesContent = await getSourcesContent(filteredResults, 3);

    // Шаг 5: AI-анализ и сравнение смысла
    let aiAnalysis = null;
    try {
      // Проверяем наличие API ключа (OpenAI или OpenRouter)
      const openaiKey = process.env.OPENAI_API_KEY;
      const openrouterKey = process.env.OPENROUTER_API_KEY;
      const hasApiKey = !!(openaiKey || openrouterKey);
      
      console.log('Проверка API ключей:', {
        hasOpenAI: !!openaiKey,
        hasOpenRouter: !!openrouterKey,
        hasApiKey,
      });
      
      const validSources = sourcesContent.filter(s => 
        s.text && 
        s.text.trim().length > 0 && 
        s.text !== 'Контент недоступен для загрузки'
      );
      const hasContent = validSources.length > 0;
      
      console.log('Проверка контента:', {
        totalSources: sourcesContent.length,
        validSources: validSources.length,
        hasContent,
      });
      
      if (hasApiKey && hasContent) {
        console.log('Запуск AI-анализа с', validSources.length, 'источниками...');
        aiAnalysis = await compareTextsWithAI(
          text,
          validSources.map(s => ({
            title: s.title,
            url: s.url,
            text: s.text,
            sourceType: s.sourceType,
          }))
        );
        console.log('AI-анализ завершен успешно');
      } else {
        if (!hasApiKey) {
          console.warn('AI-анализ не выполнен: API ключ не найден');
          console.warn('OPENAI_API_KEY:', openaiKey ? 'установлен' : 'не установлен');
          console.warn('OPENROUTER_API_KEY:', openrouterKey ? 'установлен' : 'не установлен');
        }
        if (!hasContent) {
          console.warn('AI-анализ не выполнен: нет источников с контентом');
          console.warn('Всего источников:', sourcesContent.length);
          console.warn('Валидных источников:', validSources.length);
        }
      }
    } catch (error) {
      console.error('Ошибка при AI-анализе:', error);
      if (error instanceof Error) {
        console.error('Детали ошибки:', error.message);
        console.error('Стек:', error.stack);
      }
      // Продолжаем без AI-анализа
    }

    // Шаг 6: Формирование ответа
    return NextResponse.json({
      success: true,
      query: text,
      sources: sourcesContent.map((source, index) => {
        const match = aiAnalysis?.matches.find(m => m.sourceIndex === index);
        return {
          title: source.title,
          url: source.url,
          text: source.text.substring(0, 500),
          sourceType: source.sourceType,
          confidence: match?.confidence || null,
          explanation: match?.explanation || null,
        };
      }),
      aiAnalysis: aiAnalysis ? {
        summary: aiAnalysis.summary,
        matches: aiAnalysis.matches,
      } : null,
    });

  } catch (error) {
    console.error('Ошибка при поиске источников:', error);
    
    const errorMessage = error instanceof Error ? error.message : 'Неизвестная ошибка';
    
    // Более детальные сообщения об ошибках
    let userMessage = 'Произошла ошибка при поиске источников';
    
    if (errorMessage.includes('не настроен ни один поисковый API')) {
      userMessage = 'Не настроен ни один поисковый API. Добавьте GOOGLE_SEARCH_API_KEY, BING_SEARCH_API_KEY или SERPAPI_KEY в файл .env.local';
    } else if (errorMessage.includes('API key не установлен') || errorMessage.includes('credentials не установлены')) {
      userMessage = 'API ключ не установлен. Проверьте переменные окружения в файле .env.local';
    } else if (errorMessage.includes('403') || errorMessage.includes('Forbidden')) {
      userMessage = 'Ошибка доступа к API (403). Проверьте правильность API ключа и настройки биллинга';
    } else if (errorMessage.includes('401') || errorMessage.includes('Unauthorized')) {
      userMessage = 'Ошибка авторизации (401). Проверьте правильность API ключа';
    } else if (errorMessage.includes('429') || errorMessage.includes('quota') || errorMessage.includes('limit')) {
      userMessage = 'Превышен лимит запросов. Подождите или настройте биллинг';
    }
    
    return NextResponse.json(
      {
        error: userMessage,
        message: errorMessage,
      },
      { status: 500 }
    );
  }
}

