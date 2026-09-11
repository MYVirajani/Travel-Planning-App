from langchain_google_genai import ChatGoogleGenerativeAI
from app.config import settings
import json
import re

def get_gemini_model(temperature: float = 0.4):
    """
    Returns a configured Gemini chat model instance.
    Centralizing this means every LangGraph node uses the same setup.
    """
    return ChatGoogleGenerativeAI(
        model="gemini-3.6-flash",
        google_api_key=settings.GOOGLE_API_KEY,
        temperature=temperature,
    )

def _extract_text(content) -> str:
    """
    Gemini responses can come back as a plain string or as a list of
    content blocks (e.g. [{"type": "text", "text": "..."}]) depending
    on model version. Normalize to a single string either way.
    """
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, str):
                parts.append(block)
            elif isinstance(block, dict) and "text" in block:
                parts.append(block["text"])
        return "".join(parts)
    return str(content)

def parse_json_response(content) -> dict:
    """
    Strips markdown code fences if present and parses JSON safely.
    Accepts either a string or Gemini's list-of-blocks content format.
    """
    text = _extract_text(content)
    cleaned = re.sub(r"^```json\s*|\s*```$", "", text.strip(), flags=re.MULTILINE)
    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        return {}