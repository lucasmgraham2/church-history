# Church History Explorer

An interactive application for exploring and learning about church history through timelines, eras, and historical events. This project combines a Flutter mobile frontend with Python backend services for data management and AI-powered insights.

## Project Overview

Church History Explorer provides an accessible platform for students, researchers, and enthusiasts to discover key events, figures, and developments across different eras of Christian history. The application features:

- **Interactive Timeline**: Browse church history organized by historical eras
- **Detailed Era Information**: Explore key events, theological developments, and influential figures
- **Historical Images**: View curated historical imagery related to church periods
- **AI-Powered Insights**: Get intelligent context and explanations about historical events
- **Multi-Era Exploration**: Navigate seamlessly through different periods of church history

## Quick Setup

### 1. Database Setup

**Windows:**
```bash
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

### 2. Start Services
```bash
# Terminal 1 - Storage Service (Port 8002)
python storage_service/main_simple.py

# Terminal 2 - API Gateway (Port 8000)  
python api_gateway/main_simple.py

# Terminal 3 - Flutter App
cd flutter_frontend
flutter run

# Terminal 4 - LLM Service
python llm_service/main_simple.py
```

## Architecture

- **Storage Service**: User authentication and historical data management (PostgreSQL)
- **API Gateway**: API orchestration, token management, and request routing
- **LLM Service**: AI-powered service for generating historical insights and context
- **Flutter Frontend**: Cross-platform mobile application for church history exploration

### Features

- **Church History Database**: Comprehensive data on historical eras, events, and figures
- **Historical Content**: Curated images and detailed descriptions of important periods
- **AI Insights**: Intelligent explanations and context about historical developments
- **User Authentication**: Secure account system for personalized exploration experience

## API Endpoints

- `POST /auth/register` - Create new user account
- `POST /auth/login` - User authentication
- `GET /auth/me` - Get current user profile
- `POST /auth/logout` - User logout
- Historical data endpoints for retrieving era information, events, and images

## Requirements

- **Python 3.7+** with pip
- **PostgreSQL 14+** (auto-installed by setup scripts)
- **Flutter SDK** for mobile development

## Content

The application will include historical data covering various church history eras:
- Early Christian Church
- The Imperial Church
- Medieval Christianity 
- Reformation Era
- Modern Christianity

## Troubleshooting

**Database Connection Issues:**
- Ensure PostgreSQL service is running
- Verify database credentials are correct

**Port Conflicts:**
- Storage Service: Port 8002
- API Gateway: Port 8000
- LLM Service: Port 8001
- Make sure these ports are available

## Development

This is a project focused on making church history accessible and learnable.
