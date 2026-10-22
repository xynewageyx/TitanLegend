#!/usr/bin/env python3
"""Read-only smoke test for Titan Legends' Cloudflare -> Google AI Studio route.

Runs only when GEMINI_API_KEY is explicitly supplied in the environment.
No dependencies beyond the Python standard library; never prints the key.
No repository writes, AI Gateway settings changes, or Godot modifications.
"""
import json
import os
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ACCOUNT = "aad0481ecb7bf257b6bdefc1276da551"
GATEWAY = "titan-legends-gemini"
DEFAULT_MODEL = "gemini-2.5-flash"
PROMPT = "Antworte ausschließlich mit TITAN_OK."
ENDPOINT = (
    f"https://gateway.ai.cloudflare.com/v1/{ACCOUNT}/{GATEWAY}"
    "/google-ai-studio/v1/models/{model}:generateContent"
)


def main() -> int:
    key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not key:
        print("SKIPPED: GEMINI_API_KEY fehlt. Schlüssel nur lokal setzen, nicht committen.")
        return 2

    model = os.environ.get("GEMINI_MODEL", DEFAULT_MODEL)
    if not model.replace("-", "").replace(".", "").isalnum():
        print("ERROR: Ungültiger GEMINI_MODEL-Name")
        return 1

    url = ENDPOINT.format(model=model)
    payload = json.dumps(
        {"contents": [{"role": "user", "parts": [{"text": PROMPT}]}]}
    ).encode("utf-8")
    request = Request(
        url,
        data=payload,
        headers={"Content-Type": "application/json", "x-goog-api-key": key},
        method="POST",
    )
    try:
        with urlopen(request, timeout=20) as response:
            body = json.load(response)
            status = response.status
    except HTTPError as exc:
        print(f"FAIL: Cloudflare/Gemini HTTP {exc.code}.")
        if exc.code in (401, 403):
            print("Prüfe Google AI Studio API-Key und Gateway-Zugriffsrechte.")
        elif exc.code == 429:
            print("Rate-Limit oder Provider-Quota erreicht.")
        return 1
    except (URLError, TimeoutError, json.JSONDecodeError) as exc:
        print(f"FAIL: Netzwerk-, Timeout- oder JSON-Fehler: {type(exc).__name__}")
        return 1

    parts = (
        body.get("candidates", [{}])[0].get("content", {}).get("parts", [])
        if body.get("candidates") else []
    )
    answer = " ".join(str(p.get("text", "")) for p in parts)
    if status == 200 and "TITAN_OK" in answer:
        print(f"PASS: Cloudflare Gateway -> Gemini {model} antwortet mit TITAN_OK.")
        return 0

    print("FAIL: HTTP 200, aber erwartete Gemini-Antwort fehlt.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
