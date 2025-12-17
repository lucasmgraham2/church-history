# Church History Explorer - Quick Start Guide

## What Changed

Your app has been completely transformed from **Bariatric GPT** (medical assistant) to **Church History Explorer** (educational platform).

### New App Features
- 📚 **Interactive Church History**: Browse through 4 major historical eras
- 📖 **Detailed Events**: 5+ major historical events with full context
- 🤖 **Church History AI**: Ask the AI any question about church history
- 🏷️ **Bookmarks**: Save your favorite events for later
- 🔍 **Search**: Find events and topics quickly
- 🎨 **Beautiful UI**: Color-coded eras with expandable event cards

## Architecture Overview

```
Flutter App (Port: Dynamic)
        ↓
API Gateway (Port 8000)
    ↙       ↓       ↘
Storage  LLM      (History)
Svc      Svc
(8002)   (8001)
```

## How to Start

### Step 1: Start Backend Services

**Terminal 1 - Storage Service**
```bash
cd storage_service
pip install -r requirements.txt
python main_simple.py
# Runs on http://localhost:8002
```

**Terminal 2 - LLM Service** (Church History AI)
```bash
cd llm_service
pip install -r requirements.txt
python main_simple.py
# Runs on http://localhost:8001
# Note: Requires Ollama with gemma3:1b model
```

**Terminal 3 - API Gateway**
```bash
cd api_gateway
pip install -r requirements.txt
python main_simple.py
# Runs on http://localhost:8000
```

### Step 2: Start Flutter App

```bash
cd flutter_frontend
flutter pub get
flutter run -d windows
# Or: flutter run -d chrome (for web)
```

### Step 3: Create Account

1. Open the app
2. Click "Don't have an account? Register"
3. Enter username, email, password
4. Login with your credentials

### Step 4: Explore Church History!

1. **Browse Eras**: See the 4 major church history periods
2. **View Events**: Tap an era to see detailed events
3. **Expand Events**: Click event cards to see full details
4. **Ask AI**: Press the blue "Ask AI" button to chat with the Church History assistant
5. **Bookmark**: Star your favorite events

## Main Screens

### Home Screen
- Shows 4 major church history eras
- Each era card displays: title, year range, description, event count
- Search bar to find eras
- Floating "Ask AI" button

### Era Detail Screen
- List of events in the era
- Expandable event cards
- Sort events by year or title
- Each event shows: year, location, title, preview

### Event Detail Screen
- Full event information
- Sections: Overview, Details, Key Figures, Significance, Related Topics
- Bookmark button
- "Ask AI About This Event" button with context

### AI Assistant Screen
- Chat with Church History AI
- Ask questions about events, figures, theology
- Context from events you're viewing
- Markdown-formatted responses

## Sample Data

### Early Church Period (33 AD - 325 AD)
1. **Day of Pentecost** - Birth of the Christian church
2. **Persecution Under Nero** - First major persecutions in Rome
3. **Paul's Epistles** - Foundational letters to early churches
4. **Writing of Gospels** - Matthew, Mark, Luke, John recorded Jesus's life
5. **Council of Nicaea** - First major church council, established the Nicene Creed

More eras can be added by editing the API Gateway endpoints.

## Key Files Changed

### New Files
- `flutter_frontend/lib/models/church_history_models.dart` - Data models
- `flutter_frontend/lib/services/church_history_service.dart` - History API service
- `flutter_frontend/lib/screens/era_detail_screen.dart` - Era browsing
- `flutter_frontend/lib/screens/event_detail_screen.dart` - Event details
- `llm_service/app/graph_church_history.py` - Church History AI

### Updated Files
- `flutter_frontend/pubspec.yaml` - App name & package
- `flutter_frontend/lib/main.dart` - Updated branding
- `flutter_frontend/lib/screens/home_screen.dart` - New era-based layout
- `flutter_frontend/lib/screens/ai_assistant_screen.dart` - Church History context
- `api_gateway/main_simple.py` - New history endpoints
- `llm_service/app/api.py` - Uses church history graph
- All screen imports - Updated to new package name

## API Endpoints

### Authentication (existing)
```
POST /auth/register
POST /auth/login
GET  /auth/me
POST /auth/logout
```

### Church History (new)
```
GET  /history/eras                      - Get all eras
GET  /history/eras/{era_id}            - Get era with events
GET  /history/events/{event_id}        - Get event details
POST /history/events/{event_id}/viewed - Track view
POST /history/events/{event_id}/bookmark - Bookmark
POST /history/events/{event_id}/unbookmark - Unbookmark
GET  /history/search?q=<query>         - Search
```

### Chat
```
POST /chat                              - Send message to AI
```

## Customization Tips

### Add More Events
Edit `/api_gateway/main_simple.py`:
```python
@app.get("/history/eras/{era_id}")
async def get_era(era_id: str, ...):
    eras_data = {
        "era_name": {
            "events": [
                {
                    "id": "unique_id",
                    "title": "Event Title",
                    "year": "1234 AD",
                    "location": "Location",
                    # ... more fields
                }
            ]
        }
    }
```

### Customize Colors
Change era colors by editing the color hex codes in:
- `get_all_eras()` - main color
- Update in Flutter screens to match

### Enhance AI Responses
Edit `llm_service/app/graph_church_history.py`:
```python
CHURCH_HISTORY_SYSTEM_PROMPT = """
Your custom instructions for the AI...
"""
```

## Troubleshooting

### "Connection refused" on localhost
- Ensure all 3 backend services are running
- Check ports: 8000, 8001, 8002

### LLM Service not responding
- Ensure Ollama is installed: `ollama pull gemma3:1b`
- Check Ollama is running: `ollama serve`

### Flutter app won't start
- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter is properly installed: `flutter doctor`

### Login fails
- Ensure storage service is running
- Check username/email don't already exist
- Make sure password meets requirements

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| API Gateway | FastAPI (Python) |
| LLM | LangChain + Ollama |
| Storage | Python service |
| Auth | Token-based (Bearer) |
| Database | (Expandable to any DB) |

## Next Steps

1. ✅ **Test the app** - Try all the features
2. ⏭️ **Add more events** - Expand Medieval, Reformation, Modern eras
3. ⏭️ **Connect to database** - Replace sample data with persistent storage
4. ⏭️ **Add images** - Include historical photos and maps
5. ⏭️ **Enhance AI** - Add more sophisticated church history knowledge
6. ⏭️ **Deploy** - Docker containerize and deploy to cloud

## Support

For detailed information, see:
- `CHURCH_HISTORY_TRANSFORMATION.md` - Complete transformation details
- `README.md` - Original project info
- Code comments - Inline documentation

---

**Created**: December 15, 2025
**App**: Church History Explorer
**Status**: Ready to use!
