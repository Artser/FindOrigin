'use client';

import { useState, useEffect, useCallback } from 'react';

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

const SOURCE_LABELS: Record<string, string> = {
  official: 'Официальный',
  news: 'Новости',
  blog: 'Блог',
  research: 'Исследование',
  unknown: 'Источник',
};

function getApiBase(): string {
  if (typeof window === 'undefined') return '';
  return window.location.origin;
}

export default function TMAPage() {
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<SearchResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [theme, setTheme] = useState<{ bg: string; text: string; hint: string; button: string; buttonText: string }>({
    bg: '#ffffff',
    text: '#000000',
    hint: '#999999',
    button: '#2481cc',
    buttonText: '#ffffff',
  });

  const WebApp = typeof window !== 'undefined' ? window.Telegram?.WebApp : null;

  useEffect(() => {
    if (!WebApp) return;
    WebApp.ready();
    WebApp.expand();
    const tp = WebApp.themeParams;
    setTheme({
      bg: tp.bg_color || '#ffffff',
      text: tp.text_color || '#000000',
      hint: tp.hint_color || '#999999',
      button: tp.button_color || '#2481cc',
      buttonText: tp.button_text_color || '#ffffff',
    });
    WebApp.setHeaderColor('bg_color');
    WebApp.setBackgroundColor(tp.bg_color || '#ffffff');
  }, [WebApp]);

  const handleSearch = useCallback(
    async (e: React.FormEvent) => {
      e.preventDefault();
      if (!query.trim()) {
        setError('Введите текст или ссылку');
        WebApp?.HapticFeedback?.notificationOccurred?.('warning');
        return;
      }
      setLoading(true);
      setError(null);
      setResults(null);
      WebApp?.HapticFeedback?.impactOccurred?.('light');

      try {
        const base = getApiBase();
        const res = await fetch(`${base}/api/search`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ query: query.trim() }),
        });
        const data: SearchResponse = await res.json();

        if (!res.ok) {
          setError(data?.error || data?.message || 'Ошибка запроса');
          WebApp?.HapticFeedback?.notificationOccurred?.('error');
          return;
        }
        if (!data?.sources?.length) {
          setError('Источники не найдены');
          WebApp?.HapticFeedback?.notificationOccurred?.('warning');
          return;
        }
        setResults(data);
        WebApp?.HapticFeedback?.notificationOccurred?.('success');
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Ошибка сети');
        WebApp?.HapticFeedback?.notificationOccurred?.('error');
      } finally {
        setLoading(false);
      }
    },
    [query, WebApp]
  );

  const openLink = useCallback(
    (url: string) => {
      WebApp?.openLink?.(url) ?? window.open(url, '_blank');
    },
    [WebApp]
  );

  return (
    <div
      className="tma-container"
      style={{
        minHeight: '100vh',
        minHeight: '100dvh',
        background: theme.bg,
        color: theme.text,
        padding: '16px',
        paddingBottom: 'calc(16px + env(safe-area-inset-bottom))',
      }}
    >
      <header style={{ marginBottom: '20px' }}>
        <h1
          style={{
            margin: 0,
            fontSize: '1.5rem',
            fontWeight: 700,
          }}
        >
          FindOrigin
        </h1>
        <p style={{ margin: '4px 0 0', fontSize: '0.9rem', color: theme.hint }}>
          Введите текст или ссылку на пост — найдём источники
        </p>
      </header>

      <form onSubmit={handleSearch} style={{ marginBottom: '24px' }}>
        <textarea
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Текст или ссылка на Telegram-пост..."
          disabled={loading}
          rows={4}
          style={{
            width: '100%',
            padding: '12px',
            fontSize: '16px',
            border: `1px solid ${theme.hint}`,
            borderRadius: '12px',
            background: theme.bg,
            color: theme.text,
            resize: 'vertical',
            marginBottom: '12px',
          }}
        />
        <button
          type="submit"
          disabled={loading || !query.trim()}
          style={{
            width: '100%',
            padding: '14px',
            fontSize: '1rem',
            fontWeight: 600,
            backgroundColor: loading ? theme.hint : theme.button,
            color: theme.buttonText,
            border: 'none',
            borderRadius: '12px',
            cursor: loading ? 'not-allowed' : 'pointer',
            opacity: loading ? 0.7 : 1,
          }}
        >
          {loading ? 'Поиск...' : 'Найти источники'}
        </button>
      </form>

      {error && (
        <div
          style={{
            padding: '12px',
            marginBottom: '16px',
            background: 'rgba(255, 59, 48, 0.12)',
            color: '#c00',
            borderRadius: '12px',
            fontSize: '0.9rem',
          }}
        >
          {error}
        </div>
      )}

      {results && (
        <section style={{ marginTop: '24px' }}>
          <h2
            style={{
              margin: '0 0 12px',
              fontSize: '1.1rem',
              fontWeight: 600,
            }}
          >
            Найденные источники
          </h2>
          {results.aiAnalysis?.summary && (
            <div
              style={{
                padding: '12px',
                marginBottom: '16px',
                background: 'rgba(34, 159, 255, 0.1)',
                borderRadius: '12px',
                fontSize: '0.9rem',
                lineHeight: 1.5,
              }}
            >
              <strong>AI-анализ:</strong> {results.aiAnalysis.summary}
            </div>
          )}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {results.sources.map((source, index) => (
              <article
                key={index}
                style={{
                  padding: '14px',
                  border: `1px solid ${theme.hint}`,
                  borderRadius: '12px',
                  background: theme.bg,
                }}
              >
                <div style={{ marginBottom: '6px' }}>
                  <span
                    style={{
                      fontSize: '0.75rem',
                      color: theme.hint,
                      marginRight: '6px',
                    }}
                  >
                    {SOURCE_LABELS[source.sourceType] || source.sourceType}
                  </span>
                  {source.confidence != null && (
                    <span
                      style={{
                        fontSize: '0.75rem',
                        padding: '2px 6px',
                        borderRadius: '6px',
                        background:
                          source.confidence >= 70
                            ? 'rgba(52, 199, 89, 0.2)'
                            : source.confidence >= 40
                              ? 'rgba(255, 204, 0, 0.2)'
                              : 'rgba(255, 59, 48, 0.15)',
                      }}
                    >
                      {source.confidence}%
                    </span>
                  )}
                </div>
                <h3
                  style={{
                    margin: '0 0 6px',
                    fontSize: '1rem',
                    fontWeight: 600,
                  }}
                >
                  {source.title}
                </h3>
                {source.explanation && (
                  <p
                    style={{
                      margin: '0 0 8px',
                      fontSize: '0.85rem',
                      color: theme.hint,
                      fontStyle: 'italic',
                    }}
                  >
                    {source.explanation}
                  </p>
                )}
                <button
                  type="button"
                  onClick={() => openLink(source.url)}
                  style={{
                    marginTop: '8px',
                    padding: '8px 12px',
                    fontSize: '0.85rem',
                    color: theme.button,
                    background: 'transparent',
                    border: 'none',
                    cursor: 'pointer',
                    textAlign: 'left',
                    textDecoration: 'underline',
                  }}
                >
                  {source.url}
                </button>
                {source.text &&
                  source.text !== 'Контент недоступен для загрузки' && (
                    <p
                      style={{
                        margin: '8px 0 0',
                        fontSize: '0.85rem',
                        color: theme.hint,
                        lineHeight: 1.4,
                      }}
                    >
                      {source.text.slice(0, 200)}
                      {source.text.length > 200 ? '…' : ''}
                    </p>
                  )}
              </article>
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
