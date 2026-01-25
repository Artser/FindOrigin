/**
 * Интеграция с OpenAI API
 */

import axios from 'axios';

export interface OpenAIMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface OpenAIResponse {
  content: string;
  confidence?: number;
}

/**
 * Отправка запроса к OpenAI API
 */
export async function callOpenAI(
  messages: OpenAIMessage[],
  model: string = 'gpt-4o-mini'
): Promise<OpenAIResponse> {
  // Поддержка как OPENAI_API_KEY, так и OPENROUTER_API_KEY
  // Приоритет: если есть OPENROUTER_API_KEY, используем его (для работы в России)
  const openRouterKey = process.env.OPENROUTER_API_KEY;
  const openAIKey = process.env.OPENAI_API_KEY;
  const apiKey = openRouterKey || openAIKey;
  const isOpenRouter = !!openRouterKey;
  
  console.log('OpenAI API конфигурация:', {
    hasOpenRouterKey: !!openRouterKey,
    hasOpenAIKey: !!openAIKey,
    isOpenRouter,
    usingKey: openRouterKey ? 'OPENROUTER_API_KEY' : 'OPENAI_API_KEY',
  });
  
  // Если используется OPENROUTER_API_KEY, используем OpenRouter URL
  let baseUrl = process.env.OPENAI_BASE_URL;
  if (!baseUrl) {
    baseUrl = isOpenRouter ? 'https://openrouter.ai/api/v1' : 'https://api.openai.com/v1';
  }
  // Убираем кавычки, если они есть
  baseUrl = baseUrl.replace(/^["']|["']$/g, '');
  
  console.log('OpenAI API URL:', baseUrl);

  if (!apiKey) {
    throw new Error('OPENAI_API_KEY или OPENROUTER_API_KEY не установлен');
  }

  // Для OpenRouter нужно указывать полное имя модели
  const modelName = isOpenRouter && !model.includes('/') ? `openai/${model}` : model;

  const url = `${baseUrl}/chat/completions`;

  console.log('Отправка запроса к OpenAI API:', {
    url,
    model: modelName,
    isOpenRouter,
  });

  try {
    const response = await axios.post(
      url,
      {
        model: modelName,
        messages: messages,
        temperature: 0.7,
        max_tokens: 2000,
      },
      {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          // OpenRouter требует дополнительные заголовки
          ...(isOpenRouter ? {
            'HTTP-Referer': process.env.OPENROUTER_REFERER || 'https://github.com',
            'X-Title': process.env.OPENROUTER_TITLE || 'FindOrigin Bot',
          } : {}),
        },
        timeout: 30000,
      }
    );

    const content = response.data.choices?.[0]?.message?.content || '';
    
    if (!content) {
      throw new Error('OpenAI не вернул ответ');
    }

    return {
      content,
    };
  } catch (error: any) {
    console.error('Ошибка при запросе к OpenAI:', error);
    console.error('Детали запроса:', {
      url,
      isOpenRouter,
      hasApiKey: !!apiKey,
      apiKeyPrefix: apiKey ? apiKey.substring(0, 10) + '...' : 'нет',
    });
    
    if (error.response) {
      const status = error.response.status;
      const errorData = error.response.data;
      const errorMessage = errorData?.error?.message || errorData?.message || error.message;
      console.error('Ответ сервера:', {
        status,
        errorData,
      });
      throw new Error(`OpenAI API error (${status}): ${errorMessage}`);
    } else if (error.request) {
      throw new Error('Не удалось получить ответ от OpenAI API. Проверьте подключение к интернету.');
    } else {
      throw new Error(`Ошибка при запросе к OpenAI API: ${error.message}`);
    }
  }
}

/**
 * Сравнение смысла исходного текста с текстами из источников
 */
export async function compareTextsWithAI(
  originalText: string,
  sources: Array<{ title: string; url: string; text: string; sourceType: string }>
): Promise<{
  matches: Array<{ sourceIndex: number; confidence: number; explanation: string }>;
  summary: string;
}> {
  const sourcesText = sources
    .map((source, index) => `Источник ${index + 1} (${source.url}):\n${source.text.substring(0, 1000)}`)
    .join('\n\n---\n\n');

  const prompt = `Ты эксперт по проверке фактов. Сравни исходный текст с найденными источниками и определи, какие источники подтверждают или опровергают информацию из исходного текста.

Исходный текст:
"""
${originalText}
"""

Найденные источники:
"""
${sourcesText}
"""

Проанализируй каждый источник и определи:
1. Степень совпадения смысла с исходным текстом (0-100%)
2. Краткое объяснение совпадений или различий

Верни ответ в формате JSON:
{
  "matches": [
    {
      "sourceIndex": 0,
      "confidence": 85,
      "explanation": "Источник подтверждает основную информацию..."
    }
  ],
  "summary": "Общее резюме анализа..."
}`;

  try {
    const response = await callOpenAI([
      {
        role: 'system',
        content: 'Ты эксперт по проверке фактов. Анализируй тексты и находи совпадения по смыслу, а не буквально. Отвечай только валидным JSON.',
      },
      {
        role: 'user',
        content: prompt,
      },
    ]);

    // Парсим JSON ответ
    try {
      const jsonMatch = response.content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        return {
          matches: parsed.matches || [],
          summary: parsed.summary || 'Анализ завершен',
        };
      }
    } catch (parseError) {
      console.error('Ошибка парсинга JSON от OpenAI:', parseError);
    }

    // Если не удалось распарсить JSON, возвращаем текстовый ответ
    return {
      matches: sources.map((_, index) => ({
        sourceIndex: index,
        confidence: 50,
        explanation: 'Анализ выполнен, но не удалось извлечь детальную информацию',
      })),
      summary: response.content,
    };
  } catch (error) {
    console.error('Ошибка при сравнении текстов с AI:', error);
    throw error;
  }
}

