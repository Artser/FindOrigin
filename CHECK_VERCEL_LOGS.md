# Как правильно проверить логи Vercel

## Проблема: Логи не появляются

Если логи `[WEBHOOK]` не появляются в Vercel, это может быть из-за нескольких причин:

## 1. Правильное место для просмотра логов

### Вариант A: Через Dashboard (рекомендуется)

1. Откройте https://vercel.com/dashboard
2. Выберите ваш проект **find-origin**
3. Перейдите в раздел **Deployments** (не Overview!)
4. Найдите **последний Production деплой** (должен быть зеленый статус)
5. Нажмите на деплой, чтобы открыть детали
6. Перейдите в раздел **Logs** (вкладка вверху)
7. **Обновите страницу** (F5) после отправки запроса

### Вариант B: Через Vercel CLI

```powershell
# Установите Vercel CLI (если еще не установлен)
npm install -g vercel

# Войдите в Vercel
vercel login

# Просмотр логов
vercel logs find-origin --follow
```

## 2. Проверка через тестовый endpoint

После развертывания (подождите 1-2 минуты):

```powershell
# Тест debug endpoint
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/debug-webhook" -Method GET

# Тест POST запроса
$body = '{"test":"data"}'
Invoke-RestMethod -Uri "https://find-origin.vercel.app/api/debug-webhook" -Method POST -Body $body -ContentType "application/json"
```

Затем проверьте логи Vercel - должны появиться записи с `[DEBUG-WEBHOOK]`.

## 3. Альтернативные способы проверки

### Проверка через Vercel API

Если у вас есть Vercel API token:

```powershell
$token = "YOUR_VERCEL_TOKEN"
$projectId = "YOUR_PROJECT_ID"
Invoke-RestMethod -Uri "https://api.vercel.com/v2/deployments/$projectId/events" -Headers @{Authorization = "Bearer $token"}
```

### Проверка через Analytics

1. Vercel Dashboard → ваш проект
2. **Analytics** → **Functions**
3. Проверьте метрики для `/api/webhook`
4. Если есть вызовы - значит запросы доходят

## 4. Почему логи могут не появляться

### Причина 1: Логи фильтруются

**Решение:**
- Убедитесь, что нет фильтров по времени
- Проверьте, что вы смотрите Production логи, а не Preview

### Причина 2: console.log не попадает в логи

**Решение:**
Теперь используется `process.stderr.write`, который должен работать надежнее.

### Причина 3: Задержка в отображении логов

**Решение:**
- Подождите 10-30 секунд после запроса
- Обновите страницу логов

### Причина 4: Неправильный деплой

**Решение:**
- Убедитесь, что последний деплой **успешен** (зеленый статус)
- Проверьте время деплоя - должен быть свежим

## 5. Диагностика через ответ endpoint

Если логи не работают, можно использовать ответ endpoint для отладки:

```powershell
# Тест webhook с получением ответа
$testBody = '{"update_id":999999,"message":{"message_id":1,"chat":{"id":123456789,"type":"private"},"text":"/start"}}'
$response = Invoke-WebRequest -Uri "https://find-origin.vercel.app/api/webhook" -Method POST -Body $testBody -ContentType "application/json"
$response.Content
```

## 6. Проверка через Telegram

Если логи не появляются, но бот отвечает - значит все работает, просто логи не отображаются.

**Проверка:**
1. Отправьте сообщение боту
2. Если бот отвечает - webhook работает!
3. Проблема только в отображении логов

## 7. Использование внешнего сервиса логирования

Если логи Vercel не работают, можно добавить внешний сервис:

- Sentry
- Logtail
- Datadog
- CloudWatch

Но для начала попробуйте проверить логи правильно.

## Контрольный список

- [ ] Открыт правильный раздел: Deployments → последний деплой → Logs
- [ ] Выбран Production деплой (не Preview)
- [ ] Страница логов обновлена после запроса
- [ ] Нет фильтров по времени
- [ ] Последний деплой успешен (зеленый статус)
- [ ] Протестирован debug endpoint
- [ ] Проверены Analytics → Functions

## Если ничего не помогает

1. **Проверьте, работает ли бот:**
   - Отправьте сообщение боту
   - Если бот отвечает - webhook работает, проблема только в логах

2. **Используйте Vercel CLI:**
   ```powershell
   vercel logs find-origin --follow
   ```

3. **Проверьте через другой endpoint:**
   - `/api/webhook` (GET) - должен вернуть JSON
   - `/api/debug-webhook` - должен логировать

4. **Свяжитесь с поддержкой Vercel:**
   - Если логи вообще не работают, это может быть проблема Vercel



