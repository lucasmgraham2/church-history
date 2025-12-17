from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import Optional
import uuid
import httpx
import os

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

STORAGE_URL = "http://localhost:8002"
LLM_SERVICE_URL = "http://localhost:8001"
tokens = {}
# Optional key the gateway will send when persisting memory to storage service.
STORAGE_SERVICE_KEY = os.getenv("STORAGE_SERVICE_KEY")

class UserRegister(BaseModel):
    email: EmailStr
    username: str
    password: str

class UserLogin(BaseModel):
    username: str
    password: str

class ChatRequest(BaseModel):
    message: str
    patient_id: Optional[str] = None

@app.post("/auth/register")
async def register(user_data: UserRegister):
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(f"{STORAGE_URL}/register", json=user_data.model_dump())
            if response.status_code == 400:
                raise HTTPException(status_code=400, detail=response.json().get("detail"))
            response.raise_for_status()
            user = response.json()
            token = f"token_{uuid.uuid4().hex[:16]}"
            tokens[token] = user["id"]
            return {"access_token": token, "token_type": "bearer", "user_id": user["id"]}
        except httpx.HTTPError:
            raise HTTPException(status_code=500, detail="Storage service unavailable")

@app.post("/auth/login") 
async def login(login_data: UserLogin):
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(f"{STORAGE_URL}/login", json=login_data.model_dump())
            if response.status_code == 401:
                raise HTTPException(status_code=401, detail="Invalid credentials")
            response.raise_for_status()
            result = response.json()
            token = f"token_{uuid.uuid4().hex[:16]}"
            tokens[token] = result["user_id"]
            return {"access_token": token, "token_type": "bearer", "user_id": result["user_id"]}
        except httpx.HTTPError:
            raise HTTPException(status_code=500, detail="Storage service unavailable")

