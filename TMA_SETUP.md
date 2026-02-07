# Telegram Mini App (TMA) — FindOrigin

Mini App — веб-интерфейс бота FindOrigin, открывается внутри Telegram и использует тот же API поиска источников (`/api/search`).

## URL Mini App

После деплоя на Vercel:

- **URL приложения:** `https://find-origin-nine.vercel.app/tma`  
  (замените на ваш домен, если другой)

## Настройка в BotFather

1. Откройте [@BotFather](https://t.me/BotFather) в Telegram.
2. Выберите бота FindOrigin (например, @ArtserShowBot).
3. **Меню → Bot Settings → Menu Button:**
   - Выберите **Configure menu button**.
   - **Menu button URL:** `https://find-origin-nine.vercel.app/tma`
   - Текст кнопки по умолчанию — «Open App» или задайте свой (если BotFather даёт такую опцию).

Либо задайте кнопку меню через API:

```http
GET https://api.telegram.org/bot<TOKEN>/setChatMenuButton?menu_button={"type":"web_app","text":"FindOrigin","web_app":{"url":"https://find-origin-nine.vercel.app/tma"}}
```

(Подставьте ваш `TOKEN` и при необходимости закодируйте JSON в query.)

## Что делает Mini App

- Поле ввода: текст или ссылка на Telegram-пост.
- Кнопка «Найти источники» — отправка запроса в `/api/search`.
- Отображение списка источников, типа (официальный, новости, блог, исследование), уверенности AI и ссылки на источник.
- Подстройка под тему Telegram (светлая/тёмная) через `themeParams`.
- Открытие ссылок через `WebApp.openLink` (внутри клиента Telegram, где возможно).

## Локальная проверка

1. Запустите проект: `npm run dev`.
2. В браузере откройте: `http://localhost:3000/tma`.
3. Без Telegram-клиента `window.Telegram.WebApp` будет `undefined` — интерфейс всё равно должен работать (поиск, вывод результатов). Для полной проверки откройте Mini App из Telegram по URL выше (после деплоя).

## Файлы

- `app/tma/layout.tsx` — layout: подключение скрипта Telegram Web App, viewport, метаданные.
- `app/tma/page.tsx` — страница: форма, запрос к `/api/search`, отображение результатов и тема.
- `types/telegram-webapp.d.ts` — типы TypeScript для Telegram Web App API.

## CORS и домен

Запросы с страницы `/tma` идут на тот же домен (`/api/search`), отдельный CORS для Mini App не нужен. Убедитесь, что в BotFather или в `setChatMenuButton` указан тот же домен, на котором развёрнут проект (например, `https://find-origin-nine.vercel.app`).
