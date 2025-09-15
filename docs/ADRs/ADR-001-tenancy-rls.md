# ADR-001 â€” Tenancy + Row Level Security (RLS)

## Contexto
Nexum es multi-tenant. Requerimos aislamiento fuerte entre inquilinos y controles en la base de datos.

## DecisiÃ³n
- Una Ãºnica base con `tenant_id UUID` en todas las tablas.
- Activar RLS y setear `app.tenant_id` por request.
- Doble validaciÃ³n: middleware + polÃ­ticas RLS.

## SQL ejemplo
```sql
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY products_tenant_isolation
ON public.products
USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
```
