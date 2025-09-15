Write-Host "== TESTS ==" -ForegroundColor Cyan
pnpm lint
pnpm -w ts:check || pnpm -w tsc --noEmit
pnpm test || echo "no tests"
Write-Host "OK" -ForegroundColor Green
