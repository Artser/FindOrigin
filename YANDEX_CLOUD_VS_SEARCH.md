# Разница между Yandex Cloud API и поисковыми API

## Важно: Yandex Cloud API ≠ Поисковый API

### Yandex Cloud API (`YANDEX_CLOUD_API_KEY`)

**Что это:**
- API ключ для доступа к сервисам Yandex Cloud
- Используется для: Compute Cloud, Object Storage, Managed Databases и т.д.
- **НЕ используется для поиска в интернете**

**Формат ключа:**
- Начинается с `AQVN...` или `AQAAA...`
- Пример: `ваш_yandex_cloud_api_ключ`

**Для чего нужен:**
- Управление ресурсами в Yandex Cloud
- Доступ к облачным сервисам
- **НЕ для поиска источников информации**

### Поисковые API (для поиска в интернете)

Для поиска источников информации нужны **другие API**:

#### 1. Google Custom Search API
```env
GOOGLE_SEARCH_API_KEY=ваш_ключ
GOOGLE_SEARCH_ENGINE_ID=ваш_engine_id
```

#### 2. Bing Search API
```env
BING_SEARCH_API_KEY=ваш_ключ
```

#### 3. SerpAPI
```env
SERPAPI_KEY=ваш_ключ
```

#### 4. Yandex XML API (старый, сложный)
```env
YANDEX_SEARCH_API_KEY=ваш_ключ
```
⚠️ Это другой API, не Yandex Cloud API!

## Решение для вашего случая

У вас есть `YANDEX_CLOUD_API_KEY`, но для поиска нужен другой API.

### Вариант 1: Использовать Google Custom Search API (если уже настроен)

Если у вас уже есть Google API ключ, добавьте в `.env`:

```env
GOOGLE_SEARCH_API_KEY=AIzaSyDn0HCY056_ewE6vEAs2rD01_DPtXbs20I
GOOGLE_SEARCH_ENGINE_ID=c3818dfb6fe534e25
```

### Вариант 2: Использовать Bing Search API (рекомендуется для России)

1. Создайте Microsoft аккаунт (outlook.com)
2. Создайте Azure аккаунт
3. Создайте ресурс "Bing Search v7"
4. Получите API ключ
5. Добавьте в `.env`:

```env
BING_SEARCH_API_KEY=ваш_bing_ключ
```

### Вариант 3: Использовать SerpAPI

1. Зарегистрируйтесь на SerpAPI
2. Получите API ключ
3. Добавьте в `.env`:

```env
SERPAPI_KEY=ваш_serpapi_ключ
```

## Что делать с YANDEX_CLOUD_API_KEY?

`YANDEX_CLOUD_API_KEY` можно оставить в `.env`, если вы планируете использовать другие сервисы Yandex Cloud в будущем. Но для поиска источников он **не подходит**.

## Проверка настроек

После добавления поискового API в `.env`:

1. **Перезапустите сервер:**
   ```powershell
   # Остановите (Ctrl+C) и запустите снова:
   npm run dev
   ```

2. **Попробуйте выполнить поиск** в веб-интерфейсе

3. **Проверьте логи сервера** на наличие ошибок

## Текущая ситуация

Сейчас в вашем `.env` есть:
- `YANDEX_CLOUD_API_KEY` - не подходит для поиска ❌
- Нужно добавить один из поисковых API ✅

## Рекомендация

**Для России лучше всего использовать Bing Search API:**
- Работает без ограничений
- 3,000 запросов/месяц бесплатно
- Простая настройка
- Хорошее качество результатов

Инструкция по настройке: см. файл `RUSSIA_ALTERNATIVES.md`


