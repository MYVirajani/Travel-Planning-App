from typing import TypedDict, List, Optional

class TripState(TypedDict, total=False):
    """
    Shared state passed between LangGraph nodes.
    Every node reads from and writes back into this dict.
    """
    user_message: str         
    destination: Optional[str]
    start_date: Optional[str]
    end_date: Optional[str]
    budget: Optional[str]
    interests: List[str]
    search_results: List[dict]
    itinerary: Optional[str]
    messages: List[dict]       