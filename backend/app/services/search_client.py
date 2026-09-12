from tavily import TavilyClient
from app.config import settings

_client = TavilyClient(api_key=settings.TAVILY_API_KEY)

def search_web(query: str, max_results: int = 5) -> list[dict]:
    """
    Runs a Tavily search and returns simplified result dicts:
    {title, url, content}. Used by the search_tool_node to gather
    real-world info the itinerary node can ground its output in.
    """
    response = _client.search(query=query, max_results=max_results)
    return [
        {
            "title": r.get("title"),
            "url": r.get("url"),
            "content": r.get("content"),
        }
        for r in response.get("results", [])
    ]