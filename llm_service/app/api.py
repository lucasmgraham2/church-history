from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from .graph_church_history import app  # Import the Church History graph
from langchain_core.messages import HumanMessage

router = APIRouter()

# This model matches the payload from the API Gateway
class ChatRequest(BaseModel):
    message: str
    user_id: str
    patient_id: Optional[str] = None  # Reserved for future use
    profile: Optional[dict] = None
    memory: Optional[str] = None
    conversation_log: Optional[str] = None
    debug: Optional[bool] = False

@router.post("/invoke_agent_graph")
async def invoke_chat(request: ChatRequest):
    """
    Receives a user message and runs it through the Church History AI system.
    The system answers questions about church history in an educational way.
    """
    
    print(f"\n{'='*60}")
    print(f"📨 New Chat Request from user: {request.user_id}")
    print(f"💬 Message: {request.message}")
    print(f"{'='*60}\n")
    
    # 1. Define the initial state for the church history graph
    initial_state = {
        "messages": [HumanMessage(content=request.message)],
        "user_id": request.user_id,
        "final_response": None,
        "final_response_readme": None,
    }
    
    try:
        # 2. Invoke the compiled church history graph
        result_state = await app.ainvoke(initial_state)

        # 3. Extract the final synthesized response
        final_answer = result_state.get("final_response")
        final_answer_readme = result_state.get("final_response_readme")

        if not final_answer:
            final_answer = "I couldn't process that request. Please try rephrasing your question."
        
        print(f"\n{'='*60}")
        print(f"✅ Response generated successfully")
        print(f"📤 Sending response back to user")
        print(f"{'='*60}\n")
        
        resp = {
            "response": final_answer_readme if final_answer_readme else final_answer,
            "response_markdown": final_answer_readme,
            "response_text": final_answer,
        }
        if request.debug:
            resp["state_messages"] = [m.content for m in result_state.get("messages", [])]
        return resp
    
    except Exception as e:
        print(f"\n{'='*60}")
        print(f"❌ ERROR invoking Church History graph: {e}")
        print(f"{'='*60}\n")
        fallback = (
            "I'm having a temporary issue, but I'm still here to help! "
            "Could you please rephrase your church history question?"
        )
        return {"response": fallback}