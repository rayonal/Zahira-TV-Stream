param(
    [string]$RepoName = "zahira-tv-stream-catalog"
)

Write-Host "ZTS-0.2B GitHub Pages layout is already prepared under .\docs"
Write-Host ""
Write-Host "Create/use a repository you control, then copy this pack into it."
Write-Host "Enable Pages: main branch -> /docs."
Write-Host ""
Write-Host "Expected catalog URL pattern:"
Write-Host "https://<github-username>.github.io/$RepoName/catalog.json"
Write-Host ""
Write-Host "Do not configure the Android app until that HTTPS URL really exists and verify-remote.ps1 passes."