@app.get("/auth/me")
async def get_current_user(authorization: Optional[str] = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    user_id = tokens.get(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(f"{STORAGE_URL}/me/{user_id}")
            response.raise_for_status()
            user_data = response.json()
            # Do not expose the internal conversation memory to client-side callers.
            if isinstance(user_data, dict) and 'memory' in user_data:
                user_data = dict(user_data)  # shallow copy
                user_data.pop('memory', None)
            return user_data
        except httpx.HTTPError:
            raise HTTPException(status_code=500, detail="Storage service unavailable")

@app.post("/auth/logout")
async def logout(authorization: Optional[str] = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
        if token in tokens:
            del tokens[token]
    except IndexError:
        pass
    
    return {"message": "Logout successful"}


@app.get("/auth/profile")
async def get_profile(authorization: Optional[str] = Header(None)):
    """Return the current user's profile (forwarded from storage service)."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    user_id = tokens.get(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")

    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(f"{STORAGE_URL}/me/{user_id}")
            response.raise_for_status()
            data = response.json()
            return {"profile": data.get("profile", {})}
        except httpx.HTTPError:
            raise HTTPException(status_code=500, detail="Storage service unavailable")


@app.put("/auth/profile")
async def update_profile(payload: dict, authorization: Optional[str] = Header(None)):
    """Update the current user's profile by forwarding to storage service."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    user_id = tokens.get(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")

    async with httpx.AsyncClient() as client:
        try:
            response = await client.put(f"{STORAGE_URL}/me/{user_id}/profile", json=payload)
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError:
            raise HTTPException(status_code=500, detail="Storage service unavailable")

@app.post("/chat")
async def chat_with_agent(chat_data: ChatRequest, authorization: Optional[str] = Header(None)):
    """
    Protected endpoint to chat with the LLM agent graph (now Church History AI).
    Requires authentication token and forwards user message to LLM service.
    """
    # Extract and validate token
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    user_id = tokens.get(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    llm_payload = {
        "message": chat_data.message,
        "user_id": str(user_id),
        "patient_id": chat_data.patient_id  # Reserved for future use
    }
    # Try to fetch the user's profile and conversation memory from the storage service
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get(f"{STORAGE_URL}/me/{user_id}")
            if resp.status_code == 200:
                user_info = resp.json()
                llm_payload["profile"] = user_info.get("profile", {})
            else:
                llm_payload["profile"] = {}

            # Fetch memory separately (use service key if configured)
            headers = {"X-SERVICE-KEY": STORAGE_SERVICE_KEY} if STORAGE_SERVICE_KEY else None
            if headers:
                mem_resp = await client.get(f"{STORAGE_URL}/me/{user_id}/memory", headers=headers)
            else:
                mem_resp = await client.get(f"{STORAGE_URL}/me/{user_id}/memory")

            if mem_resp.status_code == 200:
                mem_data = mem_resp.json()
                llm_payload["memory"] = mem_data.get("memory", "")
            else:
                llm_payload["memory"] = ""
            # Fetch recent conversation log (use service key if configured)
            if headers:
                log_resp = await client.get(f"{STORAGE_URL}/me/{user_id}/conversation_log", headers=headers)
            else:
                log_resp = await client.get(f"{STORAGE_URL}/me/{user_id}/conversation_log")

            if log_resp.status_code == 200:
                log_data = log_resp.json()
                llm_payload["conversation_log"] = log_data.get("log", "[]")
            else:
                llm_payload["conversation_log"] = "[]"
    except Exception:
        # If storage is unavailable or any error occurs, continue without profile/memory
        llm_payload["profile"] = {}
        llm_payload["memory"] = ""
    
    async with httpx.AsyncClient() as client:
        try:
            # Forward the request to the LLM Service
            # Use a long timeout, as agent graphs can be slow
            response = await client.post(
                f"{LLM_SERVICE_URL}/api/v1/invoke_agent_graph", 
                json=llm_payload,
                timeout=300.0 
            )
            
            # Propagate errors from the LLM service
            response.raise_for_status() 
            
            llm_result = response.json()

            # Persist updated memory if the LLM returned one
            try:
                new_memory = llm_result.get("memory")
                if new_memory:
                    async with httpx.AsyncClient() as client2:
                        headers = {"X-SERVICE-KEY": STORAGE_SERVICE_KEY} if STORAGE_SERVICE_KEY else None
                        if headers:
                            await client2.put(f"{STORAGE_URL}/me/{user_id}/memory", json={"memory": new_memory}, headers=headers)
                        else:
                            await client2.put(f"{STORAGE_URL}/me/{user_id}/memory", json={"memory": new_memory})

                # If the LLM returned an authoritative conversation_log, persist it directly
                try:
                    async with httpx.AsyncClient() as client2:
                        headers = {"X-SERVICE-KEY": STORAGE_SERVICE_KEY} if STORAGE_SERVICE_KEY else None
                        llm_log = llm_result.get("conversation_log")
                        import json as _json
                        if llm_log:
                            if isinstance(llm_log, dict):
                                payload_log = _json.dumps(llm_log)
                            else:
                                payload_log = llm_log
                            if headers:
                                await client2.put(f"{STORAGE_URL}/me/{user_id}/conversation_log", json={"log": payload_log}, headers=headers)
                            else:
                                await client2.put(f"{STORAGE_URL}/me/{user_id}/conversation_log", json={"log": payload_log})
                        else:
                            # Fallback: append current exchange to stored log
                            final_resp = llm_result.get("response") or llm_result.get("final_response") or ""
                            if headers:
                                existing = await client2.get(f"{STORAGE_URL}/me/{user_id}/conversation_log", headers=headers)
                            else:
                                existing = await client2.get(f"{STORAGE_URL}/me/{user_id}/conversation_log")
                            if existing.status_code == 200:
                                log_json = existing.json().get("log", "[]")
                            else:
                                log_json = "[]"
                            try:
                                parsed = _json.loads(log_json)
                                if isinstance(parsed, dict):
                                    recent_user = parsed.get("recent_user_prompts", []) or []
                                    recent_assistant = parsed.get("recent_assistant_responses", []) or []
                                elif isinstance(parsed, list):
                                    recent_user = [e.get("text") for e in parsed if isinstance(e, dict) and e.get("role") == "user"][-5:]
                                    recent_assistant = [e.get("text") for e in parsed if isinstance(e, dict) and e.get("role") == "assistant"][-5:]
                                else:
                                    recent_user = []
                                    recent_assistant = []
                            except Exception:
                                recent_user = []
                                recent_assistant = []
                            recent_user.append(chat_data.message)
                            recent_user = recent_user[-5:]
                            recent_assistant.append(final_resp)
                            recent_assistant = recent_assistant[-5:]
                            new_log_obj = {"recent_user_prompts": recent_user, "recent_assistant_responses": recent_assistant}
                            if headers:
                                await client2.put(f"{STORAGE_URL}/me/{user_id}/conversation_log", json={"log": _json.dumps(new_log_obj)}, headers=headers)
                            else:
                                await client2.put(f"{STORAGE_URL}/me/{user_id}/conversation_log", json={"log": _json.dumps(new_log_obj)})
                except Exception:
                    pass
            except Exception:
                pass

            # Return the LLM's final response to the Flutter app
            return llm_result
        
        except httpx.ConnectError:
            raise HTTPException(status_code=503, detail="LLM service is unavailable")
        except httpx.ReadTimeout:
            raise HTTPException(status_code=504, detail="Request to LLM service timed out")
        except httpx.HTTPStatusError as e:
            if e.response.status_code != 500:
                try:
                    return e.response.json()
                except:
                    raise HTTPException(status_code=e.response.status_code, detail=e.response.text)
            raise HTTPException(status_code=500, detail="An error occurred in the LLM service")


# ============================================================================
# Church History API Endpoints
# ============================================================================

@app.get("/history/eras")
async def get_all_eras(authorization: Optional[str] = Header(None)):
    """Get all church history eras with their events."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    if token not in tokens:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # For now, return sample data. In production, fetch from storage service.
    sample_eras = {
        "eras": [
            {
                "id": "early_church",
                "title": "Early Church Period",
                "start_year": "33 AD",
                "end_year": "325 AD",
                "description": "From Jesus's resurrection through the Council of Nicaea, establishing foundational Christian beliefs and practices.",
                "color": "#FF6B6B",
                "icon": "cross",
                "events": []
            },
            {
                "id": "medieval",
                "title": "Medieval Period",
                "start_year": "325 AD",
                "end_year": "1517 AD",
                "description": "The Middle Ages saw the development of monasticism, the split between East and West, and the building of great cathedrals.",
                "color": "#4ECDC4",
                "icon": "castle",
                "events": []
            },
            {
                "id": "reformation",
                "title": "Reformation",
                "start_year": "1517 AD",
                "end_year": "1700 AD",
                "description": "Martin Luther's reforms and the Counter-Reformation transformed Christianity and led to the emergence of Protestantism.",
                "color": "#FFE66D",
                "icon": "book",
                "events": []
            },
            {
                "id": "modern",
                "title": "Modern Era",
                "start_year": "1700 AD",
                "end_year": "Present",
                "description": "From the Enlightenment to today, Christianity has adapted to modernization, global expansion, and theological shifts.",
                "color": "#95E1D3",
                "icon": "globe",
                "events": []
            }
        ]
    }
    
    return sample_eras


@app.get("/history/eras/{era_id}")
async def get_era(era_id: str, authorization: Optional[str] = Header(None)):
    """Get a specific era with all its events."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    if token not in tokens:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Sample era data with events
    eras_data = {
        "early_church": {
            "id": "early_church",
            "title": "Early Church Period",
            "start_year": "33 AD",
            "end_year": "325 AD",
            "description": "From Jesus's resurrection through the Council of Nicaea",
            "color": "#FF6B6B",
            "icon": "cross",
            "events": [
                {
                    "id": "pentecost",
                    "title": "Day of Pentecost",
                    "year": "33 AD",
                    "location": "Jerusalem",
                    "description": "The Holy Spirit descended upon Jesus's apostles, marking the birth of the Christian church.",
                    "details": "On the Jewish feast of Pentecost, approximately 50 days after Jesus's resurrection, about 120 believers gathered in Jerusalem. The Holy Spirit came upon them with the sound of a mighty rushing wind and appeared as divided tongues of fire. Peter delivered a powerful sermon that resulted in about 3,000 people converting to Christianity.",
                    "key_figures": ["Peter", "John", "James", "Mary (Mother of Jesus)"],
                    "significance": ["Established the Christian church as a distinct faith community", "Demonstrated the power of the Holy Spirit", "Marked the beginning of Christian evangelism", "Empowered believers to spread the Gospel"],
                    "tags": ["Church Founding", "Holy Spirit", "Apostles", "Jerusalem"]
                },
                {
                    "id": "councils_nicaea",
                    "title": "Council of Nicaea",
                    "year": "325 AD",
                    "location": "Nicaea (modern-day Turkey)",
                    "description": "The first ecumenical council of the Christian church, convened to address theological disputes.",
                    "details": "Emperor Constantine I convened approximately 300 bishops from across the Roman Empire to address the Arian controversy, which questioned the divine nature of Christ. The council resulted in the Nicene Creed, which affirmed the consubstantiality (same substance) of the Father and the Son, establishing orthodox Christian doctrine.",
                    "key_figures": ["Constantine I", "Athanasius of Alexandria", "Nicholas of Myra", "Eusebius of Caesarea"],
                    "significance": ["Established the Nicene Creed as a standard of Christian orthodoxy", "Addressed major theological disputes", "Demonstrated the power of imperial authority in church matters", "Set precedent for ecumenical councils"],
                    "tags": ["Councils", "Theology", "Constantine", "Creed"]
                },
                {
                    "id": "persecution_nero",
                    "title": "Persecution Under Nero",
                    "year": "64-68 AD",
                    "location": "Rome",
                    "description": "Roman Emperor Nero blamed Christians for the great fire of Rome and persecuted them severely.",
                    "details": "After a massive fire destroyed much of Rome in 64 AD, Nero blamed the Christians and initiated severe persecution. Early Christian traditions report that both Peter and Paul were martyred during this period. Nero used Christians as scapegoats and had many crucified or burned alive, making them public spectacles.",
                    "key_figures": ["Nero", "Peter", "Paul", "Linus"],
                    "significance": ["First recorded large-scale persecution of Christians", "Demonstrated the willingness of believers to suffer for their faith", "Established the concept of Christian martyrdom", "Led to the spread of Christianity despite opposition"],
                    "tags": ["Persecution", "Martyrdom", "Rome", "Early Believers"]
                },
                {
                    "id": "epistle_paul",
                    "title": "Paul's Epistles Written",
                    "year": "50-67 AD",
                    "location": "Various locations",
                    "description": "The Apostle Paul wrote his influential letters to early Christian communities across the Mediterranean.",
                    "details": "Paul's letters, the oldest surviving Christian documents, were written to various churches and individuals between approximately 50-67 AD. His epistles address theological issues, provide pastoral guidance, and explain Christian doctrine. These letters form a significant portion of the New Testament and profoundly shaped Christian theology and practice.",
                    "key_figures": ["Paul", "Silas", "Timothy", "Titus"],
                    "significance": ["Provided theological foundation for Christian doctrine", "Addressed practical issues in early churches", "Influenced Christian ethics and community life", "Became core texts of the New Testament"],
                    "tags": ["New Testament", "Theology", "Apostolic Letters", "Paul"]
                },
                {
                    "id": "gospels_written",
                    "title": "Writing of the Four Gospels",
                    "year": "70-100 AD",
                    "location": "Various locations",
                    "description": "The four canonical gospels were written, recording Jesus's life, ministry, death, and resurrection.",
                    "details": "The gospels of Matthew, Mark, Luke, and John were written over several decades, likely between 70-100 AD. These narratives provide the primary accounts of Jesus's teachings and works. Each gospel has a distinct perspective and was written for different audiences within the early Christian communities.",
                    "key_figures": ["Matthew", "Mark", "Luke", "John"],
                    "significance": ["Preserved the teachings and life of Jesus", "Became the foundation of Christian faith and practice", "Provide different perspectives on Jesus's ministry", "Form the core of Christian scripture"],
                    "tags": ["New Testament", "Scripture", "Jesus", "Gospels"]
                }
            ]
        }
    }
    
    if era_id in eras_data:
        return {"era": eras_data[era_id]}
    else:
        raise HTTPException(status_code=404, detail="Era not found")


@app.get("/history/events/{event_id}")
async def get_event(event_id: str, authorization: Optional[str] = Header(None)):
    """Get a specific historical event."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    if token not in tokens:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    raise HTTPException(status_code=404, detail="Event not found")


@app.post("/history/events/{event_id}/viewed")
async def mark_event_viewed(event_id: str, authorization: Optional[str] = Header(None)):
    """Mark an event as viewed for learning progress tracking."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    if token not in tokens:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return {"status": "Event marked as viewed"}


@app.post("/history/events/{event_id}/bookmark")
async def bookmark_event(event_id: str, authorization: Optional[str] = Header(None)):
    """Bookmark an event for later reference."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    if token not in tokens:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return {"status": "Event bookmarked"}


@app.post("/history/events/{event_id}/unbookmark")
async def unbookmark_event(event_id: str, authorization: Optional[str] = Header(None)):
    """Remove an event from bookmarks."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    if token not in tokens:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return {"status": "Bookmark removed"}


@app.get("/history/search")
async def search_events(q: str, authorization: Optional[str] = Header(None)):
    """Search for church history events."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    try:
        token = authorization.split(" ")[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    if token not in tokens:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return {"events": []}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)