"""
Church History AI Assistant
A simplified LLM system for answering church history questions
"""

import os
from typing import TypedDict, List, Optional
from langchain_core.messages import BaseMessage, HumanMessage, AIMessage, SystemMessage
from langchain_ollama import ChatOllama
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langgraph.graph import StateGraph, END
import json

# Use a local model via Ollama
# If Ollama is not available, this will fail gracefully
try:
    llm = ChatOllama(model="gemma3:1b", temperature=0.3)
except Exception:
    # Fallback to a simpler configuration if Ollama fails
    llm = None

# ==========================================
# STATE DEFINITION
# ==========================================

class ChurchHistoryState(TypedDict):
    """State for the church history assistant"""
    messages: List[BaseMessage]
    user_id: str
    final_response: Optional[str]
    final_response_readme: Optional[str]

# ==========================================
# CHURCH HISTORY SYSTEM PROMPT
# ==========================================

CHURCH_HISTORY_SYSTEM_PROMPT = """You are an expert Church History Assistant designed to help people learn about church history in an engaging and educational way.

Your expertise covers:
- Early Christian Church (33 AD - 325 AD)
- Medieval Period (325 AD - 1517 AD)
- Reformation Era (1517 AD - 1700 AD)
- Modern Era (1700 AD - Present)

IMPORTANT - Response Style:
- Keep responses CONCISE and to the point (2-4 paragraphs maximum unless user asks for detailed explanation)
- Only provide long, detailed explanations when the user specifically asks for more detail or depth
- Be direct and clear - avoid unnecessary elaboration
- Maintain conversation context from previous messages
- When user asks "tell me more" or similar, then expand with additional detail

When answering questions:
1. Start with the most important information first
2. Provide historically accurate information backed by scholarly consensus
3. Explain complex concepts in simple, clear terms
4. Mention key figures and their contributions when directly relevant
5. Use bullet points for lists (keep them short - 3-5 items max)
6. If you don't know something, say so honestly
7. Only ask follow-up questions occasionally, not in every response

Format your responses with:
- Clear, concise paragraphs
- Bold text for important terms and names
- Short lists when appropriate
- Minimal markdown formatting (only when it adds clarity)

Remember: Be helpful and informative, but CONCISE. Users can always ask for more detail if they want it."""


# ==========================================
# CHURCH HISTORY AGENT
# ==========================================

async def church_history_agent(state: ChurchHistoryState) -> dict:
    """Main agent that processes questions about church history."""
    
    messages = state.get("messages", [])
    
    # Debug: Log conversation history
    print(f"\n{'='*60}")
    print(f"🤖 Processing {len(messages)} messages in conversation history:")
    for i, msg in enumerate(messages):
        msg_type = "User" if isinstance(msg, HumanMessage) else "AI"
        content_preview = msg.content[:100] + "..." if len(msg.content) > 100 else msg.content
        print(f"  {i+1}. [{msg_type}]: {content_preview}")
    print(f"{'='*60}\n")
    
    # Create the prompt with system message and user messages
    prompt = ChatPromptTemplate.from_messages([
        SystemMessage(content=CHURCH_HISTORY_SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="messages"),
    ])
    
    # Format the prompt
    formatted_prompt = prompt.format_messages(messages=messages)
    
    try:
        if llm is None:
            # Fallback response if LLM is not available
            response_text = """I appreciate your question about church history! However, I'm currently running in offline mode without access to my full AI capabilities.

To give you the best answer, I recommend:
1. Checking reliable church history sources like academic articles or books
2. Visiting websites like Christianity.com or church-history databases
3. Asking me again once the service is fully restored

Feel free to ask any other questions about church history, and I'll do my best to help!"""
            response_markdown = response_text
        else:
            # Get response from LLM
            response = await llm.ainvoke(formatted_prompt)
            response_text = response.content
            response_markdown = response.content
        
        return {
            "final_response": response_text,
            "final_response_readme": response_markdown,
        }
    
    except Exception as e:
        error_response = f"""I encountered an issue processing your question: {str(e)}

Please try again with a simpler question or check if the service is running properly."""
        return {
            "final_response": error_response,
            "final_response_readme": error_response,
        }


# ==========================================
# BUILD THE GRAPH
# ==========================================

workflow = StateGraph(ChurchHistoryState)

# Add the church history agent as the sole node
workflow.add_node("church_history", church_history_agent)

# Set entry point
workflow.set_entry_point("church_history")

# Set exit point
workflow.add_edge("church_history", END)

# Compile the graph
app = workflow.compile()
