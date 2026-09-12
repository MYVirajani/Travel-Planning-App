from app.agent.state import TripState
from app.services.gemini_client import get_gemini_model

ITINERARY_PROMPT = """You are an expert travel planner. Create a detailed day-by-day itinerary using the trip details and research below.

Trip details:
- Destination: {destination}
- Dates: {start_date} to {end_date}
- Budget: {budget}
- Interests: {interests}

Research notes (use these for real places, names, and practical details — don't invent facts that contradict them):
{research}

Instructions:
- Structure the response as "Day 1", "Day 2", etc.
- For each day, suggest morning/afternoon/evening activities
- Reference specific places from the research notes where relevant
- Keep it concise but concrete — actual place names, not generic suggestions
- If budget was given, keep suggestions roughly within it
"""

def _format_research(search_results: list[dict]) -> str:
    if not search_results:
        return "No research available — use general knowledge."
    lines = []
    for r in search_results:
        lines.append(f"- {r.get('title')}: {r.get('content', '')[:300]}")
    return "\n".join(lines)

def synthesize_itinerary_node(state: TripState) -> TripState:
    """
    Final synthesis step: combines structured intent + search results
    into a concrete day-by-day itinerary via Gemini.
    """
    model = get_gemini_model(temperature=0.5)

    prompt = ITINERARY_PROMPT.format(
        destination=state.get("destination") or "unspecified",
        start_date=state.get("start_date") or "unspecified",
        end_date=state.get("end_date") or "unspecified",
        budget=state.get("budget") or "no budget specified",
        interests=", ".join(state.get("interests") or []) or "general sightseeing",
        research=_format_research(state.get("search_results") or []),
    )

    response = model.invoke(prompt)
    from app.services.gemini_client import _extract_text
    state["itinerary"] = _extract_text(response.content)
    return state