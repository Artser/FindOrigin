/**
 * Извлечение ключевых элементов из текста
 */

export interface ExtractedElements {
  keyStatements: string[];
  dates: string[];
  numbers: string[];
  names: string[];
  links: string[];
}

/**
 * Извлечение ключевых утверждений из текста
 * Использует простые эвристики для выделения важных предложений
 */
export function extractKeyStatements(text: string): string[] {
  // Разбиваем текст на предложения
  const sentences = text
    .split(/[.!?]+/)
    .map(s => s.trim())
    .filter(s => s.length > 0);

  // Фильтруем предложения по ключевым словам и длине
  const keyWords = [
    'утверждает', 'заявляет', 'сообщает', 'объявляет',
    'обнаружено', 'выявлено', 'найдено', 'установлено',
    'результат', 'исследование', 'анализ', 'данные',
    'статистика', 'процент', 'увеличение', 'уменьшение',
  ];

  const keyStatements = sentences.filter(sentence => {
    const lowerSentence = sentence.toLowerCase();
    
    // Проверяем наличие ключевых слов
    const hasKeyWord = keyWords.some(word => lowerSentence.includes(word));
    
    // Проверяем длину (не слишком короткие и не слишком длинные)
    const isGoodLength = sentence.length > 20 && sentence.length < 300;
    
    // Проверяем наличие чисел (часто указывает на конкретные данные)
    const hasNumbers = /\d/.test(sentence);
    
    return (hasKeyWord || hasNumbers) && isGoodLength;
  });

  return keyStatements.slice(0, 5); // Возвращаем до 5 ключевых утверждений
}

/**
 * Извлечение дат из текста
 */
export function extractDates(text: string): string[] {
  const datePatterns = [
    // Формат ДД.ММ.ГГГГ или ДД/ММ/ГГГГ
    /\b(\d{1,2}[.\/]\d{1,2}[.\/]\d{2,4})\b/g,
    // Формат ГГГГ-ММ-ДД
    /\b(\d{4}-\d{1,2}-\d{1,2})\b/g,
    // Названия месяцев
    /\b(\d{1,2}\s+(января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)\s+\d{2,4})\b/gi,
    // Относительные даты
    /\b(сегодня|вчера|позавчера|завтра|послезавтра)\b/gi,
    // Годы
    /\b(19|20)\d{2}\s+год[а]?\b/gi,
  ];

  const dates: string[] = [];
  
  datePatterns.forEach(pattern => {
    const matches = text.match(pattern);
    if (matches) {
      dates.push(...matches);
    }
  });

  // Удаляем дубликаты
  return [...new Set(dates)];
}

/**
 * Извлечение чисел из текста
 */
export function extractNumbers(text: string): string[] {
  const numberPatterns = [
    // Проценты
    /\b\d+\.?\d*\s*%/g,
    // Большие числа с разделителями
    /\b\d{1,3}(?:\s+\d{3})+\b/g,
    // Десятичные числа
    /\b\d+\.\d+\b/g,
    // Обычные числа (только значимые, больше 10)
    /\b\d{2,}\b/g,
    // Денежные суммы
    /\b\d+\.?\d*\s*(руб|долл|евро|₽|\$|€)\b/gi,
  ];

  const numbers: string[] = [];
  
  numberPatterns.forEach(pattern => {
    const matches = text.match(pattern);
    if (matches) {
      numbers.push(...matches);
    }
  });

  // Удаляем дубликаты и сортируем
  return [...new Set(numbers)];
}

/**
 * Извлечение имен собственных (упрощенная версия)
 */
export function extractNames(text: string): string[] {
  // Паттерны для имен:
  // - Слова с заглавной буквы, которые не в начале предложения
  // - Комбинации из 2-3 слов с заглавными буквами
  const namePatterns = [
    // Имена людей (Имя Фамилия)
    /\b([А-ЯЁ][а-яё]+\s+[А-ЯЁ][а-яё]+)\b/g,
    // Организации (часто содержат кавычки или специфические слова)
    /["«]([А-ЯЁ][^"»]+)["»]/g,
    // Аббревиатуры
    /\b([А-ЯЁ]{2,})\b/g,
  ];

  const names: string[] = [];
  
  namePatterns.forEach(pattern => {
    const matches = text.match(pattern);
    if (matches) {
      names.push(...matches.map(m => m.trim()));
    }
  });

  // Фильтруем слишком короткие и общие слова
  const commonWords = ['Россия', 'Москва', 'России', 'Москве', 'Россию'];
  const filtered = names.filter(name => 
    name.length > 2 && 
    !commonWords.includes(name) &&
    !/^\d+$/.test(name)
  );

  return [...new Set(filtered)].slice(0, 10); // Возвращаем до 10 имен
}

/**
 * Извлечение ссылок из текста
 */
export function extractLinks(text: string): string[] {
  const urlPattern = /https?:\/\/[^\s<>"{}|\\^`\[\]]+/gi;
  const matches = text.match(urlPattern);
  
  if (!matches) {
    return [];
  }

  return [...new Set(matches)];
}

/**
 * Извлечение всех ключевых элементов из текста
 */
export function extractKeyElements(text: string): ExtractedElements {
  return {
    keyStatements: extractKeyStatements(text),
    dates: extractDates(text),
    numbers: extractNumbers(text),
    names: extractNames(text),
    links: extractLinks(text),
  };
}





