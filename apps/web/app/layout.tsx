// apps/web/app/layout.tsx
import "./globals.css";
import { Inter } from "next/font/google";

const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "Nexum — Conecta tu negocio con cualquier vertical",
  description: "POS SaaS modular con verticales enchufables",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className={`${inter.className} min-h-screen text-slate-900 bg-gradient-to-b from-[#DBEAFE] via-white to-white`}>
        {children}
      </body>
    </html>
  );
}
