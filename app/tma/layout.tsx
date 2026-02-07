/**
 * Layout for Telegram Mini App (TMA)
 * Loads Telegram Web App script. Root layout provides html/body.
 */
import Script from 'next/script';

export const metadata = {
  title: 'FindOrigin',
  description: 'Поиск источников информации',
  robots: 'noindex, nofollow',
};

export const viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  viewportFit: 'cover',
  themeColor: '#2481cc',
};

export default function TMALayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <Script
        src="https://telegram.org/js/telegram-web-app.js"
        strategy="beforeInteractive"
      />
      <div className="tma-root">{children}</div>
    </>
  );
}
