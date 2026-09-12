from langgraph.graph import StateGraph, END
from app.agent.state import TripState
from app.agent.nodes.intent_parser import parse_intent_node
from app.agent.nodes.search_tool import search_tool_node
from app.agent.nodes.itinerary_synthesizer import synthesize_itinerary_node

def build_graph():
    graph = StateGraph(TripState)
    graph.add_node("parse_intent", parse_intent_node)
    graph.add_node("search_tool", search_tool_node)
    graph.add_node("synthesize_itinerary", synthesize_itinerary_node)

    graph.set_entry_point("parse_intent")
    graph.add_edge("parse_intent", "search_tool")
    graph.add_edge("search_tool", "synthesize_itinerary")
    graph.add_edge("synthesize_itinerary", END)

    return graph.compile()

trip_agent = build_graph()