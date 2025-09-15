param(
  [string]$ProjectName = "nexum",
  [switch]$InitGit = $true,
  [switch]$Install = $true
)

$ErrorActionPreference = "Stop"

function Need($cmd) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "No se encontró '$cmd'. Instálalo y reintenta."
  }
}

Write-Host "== BOOTSTRAP NEXUM ==" -ForegroundColor Cyan

Need node
Need pnpm
Need git

# ESTRUCTURA
New-Item -ItemType Directory -Force -Path ".github/workflows" | Out-Null
New-Item -ItemType Directory -Force -Path "docs/ADRs" | Out-Null
New-Item -ItemType Directory -Force -Path "scripts/windows" | Out-Null
New-Item -ItemType Directory -Force -Path "apps/web/app" | Out-Null
New-Item -ItemType Directory -Force -Path "apps/web/public" | Out-Null
New-Item -ItemType Directory -Force -Path "apps/api" | Out-Null
New-Item -ItemType Directory -Force -Path "packages/core" | Out-Null
New-Item -ItemType Directory -Force -Path "packages/ui" | Out-Null
New-Item -ItemType Directory -Force -Path "packages/db" | Out-Null

# GITIGNORE
@'
# Node
node_modules
pnpm-lock.yaml
dist
.next
.out
.cache
coverage
.env*
.DS_Store
'@ | Out-File -Encoding utf8 ".gitignore"

# EDITORCONFIG
@'
root = true
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
'@ | Out-File -Encoding utf8 ".editorconfig"

# PRETTIER
@'
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "es5"
}
'@ | Out-File -Encoding utf8 ".prettierrc"

# ESLINT
@'
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "env": { "node": true, "es6": true },
  "ignorePatterns": ["node_modules", "dist", ".next"]
}
'@ | Out-File -Encoding utf8 ".eslintrc.json"

# TSCONFIG BASE
@'
{
  "compilerOptions": {
    "target": "ES2021",
    "lib": ["ES2021", "DOM"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": {
      "@nexum/core/*": ["packages/core/*"],
      "@nexum/ui/*": ["packages/ui/*"],
      "@nexum/db/*": ["packages/db/*"]
    }
  }
}
'@ | Out-File -Encoding utf8 "tsconfig.base.json"

