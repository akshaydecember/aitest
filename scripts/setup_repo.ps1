Param()

Write-Host "Initializing repository branches (dev, stage, main)..."
git branch -M main
git checkout -b dev
git checkout -b stage
git checkout main
Write-Host "Branches created: dev, stage, main"
