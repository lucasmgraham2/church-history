# Startup script for Church History project
# Starts all Python services and Flutter frontend

Write-Host "Starting Church History Application..." -ForegroundColor Green

# Start API Gateway
Write-Host "`nStarting API Gateway..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\api_gateway'; python main_simple.py"

# Start LLM Service
Write-Host "Starting LLM Service..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\llm_service'; python main_simple.py"

# Start Storage Service
Write-Host "Starting Storage Service..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\storage_service'; python main_simple.py"

# Wait a bit for services to initialize
Write-Host "`nWaiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start Flutter Frontend
Write-Host "`nStarting Flutter Frontend..." -ForegroundColor Cyan
Set-Location "$PSScriptRoot\flutter_frontend"
flutter run

Write-Host "`nAll services started!" -ForegroundColor Green
