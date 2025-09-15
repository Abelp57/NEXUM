# scripts/windows/setup-web.ps1
param()

$ErrorActionPreference = "Stop"

Write-Host "== NEXUM WEB SETUP (Next + Tailwind) ==" -ForegroundColor Cyan

# Asegurar estructura
New-Item -ItemType Directory -Force -Path "apps/web/app" | Out-Null
New-Item -ItemType Directory -Force -Path "apps/web/public" | Out-Null

# package.json del app web
@'
{
  "name": "@nexum/web",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.2.5",
    "react": "18.3.1",
    "react-dom": "18.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.12.12",
    "@types/react": "^18.2.67",
    "autoprefixer": "^10.4.20",
    "eslint-config-next": "14.2.5",
    "postcss": "^8.4.41",
    "tailwindcss": "^3.4.9",
    "typescript": "^5.6.2"
  }
}
'@ | Out-File -Encoding utf8 "apps/web/package.json"

# tsconfig del app web
@'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "jsx": "preserve",
    "types": ["node", "react"]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
'@ | Out-File -Encoding utf8 "apps/web/tsconfig.json"

# next-env.d.ts
@'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
'@ | Out-File -Encoding utf8 "apps/web/next-env.d.ts"

# next.config.mjs
@'
/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: { appDir: true }
}
export default nextConfig
'@ | Out-File -Encoding utf8 "apps/web/next.config.mjs"

# Tailwind & PostCSS config
@'
import type { Config } from "tailwindcss"

export default {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        "nx-primary-500": "#2563EB",
        "nx-primary-600": "#1D4ED8",
        "nx-accent-500": "#22C55E",
        "nx-accent-600": "#16A34A",
        "nx-neutral-900": "#0B1220",
        "nx-neutral-700": "#334155",
        "nx-neutral-500": "#6B7280",
        "nx-neutral-200": "#E5E7EB",
        "nx-neutral-50": "#F8FAFC"
      }
    }
  },
  plugins: []
} satisfies Config
'@ | Out-File -Encoding utf8 "apps/web/tailwind.config.ts"

@'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@ | Out-File -Encoding utf8 "apps/web/postcss.config.js"

# globals.css + layout.tsx
New-Item -ItemType Directory -Force -Path "apps/web/app/(styles)" | Out-Null

@'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Tokens base Nexum (CSS vars opcionales) */
:root{
  --nx-primary-500:#2563EB;
  --nx-primary-600:#1D4ED8;
  --nx-accent-500:#22C55E;
  --nx-accent-600:#16A34A;
  --nx-neutral-900:#0B1220;
  --nx-neutral-700:#334155;
  --nx-neutral-500:#6B7280;
  --nx-neutral-200:#E5E7EB;
  --nx-neutral-50:#F8FAFC;
}

html, body { height: 100%; }
'@ | Out-File -Encoding utf8 "apps/web/app/globals.css"

@'
export const metadata = {
  title: "Nexum — Conecta tu negocio con cualquier vertical",
  description: "POS SaaS modular con verticales enchufables"
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className="min-h-screen text-slate-900 bg-gradient-to-b from-[#DBEAFE] via-white to-white">
        {children}
      </body>
    </html>
  )
}
'@ | Out-File -Encoding utf8 "apps/web/app/layout.tsx"

# Crear page.tsx si no existe
if (-not (Test-Path "apps/web/app/page.tsx")) {
@'
export default function NexumLanding(){
  return (
    <main className="mx-auto max-w-7xl px-4 py-20">
      <h1 className="text-5xl font-extrabold">NEXUM</h1>
      <p className="mt-4 text-lg text-slate-600">Conecta tu negocio con cualquier vertical.</p>
    </main>
  )
}
'@ | Out-File -Encoding utf8 "apps/web/app/page.tsx"
}

Write-Host "Instalando dependencias del workspace y del app web..." -ForegroundColor Cyan
pnpm i

Write-Host "Listo. Puedes correr:" -ForegroundColor Green
Write-Host "  pnpm -F @nexum/web dev" -ForegroundColor Green
Write-Host "o desde el root: pnpm dev (cuando tengamos turbo apuntando a devs)" -ForegroundColor DarkGreen
