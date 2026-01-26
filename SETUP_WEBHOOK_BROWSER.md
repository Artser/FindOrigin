# Как получить успешный ответ от Telegram API

## Способ 1: Через браузер (самый простой)

Откройте в браузере следующую ссылку:

```
https://api.telegram.org/bot6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k/setWebhook?url=https://find-origin.vercel.app/api/telegram
```

Вы увидите JSON ответ:
```json
{
  "ok": true,
  "result": true,
  "description": "Webhook was set"
}
```

## Способ 2: Через PowerShell

Выполните команду:

```powershell
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$webhookUrl = "https://find-origin.vercel.app/api/telegram"
$result = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/setWebhook?url=$webhookUrl" -Method GET
$result | ConvertTo-Json
```

## Способ 3: Использовать скрипт

Запустите:
```powershell
.\setup-webhook.ps1
```

## Проверка статуса webhook

Чтобы проверить, что webhook установлен правильно:

**В браузере:**
```
https://api.telegram.org/bot6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k/getWebhookInfo
```

**В PowerShell:**
```powershell
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getWebhookInfo"
$info.result | ConvertTo-Json
```

## Удаление webhook (если нужно)

**В браузере:**
```
https://api.telegram.org/bot6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k/deleteWebhook?drop_pending_updates=true
```

**В PowerShell:**
```powershell
$token = "6825751325:AAGrU8yECxlw6YlH8VBXDyRwYmqdHhf3Z3k"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/deleteWebhook?drop_pending_updates=true" -Method GET
```
