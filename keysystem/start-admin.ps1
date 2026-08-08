# ============================================================
# lizard - lance le panel admin avec la config pré-chargée
# 1) Lit keysystem/.env
# 2) Génère keysystem/config.js (lue par admin.html)
# 3) Ouvre admin.html dans le navigateur
# ============================================================
$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path -LiteralPath $envFile)) {
    Write-Host "ERREUR: $envFile introuvable. Copie keysystem/.env depuis le template." -ForegroundColor Red
    exit 1
}

$vars = @{}
Get-Content -LiteralPath $envFile | Where-Object {
    $_ -match '^\s*([A-Z0-9_]+)\s*=\s*(.*)$' -and $_ -notmatch '^\s*#'
} | ForEach-Object {
    if ($_ -match '^\s*([A-Z0-9_]+)\s*=\s*(.*)$') {
        $vars[$matches[1]] = $matches[2].Trim('"').Trim("'")
    }
}

$configJs = Join-Path $PSScriptRoot "config.js"
$content = @"
// AUTO-GENERE par start-admin.ps1 - ne pas éditer manuellement
window.LIZARD_CONFIG = {
  url: "$($vars['SUPABASE_URL'])",
  anonKey: "$($vars['SUPABASE_ANON_KEY'])",
  serviceKey: "$($vars['SUPABASE_SERVICE_KEY'])"
};
"@
Set-Content -LiteralPath $configJs -Value $content -Encoding UTF8
Write-Host "config.js genere (URL + anon pre-remplis)." -ForegroundColor Green

if (-not $vars['SUPABASE_SERVICE_KEY']) {
    Write-Host "ATTENTION: SUPABASE_SERVICE_KEY est vide dans .env" -ForegroundColor Yellow
    Write-Host "Revele la cle service_role dans Supabase (Settings > API) et colle-la dans keysystem/.env" -ForegroundColor Yellow
}

Start-Process $PSScriptRoot\admin.html
