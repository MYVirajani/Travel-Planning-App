import json
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from app.agent.graph import trip_agent

router = APIRouter()

NODE_LABELS = {
    "parse_intent": "Understanding your request",
    "search_tool": "Researching destination",
    "synthesize_itinerary": "Building your itinerary",
}

def _sse_event(event_type: str, data: dict) -> str:
    """
    Formats a single SSE message. Each message is:
    event: <type>
    data: <json>
    followed by a blank line, per the SSE spec.
    """
    return f"event: {event_type}\ndata: {json.dumps(data)}\n\n"

async def stream_trip_plan(user_message: str):
    """
    Streams graph progress as SSE events:
    - 'progress' after each node, with a human-readable label
    - 'result' once the final node (synthesize_itinerary) completes
    - 'error' if anything raises
    """
    try:
        final_state = {}
        for chunk in trip_agent.stream({"user_message": user_message}):
            
            for node_name, node_state in chunk.items():
                final_state.update(node_state)
                label = NODE_LABELS.get(node_name, node_name)
                yield _sse_event("progress", {"step": node_name, "label": label})

        yield _sse_event("result", {
            "destination": final_state.get("destination"),
            "start_date": final_state.get("start_date"),
            "end_date": final_state.get("end_date"),
            "budget": final_state.get("budget"),
            "interests": final_state.get("interests"),
            "itinerary": final_state.get("itinerary"),
        })

    except Exception as e:
        yield _sse_event("error", {"message": str(e)})

@router.post("/plan-trip")
async def plan_trip(payload: dict):
    user_message = payload.get("message", "")
    return StreamingResponse(
        stream_trip_plan(user_message),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",  
        },
    )