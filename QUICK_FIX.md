# Быстрое решение ошибки "Произошла ошибка при поиске источников"

## Проблема

Ошибка возникает, потому что не настроен ни один поисковый API.

## Решение за 3 шага

### Шаг 1: Создайте или откройте файл `.env.local`

В корне проекта (там же, где `package.json`) создайте или откройте файл `.env.local`

```powershell
# В PowerShell
notepad .env.local
```

### Шаг 2: Добавьте хотя бы один API ключ

Выберите один из вариантов и добавьте в `.env.local`:

#### Вариант 1: Google Custom Search API (если уже настроен)

```env
GOOGLE_SEARCH_API_KEY=AIzaSyDn0HCY056_ewE6vEAs2rD01_DPtXbs20I
GOOGLE_SEARCH_ENGINE_ID=c3818dfb6fe534e25
```

#### Вариант 2: Bing Search API (рекомендуется для России)

```env
BING_SEARCH_API_KEY=ваш_bing_api_ключ
```

**Как получить Bing API ключ:**
1. Создайте Microsoft аккаунт (outlook.com)
2. Создайте Azure аккаунт
3. Создайте ресурс "Bing Search v7"
4. Скопируйте API ключ

См. файл `RUSSIA_ALTERNATIVES.md` для подробной инструкции.

#### Вариант 3: SerpAPI

```env
SERPAPI_KEY=ваш_serpapi_ключ
```

### Шаг 3: Перезапустите сервер

**ВАЖНО:** После изменения `.env.local` обязательно перезапустите сервер!

```powershell
# Остановите текущий сервер (Ctrl+C)
# Затем запустите снова:
npm run dev
```

## Проверка

После перезапуска:
1. Обновите страницу в браузере (F5)
2. Попробуйте выполнить поиск снова
3. Ошибка должна исчезнуть

## Если ошибка все еще возникает

### Проверьте формат файла `.env.local`:

- ✅ Правильно: `GOOGLE_SEARCH_API_KEY=ваш_ключ`
- ❌ Неправильно: `GOOGLE_SEARCH_API_KEY = ваш_ключ` (пробелы вокруг =)
- ❌ Неправильно: `GOOGLE_SEARCH_API_KEY="ваш_ключ"` (кавычки)

### Проверьте логи сервера:

В терминале, где запущен `npm run dev`, посмотрите ошибки. Они покажут точную причину.

### Проверьте консоль браузера:

1. Откройте DevTools (F12)
2. Перейдите на вкладку "Console"
3. Выполните поиск
4. Посмотрите детали ошибки

## Быстрая диагностика

Если у вас уже есть Google API ключ (из файла `.env`):

1. Откройте `.env.local`
2. Скопируйте ключи из `.env`:
   ```env
   GOOGLE_SEARCH_API_KEY=AIzaSyDn0HCY056_ewE6vEAs2rD01_DPtXbs20I
   GOOGLE_SEARCH_ENGINE_ID=c3818dfb6fe534e25
   ```
3. Сохраните файл
4. Перезапустите сервер: `npm run dev`

## Полезные ссылки

- **Настройка Google Custom Search API:** `GOOGLE_API_SETUP.md`
- **Настройка Bing Search API:** `RUSSIA_ALTERNATIVES.md`
- **Устранение проблем:** `WEB_INTERFACE_TROUBLESHOOTING.md`


