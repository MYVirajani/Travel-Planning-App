from app.agent.state import TripState
from app.services.gemini_client import get_gemini_model, _extract_text

REFINE_PROMPT = """You are a travel planner revising an existing itinerary based on user feedback.

Existing itinerary:
{previous_itinerary}

User's requested change:
"{user_message}"

Instructions:
- Apply only the requested change; keep the rest of the itinerary intact
- Keep the same day-by-day structure and format as the original
- If the request is ambiguous, make the most reasonable interpretation
- Return the FULL updated itinerary, not just the changed part
"""

def refine_itinerary_node(state: TripState) -> TripState:
    """
    Revises the previous itinerary based on the user's follow-up
    message, without re-running search or intent parsing.
    """
    model = get_gemini_model(temperature=0.5)
    prompt = REFINE_PROMPT.format(
        previous_itinerary=state.get("previous_itinerary", ""),
        user_message=state["user_message"],
    )
    response = model.invoke(prompt)
    state["itinerary"] = _extract_text(response.content)
    return state