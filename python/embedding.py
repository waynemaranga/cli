"""## `embedding.py`
API Ref: https://ai.google.dev/api/rest/v1beta/Embedding
Dart: https://ai.google.dev/gemini-api/docs/get-started/dart#embeddings
Python: https://ai.google.dev/gemini-api/docs/get-started/python#use_embeddings
"""

import os
import google.generativeai as genai
import json
from dotenv import load_dotenv
from luaparser import ( ast, builder )  # Lua parsing library (install: pip install luaparser) # fmt: skip
import google.ai.generativelanguage as glm

load_dotenv()

GOOGLE_API_KEY: str | None = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=os.getenv(GOOGLE_API_KEY))  # PylancereportArgumentType
EMBEDDING_MODEL: str = "embedding-gecko-001"


def create_embeddings(text_list, model_name=f"models/{EMBEDDING_MODEL}"):
    # PylintW0621:redefined-outer-name (error for text_list arg)
    # Deprecated: # // embeddings = genai.Embeddings(model_name)
    # embedding = genai.embed_content() # Option 1.
    # embedding = genai.embed_content_async  # Option 2.
    # embedding = genai.generate_embeddings() # Option 3.

    embedding = genai.embed_content(
        model=model_name,
        content=[
            "Who are the Beastie Boys?",
            "Fool me once, shame on you",
            "Nobody knows what it means, but it's provocative",
            "How old was Genghis Khan when he was born?",
        ],
        task_type="retrieval_document",
        title="Embedding of list of strings",
    )

    return embedding.batch_embed(text_list)


def process_text_with_lua(text, lua_script):
    """Processes text using a Lua script."""
    tree = ast.parse(lua_script)  # tree is type Chunk probably
    lua_globals = {
        "text": text,
        "string": {
            "lower": lambda s: s.lower(),
            "upper": lambda s: s.upper(),
            # ... other string functions you might need
        },
    }
    # result = tree.execute(lua_globals)
    result = tree  #! FIXME
    return result


if __name__ == "__main__":
    text_list = ["This is a sample sentence.", "Another sentence for embedding."]
    embeddings = create_embeddings(text_list)

    # Example Lua script for basic text processing
    LUA_SCRIPT = """
    return string.upper(text)
    """

    for text, embedding in zip(text_list, embeddings):
        processed_text = process_text_with_lua(text, LUA_SCRIPT)
        print(
            f"Original Text: '{text}', Processed Text: '{processed_text}', Embedding: {embedding}"
        )