# TURBO
@'
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**", ".next/**"] },
    "lint": {},
    "test": {},
    "dev": { "cache": false }
  }
}
'@ | Out-File -Encoding utf8 "turbo.json"

# PACKAGE.JSON
@'
{
  "name": "'+$ProjectName+'-monorepo",
  "private": true,
  "packageManager": "pnpm@9",
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "ts:check": "tsc -p tsconfig.base.json --noEmit",
    "prisma:generate": "echo TODO: add prisma generate",
    "prisma:migrate:dev": "echo TODO: add prisma migrate dev"
  },
  "devDependencies": {
    "eslint": "^9.9.0",
    "@typescript-eslint/parser": "^8.0.0",
    "@typescript-eslint/eslint-plugin": "^8.0.0",
    "prettier": "^3.3.3",
    "turbo": "^2.0.0",
    "typescript": "^5.6.2"
  },
  "workspaces": [
    "apps/*",
    "packages/*"
  ]
}
'@ | Out-File -Encoding utf8 "package.json"

# PR TEMPLATE
@'
## Resumen
Describe brevemente el cambio. ¿Qué problema resuelve?

## Tipo de cambio
- [ ] Feature
- [ ] Fix
- [ ] Chore/Refactor
- [ ] Docs

## Checklist
- [ ] Lint ok
- [ ] Tests pasan
- [ ] Migraciones aplicadas (si aplica)
- [ ] Docs actualizadas (SRS/ADR)

## Riesgos y mitigación
- Riesgos:
- Rollback:
'@ | Out-File -Encoding utf8 ".github/PULL_REQUEST_TEMPLATE.md"

# CODEOWNERS
@'
# Ajusta con tus usuarios de GitHub
/packages/core/ @sofia-assistant
/packages/db/ @sofia-assistant
/packages/ui/ @sofia-assistant
/apps/web/ @sofia-assistant
/apps/api/ @sofia-assistant
/docs/ @sofia-assistant
'@ | Out-File -Encoding utf8 ".github/CODEOWNERS"

# CI
@'
name: CI
on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: "pnpm"
      - uses: pnpm/action-setup@v4
        with: { version: 9, run_install: true }
      - run: pnpm lint
      - run: pnpm -w ts:check || pnpm -w tsc --noEmit
      - run: pnpm test || echo "no tests yet"
      - run: pnpm -w build
'@ | Out-File -Encoding utf8 ".github/workflows/ci.yml"

# ADR-001
@'
# ADR-001 — Tenancy + Row Level Security (RLS)

## Contexto
Nexum es multi-tenant. Requerimos aislamiento fuerte entre inquilinos y controles en la base de datos.

## Decisión
- Una única base con `tenant_id UUID` en todas las tablas.
- Activar RLS y setear `app.tenant_id` por request.
- Doble validación: middleware + políticas RLS.

## SQL ejemplo
```sql
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY products_tenant_isolation
ON public.products
USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
```
'@ | Out-File -Encoding utf8 "docs/ADRs/ADR-001-tenancy-rls.md"

# SRS
@'
# SRS — Nexum (POS Core + Módulo FlowFix)

## Feature: Venta con múltiples métodos de pago
Scenario: Ticket con pago mixto
  Given un catálogo con "Protector" a $200
  And una caja abierta
  When agrego "Protector" x1 al ticket
  And aplico pago "efectivo" $100 y "tarjeta" $100
  Then el ticket se marca como "pagado"
  And se imprime el comprobante

## Feature: Control de inventario con alertas
Scenario: No permitir stock negativo
  Given "Batería iPhone" stock 0
  When intento vender 1 unidad
  Then el sistema rechaza la venta por falta de stock

## FlowFix — Orden de reparación
Scenario: Crear orden y pasar a "En reparación"
  Given cliente "Juan" y equipo "iPhone 12 IMEI 123"
  When creo la orden con diagnóstico
  Then la orden queda en "Ingresado"
  When el técnico la toma y cambia a "En reparación"
  Then queda auditado
'@ | Out-File -Encoding utf8 "docs/SRS.md"

# SCRIPTS POWERSHELL
@'
param([switch]$Rebuild)
Write-Host "== NEXUM DEV UP ==" -ForegroundColor Cyan
if ($Rebuild){ docker compose down -v }
docker compose up -d postgres redis minio
Start-Sleep -Seconds 3
pnpm i
pnpm -w prisma:generate
pnpm -w prisma:migrate:dev
Write-Host "Listo. Ejecuta: pnpm dev" -ForegroundColor Green
'@ | Out-File -Encoding utf8 "scripts/windows/dev-up.ps1"

@'
$errors=@()
function Need($c){ if(-not (Get-Command $c -ErrorAction SilentlyContinue)){ $script:errors += "$c no encontrado" } }
Need node; Need pnpm; Need git; Need docker
if($errors.Count){ Write-Host "ERRORES:" -ForegroundColor Red; $errors |% {Write-Host " - $_"}; exit 1 }
$ver=(node -v).Trim('v'); if([int]$ver.Split('.')[0] -lt 20){ Write-Host "Node >=20 requerido (actual $ver)" -ForegroundColor Yellow }
Write-Host "Entorno OK" -ForegroundColor Green
'@ | Out-File -Encoding utf8 "scripts/windows/env-check.ps1"

@'
Write-Host "== TESTS ==" -ForegroundColor Cyan
pnpm lint
pnpm -w ts:check || pnpm -w tsc --noEmit
pnpm test || echo "no tests"
Write-Host "OK" -ForegroundColor Green
'@ | Out-File -Encoding utf8 "scripts/windows/test.ps1"

# LANDING PLACEHOLDER
@'
export default function NexumLanding() {
  return (
    <main className="min-h-screen text-slate-900 bg-gradient-to-b from-[#DBEAFE] via-white to-white">
      <section className="mx-auto max-w-7xl px-4 py-20">
        <h1 className="text-5xl font-extrabold">NEXUM</h1>
        <p className="mt-4 text-lg text-slate-600">Conecta tu negocio con cualquier vertical.</p>
      </section>
    </main>
  )
}
'@ | Out-File -Encoding utf8 "apps/web/app/page.tsx"

# API placeholder
@'
/** Placeholder: API service (Nest se integrará luego) */
console.log("API placeholder. Integra NestJS aquí.");
'@ | Out-File -Encoding utf8 "apps/api/README.md"

# README
@'
# Nexum — Monorepo

## Estructura
- apps/web: Frontend (Next.js App Router)
- apps/api: Backend (NestJS, próximamente)
- packages/core: Dominio POS
- packages/ui: Design System
- packages/db: Prisma/DB

## Scripts
- pnpm dev | build | lint | test
- scripts/windows/dev-up.ps1
- scripts/windows/env-check.ps1
'@ | Out-File -Encoding utf8 "README.md"

Write-Host "Listo. Fin del script." -ForegroundColor Green
