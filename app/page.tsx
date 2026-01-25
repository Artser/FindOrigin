'use client';

import { useState } from 'react';

interface Source {
  title: string;
  url: string;
  text: string;
  sourceType: 'official' | 'news' | 'blog' | 'research' | 'unknown';
  confidence: number | null;
  explanation: string | null;
}

interface AIAnalysis {
  summary: string;
  matches: Array<{
    sourceIndex: number;
    confidence: number;
    explanation: string;
  }>;
}

interface SearchResponse {
  success: boolean;
  query: string;
  sources: Source[];
  aiAnalysis: AIAnalysis | null;
  error?: string;
  message?: string;
}

export default function Home() {
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<SearchResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!query.trim()) {
      setError('Введите текст или ссылку для поиска');
      return;
    }

    setLoading(true);
    setError(null);
    setResults(null);

    try {
      const response = await fetch('/api/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ query }),
      });

      let data: SearchResponse;
      
      try {
        data = await response.json();
      } catch (jsonError) {
        setError('Ошибка при разборе ответа сервера. Проверьте логи сервера.');
        console.error('Ошибка парсинга JSON:', jsonError);
        return;
      }

      if (!response.ok) {
        const errorMessage = data?.error || data?.message || 'Произошла ошибка';
        setError(`${errorMessage}. Проверьте настройки API в файле .env.local`);
        console.error('Ошибка API:', data);
        return;
      }

      if (!data || !data.sources) {
        setError('Неверный формат ответа от сервера');
        console.error('Неверный формат данных:', data);
        return;
      }

      setResults(data);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Неизвестная ошибка';
      setError(`Ошибка при выполнении запроса: ${errorMessage}. Проверьте настройки API в файле .env.local и убедитесь, что сервер запущен.`);
      console.error('Ошибка:', err);
    } finally {
      setLoading(false);
    }
  };

  const getSourceTypeLabel = (type: string) => {
    const labels: Record<string, string> = {
      official: '🏛️ Официальный источник',
      news: '📰 Новостной сайт',
      blog: '✍️ Блог',
      research: '🔬 Исследование',
      unknown: '📄 Другой источник',
    };
    return labels[type] || labels.unknown;
  };

  return (
    <main style={{ 
      maxWidth: '1200px', 
      margin: '0 auto', 
      padding: '2rem',
      fontFamily: 'system-ui, -apple-system, sans-serif'
    }}>
      <div style={{ marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>
          FindOrigin - Поиск источников информации
        </h1>
        <p style={{ color: '#666', marginBottom: '1rem' }}>
          Введите текст или ссылку на Telegram-пост для поиска источников
        </p>
        <p style={{ fontSize: '0.875rem', color: '#999' }}>
          Webhook endpoint: /api/webhook
        </p>
      </div>

      <form onSubmit={handleSearch} style={{ marginBottom: '2rem' }}>
        <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1rem' }}>
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Введите текст или ссылку на Telegram-пост..."
            disabled={loading}
            style={{
              flex: 1,
              padding: '0.75rem',
              fontSize: '1rem',
              border: '1px solid #ddd',
              borderRadius: '4px',
              outline: 'none',
            }}
          />
          <button
            type="submit"
            disabled={loading || !query.trim()}
            style={{
              padding: '0.75rem 2rem',
              fontSize: '1rem',
              backgroundColor: loading ? '#ccc' : '#0070f3',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: loading ? 'not-allowed' : 'pointer',
              fontWeight: '500',
            }}
          >
            {loading ? 'Поиск...' : 'Найти источники'}
          </button>
        </div>
      </form>

      {error && (
        <div style={{
          padding: '1rem',
          backgroundColor: '#fee',
          border: '1px solid #fcc',
          borderRadius: '4px',
          color: '#c33',
          marginBottom: '1rem',
        }}>
          ❌ {error}
        </div>
      )}

      {results && (
        <div>
          <div style={{ marginBottom: '2rem' }}>
            <h2 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>
              📋 Найденные источники
            </h2>
            {results.query && (
              <p style={{ color: '#666', marginBottom: '0.5rem' }}>
                <strong>Исходный запрос:</strong> {results.query}
              </p>
            )}
          </div>

          {results.aiAnalysis && (
            <div style={{
              marginBottom: '2rem',
              padding: '1.5rem',
              backgroundColor: '#e3f2fd',
              border: '1px solid #2196f3',
              borderRadius: '8px',
            }}>
              <h3 style={{ fontSize: '1.125rem', marginBottom: '0.75rem' }}>
                🤖 AI-анализ источников:
              </h3>
              <p style={{ color: '#333', lineHeight: '1.6' }}>
                {results.aiAnalysis.summary}
              </p>
            </div>
          )}

          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
            {results.sources.map((source, index) => (
              <div
                key={index}
                style={{
                  padding: '1.5rem',
                  border: '1px solid #ddd',
                  borderRadius: '8px',
                  backgroundColor: 'white',
                }}
              >
                <div style={{ marginBottom: '0.75rem' }}>
                  <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>
                    {getSourceTypeLabel(source.sourceType)} - {source.title}
                  </h3>
                  {source.confidence !== null && (
                    <div style={{ marginBottom: '0.5rem' }}>
                      <span style={{
                        display: 'inline-block',
                        padding: '0.25rem 0.75rem',
                        borderRadius: '4px',
                        fontSize: '0.875rem',
                        fontWeight: '500',
                        backgroundColor: source.confidence >= 70 ? '#d4edda' : source.confidence >= 40 ? '#fff3cd' : '#f8d7da',
                        color: source.confidence >= 70 ? '#155724' : source.confidence >= 40 ? '#856404' : '#721c24',
                      }}>
                        {source.confidence >= 70 ? '✅' : source.confidence >= 40 ? '⚠️' : '❌'} Уверенность: {source.confidence}%
                      </span>
                    </div>
                  )}
                  {source.explanation && (
                    <p style={{
                      fontSize: '0.875rem',
                      color: '#666',
                      marginBottom: '0.5rem',
                      fontStyle: 'italic',
                    }}>
                      {source.explanation}
                    </p>
                  )}
                  <a
                    href={source.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{
                      color: '#0070f3',
                      textDecoration: 'none',
                      fontSize: '0.875rem',
                    }}
                  >
                    {source.url}
                  </a>
                </div>
                {source.text && source.text !== 'Контент недоступен для загрузки' ? (
                  <p style={{
                    color: '#666',
                    lineHeight: '1.6',
                    marginTop: '0.75rem',
                  }}>
                    {source.text}
                    {source.text.length >= 500 && '...'}
                  </p>
                ) : (
                  <p style={{
                    color: '#999',
                    fontStyle: 'italic',
                    marginTop: '0.75rem',
                  }}>
                    Контент недоступен для загрузки. Используйте ссылку для просмотра оригинала.
                  </p>
                )}
              </div>
            ))}
          </div>

          {!results.aiAnalysis && (
            <div style={{
              marginTop: '2rem',
              padding: '1rem',
              backgroundColor: '#fff3cd',
              border: '1px solid #ffc107',
              borderRadius: '4px',
              fontSize: '0.875rem',
              color: '#856404',
            }}>
              ⚠️ <strong>Примечание:</strong> AI-анализ не выполнен. Убедитесь, что OPENAI_API_KEY или OPENROUTER_API_KEY настроен в .env.local и перезапустите сервер
            </div>
          )}
        </div>
      )}
    </main>
  );
}

