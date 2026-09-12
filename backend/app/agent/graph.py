from langgraph.graph import StateGraph, END
from app.agent.state import TripState
from app.agent.nodes.classifier import classify_request_node
from app.agent.nodes.intent_parser import parse_intent_node
from app.agent.nodes.search_tool import search_tool_node
from app.agent.nodes.itinerary_synthesizer import synthesize_itinerary_node
from app.agent.nodes.refiner import refine_itinerary_node

def route_after_classification(state: TripState) -> str:
    """Conditional edge: refinement skips straight to the refiner node."""
    return "refine_itinerary" if state.get("is_refinement") else "parse_intent"

def build_graph():
    graph = StateGraph(TripState)

    graph.add_node("classify", classify_request_node)
    graph.add_node("parse_intent", parse_intent_node)
    graph.add_node("search_tool", search_tool_node)
    graph.add_node("synthesize_itinerary", synthesize_itinerary_node)
    graph.add_node("refine_itinerary", refine_itinerary_node)

    graph.set_entry_point("classify")
    graph.add_conditional_edges(
        "classify",
        route_after_classification,
        {
            "parse_intent": "parse_intent",
            "refine_itinerary": "refine_itinerary",
        },
    )

    graph.add_edge("parse_intent", "search_tool")
    graph.add_edge("search_tool", "synthesize_itinerary")
    graph.add_edge("synthesize_itinerary", END)
    graph.add_edge("refine_itinerary", END)

    return graph.compile()

trip_agent = build_graph()