# Важно: Yandex Cloud API не предназначен для поиска в интернете

## Проблема

`YANDEX_CLOUD_API_KEY` (начинается с `AQVN...`) - это **НЕ поисковый API**.

Yandex Cloud API используется для:
- ✅ Управления ресурсами (Compute Cloud, Object Storage)
- ✅ Работы с базами данных
- ✅ Использования Yandex GPT API
- ❌ **НЕ для поиска в интернете**

## Решение: Использовать Yandex GPT для поиска через API

Если вы хотите использовать Yandex Cloud, можно использовать **Yandex GPT API** для поиска информации, но это другой подход:

### Вариант 1: Yandex GPT API (для AI-поиска)

Yandex GPT может помочь найти информацию, но это не прямой поиск в интернете, а AI-анализ.

**Настройка:**
```env
YANDEX_CLOUD_API_KEY=ваш_yandex_cloud_api_ключ
YANDEX_AUTH_TYPE=Api-Key
YANDEX_FOLDER_ID=ваш_folder_id
```

**Но:** Это требует реализации AI-анализа (Этап 5 из PLAN.md), который еще не реализован.

### Вариант 2: Использовать существующие поисковые API

Для поиска источников в интернете лучше использовать:

1. **Google Custom Search API** (уже настроен в `.env.local`)
2. **Bing Search API** (работает в России)
3. **SerpAPI** (если доступен)

## Рекомендация

**Используйте Google Custom Search API**, который уже настроен в вашем `.env.local`:

```env
GOOGLE_SEARCH_API_KEY=AIzaSyDn0HCY056_ewE6vEAs2rD01_DPtXbs20I
GOOGLE_SEARCH_ENGINE_ID=c3818dfb6fe534e25
```

Этот API уже работает и настроен правильно.

## Если все же нужно использовать Yandex

Если вы настаиваете на использовании Yandex, можно:

1. **Использовать Yandex XML API** (старый, требует парсинга XML)
2. **Использовать Yandex GPT для анализа** (после реализации Этапа 5)

Но для прямого поиска в интернете Yandex Cloud API не подходит.


