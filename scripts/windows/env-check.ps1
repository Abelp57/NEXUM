$errors=@()
function Need($c){ if(-not (Get-Command $c -ErrorAction SilentlyContinue)){ $script:errors += "$c no encontrado" } }
Need node; Need pnpm; Need git; Need docker
if($errors.Count){ Write-Host "ERRORES:" -ForegroundColor Red; $errors |% {Write-Host " - $_"}; exit 1 }
$ver=(node -v).Trim('v'); if([int]$ver.Split('.')[0] -lt 20){ Write-Host "Node >=20 requerido (actual $ver)" -ForegroundColor Yellow }
Write-Host "Entorno OK" -ForegroundColor Green
