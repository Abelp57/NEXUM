# ADR 0001 — Arquitectura, Tenancy y RLS (NEXUM)

- Status: Accepted
- Date: 2025-09-14

## Contexto
NEXUM = base POS + módulos verticales (taller, veterinaria, consultorio, etc.).  
Monorepo con pnpm/turbo. Frontend Next.js 14 (App Router), TypeScript y Tailwind.

## Objetivos
- Escalar por vertical manteniendo una base común (POS).
- Aislamiento de datos por cliente/organización (multi-tenancy) con RLS en PostgreSQL.
- DX sólida: pnpm + turbo, CI mínimo (lint + build), TS estricto y lint estable.

## Decisiones
- **Monorepo:** pnpm + turbo; workspaces: `apps/web`, `apps/api` (TBD), `packages/ui`, `packages/tsconfig`.
- **Frontend:** Next.js 14, React 18, TS, Tailwind; componentes UI base (Button/Card).
- **Herramientas:** ESLint 8.x (alineado con Next 14), TypeScript 5.x, Corepack + pnpm 9.12.3 fijado en `package.json`.
- **CI:** GitHub Actions “ci” en `main` (push/PR) para `apps/web`: instala deps, `lint`, `build`, cache pnpm store.
- **Multi-tenancy:** PostgreSQL con columna `tenant_id` en tablas de dominio. RLS habilitado; sesión establece el tenant activo.
- **RLS (ejemplo):**
  - Policy por tabla: permitir `SELECT/INSERT/UPDATE/DELETE` sólo cuando `tenant_id = current_setting('app.tenant_id')::uuid`.
  - Función de bootstrap de sesión: `SELECT set_config('app.tenant_id', '<uuid>', false);`
- **AuthZ/AuthN:** TBD (se evaluará proveedor y modelo de roles/claims).
- **Migrations/ORM:** TBD (Prisma o Drizzle; decidir en ADR separado).

## Consecuencias
**Pros:** seguridad por fila, base común reutilizable, CI que evita roturas en `main`.  
**Contras:** +complejidad en migraciones y pruebas multi-tenant.  
**Riesgos:** definir límites/ownership de cada módulo y gobernanza de esquemas.

## Próximos pasos
- ADR 0002 — Elección ORM y estrategia de migraciones.
- ADR 0003 — Modelo de autenticación/autorización y propagación de `tenant_id`.
- Activar job de CI para `apps/api` cuando esté listo.