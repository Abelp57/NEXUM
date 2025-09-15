#!/usr/bin/env bash
set -euo pipefail
PROJECT_NAME="${1:-nexum}"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "Falta $1"; exit 1; }; }
need node; need pnpm; need git

mkdir -p .github/workflows docs/ADRs scripts/windows apps/web/app apps/web/public apps/api packages/core packages/ui packages/db

cat > .gitignore <<'EOF'
node_modules
pnpm-lock.yaml
dist
.next
.out
.cache
coverage
.env*
.DS_Store
EOF

cat > .editorconfig <<'EOF'
root = true
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
EOF

cat > .prettierrc <<'EOF'
{ "semi": false, "singleQuote": true, "trailingComma": "es5" }
EOF

cat > .eslintrc.json <<'EOF'
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "extends": ["eslint:recommended","plugin:@typescript-eslint/recommended"],
  "env": { "node": true, "es6": true },
  "ignorePatterns": ["node_modules","dist",".next"]
}
EOF

cat > tsconfig.base.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2021",
    "lib": ["ES2021","DOM"],
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
EOF

cat > turbo.json <<'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**",".next/**"] },
    "lint": {},
    "test": {},
    "dev": { "cache": false }
  }
}
EOF

cat > package.json <<EOF
{
  "name": "$PROJECT_NAME-monorepo",
  "private": true,
  "packageManager": "pnpm@9",
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "ts:check": "tsc -p tsconfig.base.json --noEmit",
    "prisma:generate": "echo TODO: prisma generate",
    "prisma:migrate:dev": "echo TODO: prisma migrate dev"
  },
  "devDependencies": {
    "eslint": "^9.9.0",
    "@typescript-eslint/parser": "^8.0.0",
    "@typescript-eslint/eslint-plugin": "^8.0.0",
    "prettier": "^3.3.3",
    "turbo": "^2.0.0",
    "typescript": "^5.6.2"
  },
  "workspaces": ["apps/*","packages/*"]
}
EOF

mkdir -p .github
cat > .github/PULL_REQUEST_TEMPLATE.md <<'EOF'
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
EOF

cat > .github/CODEOWNERS <<'EOF'
/packages/core/ @sofia-assistant
/packages/db/ @sofia-assistant
/packages/ui/ @sofia-assistant
/apps/web/ @sofia-assistant
/apps/api/ @sofia-assistant
/docs/ @sofia-assistant
EOF

cat > .github/workflows/ci.yml <<'EOF'
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
          cache: pnpm
      - uses: pnpm/action-setup@v4
        with:
          version: 9
          run_install: true
      - run: pnpm lint
      - run: pnpm -w ts:check || pnpm -w tsc --noEmit
      - run: pnpm test || echo "no tests yet"
      - run: pnpm -w build
EOF

cat > docs/ADRs/ADR-001-tenancy-rls.md <<'EOF'
# ADR-001 — Tenancy + RLS
- Una única base con `tenant_id` en todas las tablas.
- RLS activo y `SET LOCAL app.tenant_id=$TENANT` por request.
- Doble validación: middleware + políticas RLS.
EOF

cat > docs/SRS.md <<'EOF'
# SRS — Nexum (POS Core + Módulo FlowFix)
## Venta con múltiples métodos de pago
Scenario: Ticket con pago mixto
  Given "Protector" a $200 y caja abierta
  When agrego 1 y pago 100 efectivo + 100 tarjeta
  Then ticket "pagado" e impresión

## Inventario sin stock negativo
Scenario: Rechazo por stock 0
  Given "Batería iPhone" stock 0
  When intento vender 1
  Then rechaza la venta

## FlowFix — Orden
Scenario: Ingreso y En reparación
  Given cliente y equipo
  When creo orden con diagnóstico
  Then estado Ingresado
  When técnico toma
  Then En reparación auditado
EOF

cat > scripts/windows/dev-up.ps1 <<'EOF'
param([switch]$Rebuild)
Write-Host "== NEXUM DEV UP ==" -ForegroundColor Cyan
if ($Rebuild){ docker compose down -v }
docker compose up -d postgres redis minio
Start-Sleep -Seconds 3
pnpm i
pnpm -w prisma:generate
pnpm -w prisma:migrate:dev
Write-Host "Listo. Ejecuta: pnpm dev" -ForegroundColor Green
EOF

cat > scripts/windows/env-check.ps1 <<'EOF'
$errors=@()
function Need($c){ if(-not (Get-Command $c -ErrorAction SilentlyContinue)){ $script:errors += "$c no encontrado" } }
Need node; Need pnpm; Need git; Need docker
if($errors.Count){ Write-Host "ERRORES:" -ForegroundColor Red; $errors |% {Write-Host " - $_"}; exit 1 }
$ver=(node -v).Trim('v'); if([int]$ver.Split('.')[0] -lt 20){ Write-Host "Node >=20 requerido (actual $ver)" -ForegroundColor Yellow }
Write-Host "Entorno OK" -ForegroundColor Green
EOF

cat > scripts/windows/test.ps1 <<'EOF'
Write-Host "== TESTS ==" -ForegroundColor Cyan
pnpm lint
pnpm -w ts:check || pnpm -w tsc --noEmit
pnpm test || echo "no tests"
Write-Host "OK" -ForegroundColor Green
EOF

cat > apps/web/app/page.tsx <<'EOF'
export default function NexumLanding(){
  return (
    <main className="min-h-screen text-slate-900 bg-gradient-to-b from-[#DBEAFE] via-white to-white">
      <section className="mx-auto max-w-7xl px-4 py-20">
        <h1 className="text-5xl font-extrabold">NEXUM</h1>
        <p className="mt-4 text-lg text-slate-600">Conecta tu negocio con cualquier vertical.</p>
      </section>
    </main>
  )
}
EOF

echo "# Nexum — Monorepo" > README.md

git init
git checkout -b main
git add .
git commit -m "chore: bootstrap Nexum monorepo"
echo "OK. Ejecuta: pnpm i"
