# Настройка переменных окружения для Yandex Cloud API

## Определение типа ключа

Если ваш API ключ Yandex Cloud начинается с:
- `AQVN...` → это **API ключ**
- `AQAAA...` → это **API ключ**

Для API ключа нужна переменная: `YANDEX_AUTH_TYPE=Api-Key`

## Шаг 1: Откройте файл с переменными окружения

Откройте файл `.env` или `.env.local` в корне проекта:

```powershell
# В PowerShell
notepad .env.local

# Или в редакторе кода
code .env.local
```

## Шаг 2: Добавьте переменные окружения

Добавьте следующие строки в файл:

```env
# Yandex Cloud API Configuration
YANDEX_CLOUD_API_KEY=AQVNxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
YANDEX_AUTH_TYPE=Api-Key
```

**Пример с реальным ключом:**
```env
# Yandex Cloud API Configuration
YANDEX_CLOUD_API_KEY=AQVN1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7
YANDEX_AUTH_TYPE=Api-Key
```

## Шаг 3: Проверка формата

Убедитесь, что:

1. ✅ **Нет пробелов** вокруг знака `=`
   - Правильно: `YANDEX_AUTH_TYPE=Api-Key`
   - Неправильно: `YANDEX_AUTH_TYPE = Api-Key`

2. ✅ **Нет кавычек** вокруг значений
   - Правильно: `YANDEX_AUTH_TYPE=Api-Key`
   - Неправильно: `YANDEX_AUTH_TYPE="Api-Key"`

3. ✅ **Точное значение** `Api-Key` (с заглавной A и K, с дефисом)
   - Правильно: `Api-Key`
   - Неправильно: `api-key`, `API-KEY`, `ApiKey`

4. ✅ **API ключ скопирован полностью**, без пробелов и переносов строк

## Полный пример файла .env.local

```env
# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN=your_bot_token_here

# Yandex Cloud API Configuration
YANDEX_CLOUD_API_KEY=AQVNxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
YANDEX_AUTH_TYPE=Api-Key

# Google Custom Search API (альтернатива)
GOOGLE_SEARCH_API_KEY=your_google_search_api_key_here
GOOGLE_SEARCH_ENGINE_ID=your_search_engine_id_here

# Bing Search API (альтернатива)
BING_SEARCH_API_KEY=your_bing_search_api_key_here
```

## Шаг 4: Перезапустите сервер

После добавления переменных окружения **обязательно перезапустите сервер разработки**:

```powershell
# Остановите текущий сервер (Ctrl+C)
# Затем запустите снова:
npm run dev
```

## Проверка работы

После настройки переменных окружения проверьте, что они загружаются:

```powershell
# В PowerShell можно проверить (если используете dotenv)
node -e "require('dotenv').config(); console.log(process.env.YANDEX_AUTH_TYPE)"
```

Или в коде вашего приложения:

```typescript
// Проверка в коде
console.log('YANDEX_AUTH_TYPE:', process.env.YANDEX_AUTH_TYPE);
console.log('YANDEX_CLOUD_API_KEY:', process.env.YANDEX_CLOUD_API_KEY?.substring(0, 10) + '...');
```

## Альтернативные типы аутентификации

Если вы используете не API ключ, а другой тип аутентификации:

### IAM токен
```env
YANDEX_AUTH_TYPE=IAM
YANDEX_IAM_TOKEN=your_iam_token_here
```

### OAuth токен
```env
YANDEX_AUTH_TYPE=OAuth
YANDEX_OAUTH_TOKEN=your_oauth_token_here
```

Но для API ключа (начинается с `AQVN...` или `AQAAA...`) используйте:
```env
YANDEX_AUTH_TYPE=Api-Key
```

## Устранение проблем

### Переменная не загружается

**Проверьте:**
1. Файл называется `.env.local` (для Next.js) или `.env`
2. Файл находится в корне проекта (там же, где `package.json`)
3. Нет пробелов вокруг знака `=`
4. Сервер перезапущен после изменения файла

### Неправильное значение YANDEX_AUTH_TYPE

**Проверьте:**
- Значение точно `Api-Key` (с заглавной A и K, с дефисом)
- Нет лишних пробелов
- Нет кавычек

### API ключ не работает

**Проверьте:**
1. API ключ начинается с `AQVN...` или `AQAAA...`
2. Ключ скопирован полностью, без пробелов
3. Биллинг-аккаунт активен (см. `YANDEX_CLOUD_BILLING_SETUP.md`)
4. Сервисный аккаунт имеет необходимые права доступа

## Использование в коде

Пример использования переменных окружения в коде:

```typescript
// lib/yandexCloud.ts
const apiKey = process.env.YANDEX_CLOUD_API_KEY;
const authType = process.env.YANDEX_AUTH_TYPE;

if (!apiKey) {
  throw new Error('YANDEX_CLOUD_API_KEY не установлен');
}

if (authType !== 'Api-Key') {
  throw new Error('YANDEX_AUTH_TYPE должен быть "Api-Key" для API ключа');
}

// Использование ключа для запросов
const headers = {
  'Authorization': `Api-Key ${apiKey}`,
  // или в зависимости от формата, требуемого API
};
```

## Безопасность

⚠️ **Важно:**

1. **Не коммитьте `.env.local` в Git:**
   - Убедитесь, что `.env.local` в `.gitignore`
   - Используйте `.env.example` для примера (без реальных ключей)

2. **Не публикуйте ключи:**
   - Не отправляйте в чаты или email
   - Не публикуйте в документации

3. **Используйте разные ключи для разных окружений:**
   - Разработка (development)
   - Тестирование (staging)
   - Продакшн (production)

## Полезные ссылки

- **Документация Yandex Cloud API:** https://cloud.yandex.ru/docs/
- **Аутентификация в API:** https://cloud.yandex.ru/docs/iam/concepts/authorization/api-key

## Чек-лист

После настройки проверьте:

- ✅ API ключ скопирован (начинается с `AQVN...` или `AQAAA...`)
- ✅ `YANDEX_CLOUD_API_KEY` добавлен в `.env.local`
- ✅ `YANDEX_AUTH_TYPE=Api-Key` добавлен в `.env.local`
- ✅ Нет пробелов вокруг знака `=`
- ✅ Значение `Api-Key` написано правильно (с заглавной A и K)
- ✅ Сервер перезапущен
- ✅ Файл `.env.local` в `.gitignore`

