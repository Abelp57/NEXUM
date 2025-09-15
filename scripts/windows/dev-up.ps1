param([switch]$Rebuild)
Write-Host "== NEXUM DEV UP ==" -ForegroundColor Cyan
if ($Rebuild){ docker compose down -v }
docker compose up -d postgres redis minio
Start-Sleep -Seconds 3
pnpm i
pnpm -w prisma:generate
pnpm -w prisma:migrate:dev
Write-Host "Listo. Ejecuta: pnpm dev" -ForegroundColor Green
