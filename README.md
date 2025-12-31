# Church History Explorer

An interactive application for exploring and learning about church history through timelines, eras, and historical events. This project combines a Flutter mobile frontend with Python backend services for data management and AI-powered insights.

## Project Overview

Church History Explorer provides an accessible platform for students, researchers, and enthusiasts to discover key events, figures, and developments across different eras of Christian history. The application features:

- **Interactive Timeline**: Browse church history organized by historical eras
- **Detailed Era Information**: Explore key events, theological developments, and influential figures
- **Historical Images**: View curated historical imagery related to church periods
- **AI-Powered Insights**: Get intelligent context and explanations about historical events
- **Multi-Era Exploration**: Navigate seamlessly through different periods of church history

## Local Setup Guide

### Prerequisites

Before starting, ensure you have:
- **Python 3.7+** with pip
- **Flutter SDK** (for mobile development)
- **PostgreSQL 14+** (will be installed in Step 1)
- **Ollama** with gemma3:1b model (for AI service)

### Step 1: PostgreSQL Database Setup

PostgreSQL is required for storing user data and historical content.

**Windows:**
```powershell
# Run the setup script
setup_windows_postgres.bat
```

**macOS:**
```bash
chmod +x setup_macos_postgres.sh
./setup_macos_postgres.sh
```

**What this creates:**
- PostgreSQL database for storing user data and historical content
- Authentication system for user accounts
- Connection pool for reliable data access

### Step 2: Ollama Model Setup

The LLM Service requires Ollama and the gemma3:1b model for church history AI insights.

**Step 2a: Install Ollama**

1. Download Ollama from [https://ollama.ai](https://ollama.ai)
2. Install it following the platform-specific instructions

**Step 2b: Download the gemma3:1b Model**

Open a terminal and run:
```bash
ollama pull gemma3:1b
```

This will download the gemma3:1b model (~2GB). The model will be stored locally and used by the LLM Service.

**Verify the model is installed:**
```bash
ollama list
```

You should see `gemma3:1b` in the output.

### Step 3: Install Python Dependencies

Install required Python packages for each service:

```bash
# Storage Service dependencies
cd storage_service
pip install -r requirements.txt
cd ..

# API Gateway dependencies
cd api_gateway
pip install -r requirements.txt
cd ..

# LLM Service dependencies
cd llm_service
pip install -r requirements.txt
cd ..
```

### Step 4: Start All Services

**Option A: Automated Startup Script (Recommended)**

Windows PowerShell:
```powershell
./start-all.ps1
```

This script will:
1. Start the API Gateway (Port 8000)
2. Start the LLM Service (Port 8001)
3. Start the Storage Service (Port 8002)
4. Wait for services to initialize
5. Launch the Flutter app in Chrome

**Option B: Manual Startup (Multiple Terminals)**

If you prefer to run services individually, open separate terminals for each:

```bash
# Terminal 1 - Storage Service (Port 8002)
cd storage_service
python main_simple.py

# Terminal 2 - API Gateway (Port 8000)
cd api_gateway
python main_simple.py

# Terminal 3 - LLM Service (Port 8001)
cd llm_service
python main_simple.py

# Terminal 4 - Flutter Frontend
cd flutter_frontend
flutter pub get
flutter run -d chrome
# Or for Windows: flutter run -d windows
```

### Step 5: Create an Account and Start Exploring

1. Open the app
2. Click "Don't have an account? Register"
3. Enter username, email, and password
4. Log in with your credentials
5. Explore church history and use the AI assistant!

## Architecture

The application uses a microservices architecture with the following components:

- **Storage Service** (Port 8002): User authentication and historical data management using PostgreSQL
- **API Gateway** (Port 8000): API orchestration, token management, and request routing
- **LLM Service** (Port 8001): AI-powered service for generating historical insights using Ollama's gemma3:1b model
- **Flutter Frontend**: Cross-platform mobile/web application for church history exploration

### Service Dependencies

```
Flutter App
    ↓
API Gateway (Port 8000)
    ↙       ↓       ↘
Storage  LLM      
Svc      Svc
(8002)   (8001)
```

## API Endpoints

- `POST /auth/register` - Create new user account
- `POST /auth/login` - User authentication
- `GET /auth/me` - Get current user profile
- `POST /auth/logout` - User logout
- Historical data endpoints for retrieving era information, events, and images

## Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL service is running
- Verify database credentials are correct
- Check that the database was properly created during setup

### Port Conflicts
- Storage Service: Port 8002
- API Gateway: Port 8000
- LLM Service: Port 8001
- Make sure these ports are available and not used by other applications

### Ollama/LLM Service Issues
- Ensure Ollama is running in the background
- Verify the gemma3:1b model is installed: `ollama list`
- If the model isn't installed, download it: `ollama pull gemma3:1b`
- Check that the LLM Service can connect to Ollama on its default port (11434)

### Service Startup Issues
- Ensure Python 3.7+ is installed
- Verify all dependencies are installed with `pip install -r requirements.txt` in each service directory
- Run services individually to see error messages if the startup script fails
- Check that PostgreSQL is fully started before running storage_service

## Development

This is a project focused on making church history accessible and learnable.
