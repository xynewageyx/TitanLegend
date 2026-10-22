# Titan Legends – Gemini AI Studio über Cloudflare AI Gateway

Stand: 2026-10-22

## Aufbau

- **Quellcode:** GitHub `xynewageyx/TitanLegend`
- **KI für Code-Reviews und Tests:** Google Gemini über Google AI Studio
- **API-Routing:** Cloudflare AI Gateway `titan-legends-gemini`
- **Android:** OmniRoute kann Gemini unabhängig direkt erreichen; Gateway-Routing erst nach Prüfung der Base-URL-Unterstützung.
- **Godot:** Godot 4.x läuft lokal; Cloudflare ist **keine** Godot-Runtime.

Cloudflare Account: `aad0481ecb7bf257b6bdefc1276da551`
Gateway ID: `titan-legends-gemini`
BYOK-only: aktiviert. Gateway-Prompt-Logging: deaktiviert.

## Google AI Studio API-Schlüssel sicher konfigurieren

Den Gemini-API-Key unter https://aistudio.google.com/api-keys erstellen bzw. prüfen.
**Niemals einen API-Key oder ein Cloudflare-Token in GitHub committen.**

In Android/Termux:

```sh
export GEMINI_API_KEY='HIER_NUR_LOKAL_EINSETZEN'
```

## Cloudflare-Gateway per API testen

Beispiel mit dem provider-nativen Google-AI-Studio-Endpunkt, angelehnt an:
https://developers.cloudflare.com/ai-gateway/usage/providers/google-ai-studio/

```sh
curl -fsS \
  'https://gateway.ai.cloudflare.com/v1/aad0481ecb7bf257b6bdefc1276da551/titan-legends-gemini/google-ai-studio/v1/models/gemini-2.5-flash:generateContent' \
  -H 'Content-Type: application/json' \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  --data '{
    "contents": [{
      "role": "user",
      "parts": [{
        "text": "Prüfe das Godot-4-Projekt Titan Legends. Regel: maximal ein aktiver Tank pro Team; niemals automatische Rollenverdrängung. Antworte mit OK."
      }]
    }]
  }'
```

Das Gateway wurde erstellt; der Test wurde **noch nicht** mit einem gültigen Gemini-Key durchgeführt.

## Arbeitsweise

1. ChatGPT prüft und verändert den Quellcode über den GitHub-Connector.
2. Gemini AI Studio wird für einen zweiten Code-Review und Fehleranalyse genutzt, sobald der API-Schlüssel lokal/einem Secret Store bereitsteht.
3. Cloudflare routet Gemini-Anfragen; kein API-Schlüssel wird dem Repository hinzugefügt.
4. Godot-Tests und Android-Builds laufen unabhängig von der Cloudflare-KI-Infrastruktur.
5. Keine automatisch freigegebenen PRs und keine ZIP-Artefakte.

## Offene Prüfung

- Google AI Studio Key mit Gateway-Endpunkt erfolgreich aufrufen.
- Nachweisen, dass OmniRoute die Google-API-Base-URL anpassen kann.
- CI-Validierung mit realem Godot-4-Lauf vor einer produktiven Veröffentlichung.
