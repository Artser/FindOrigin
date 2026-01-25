# Исправление файла .env для работы поиска

## Проблема

В вашем файле `.env`:
- Google API ключи **закомментированы** (строки с `#`)
- `YANDEX_CLOUD_API_KEY` не подходит для поиска (это не поисковый API)

## Решение

### Вариант 1: Раскомментировать Google API (быстрое решение)

Откройте файл `.env` и раскомментируйте строки с Google API:

**Было:**
```env
#SEARCH_API_KEY = ваш_google_api_ключ
#GOOGLE_SEARCH_ENGINE_ID = ваш_search_engine_id
```

**Должно быть:**
```env
GOOGLE_SEARCH_API_KEY=ваш_google_api_ключ
GOOGLE_SEARCH_ENGINE_ID=ваш_search_engine_id
```

**Важно:**
1. Уберите символ `#` в начале строк
2. Исправьте `SEARCH_API_KEY` на `GOOGLE_SEARCH_API_KEY`
3. Уберите пробелы вокруг знака `=` (если есть)

### Вариант 2: Создать .env.local (рекомендуется для Next.js)

1. Создайте файл `.env.local` в корне проекта
2. Добавьте туда:

```env
# Google Custom Search API
GOOGLE_SEARCH_API_KEY=ваш_google_api_ключ
GOOGLE_SEARCH_ENGINE_ID=ваш_search_engine_id

# Yandex Cloud (можно оставить, если нужно)
YANDEX_CLOUD_API_KEY=ваш_yandex_cloud_api_ключ
YANDEX_AUTH_TYPE=Api-Key
YANDEX_FOLDER_ID=ваш_folder_id
```

## После исправления

1. **Перезапустите сервер:**
   ```powershell
   # Остановите (Ctrl+C) и запустите снова:
   npm run dev
   ```

2. **Попробуйте выполнить поиск** в веб-интерфейсе

3. **Проверьте логи сервера** на наличие ошибок

## Важно про YANDEX_CLOUD_API_KEY

`YANDEX_CLOUD_API_KEY` - это **НЕ поисковый API**. Он используется для:
- Управления ресурсами Yandex Cloud
- Доступа к Compute Cloud, Object Storage и т.д.
- **НЕ для поиска в интернете**

Для поиска нужны другие API:
- Google Custom Search API ✅
- Bing Search API ✅
- SerpAPI ✅

## Быстрое исправление через PowerShell

Выполните эту команду для автоматического исправления:

```powershell
# Создайте .env.local с правильными настройками
@"
# Google Custom Search API
GOOGLE_SEARCH_API_KEY=ваш_google_api_ключ
GOOGLE_SEARCH_ENGINE_ID=ваш_search_engine_id

# Yandex Cloud (для других сервисов, не для поиска)
YANDEX_CLOUD_API_KEY=ваш_yandex_cloud_api_ключ
YANDEX_AUTH_TYPE=Api-Key
YANDEX_FOLDER_ID=ваш_folder_id
"@ | Out-File -FilePath .env.local -Encoding utf8
```

Затем перезапустите сервер.


