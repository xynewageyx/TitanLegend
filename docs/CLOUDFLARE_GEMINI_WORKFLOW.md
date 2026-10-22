# Titan Legends: GitHub + Gemini + Cloudflare

## Status (2026-10-22)
- Cloudflare connection authenticated and account accessible.
- AI Gateway listing returned an empty array. No gateway or Google AI Studio credential has been configured through this integration.
- Gemini reportedly works in OmniRoute on the user's Android device; this is a separate connection, not independently verified here.
- GitHub remains the authoritative project source: `xynewageyx/TitanLegend`.

## Architecture
Android / OmniRoute -> Gemini for code review and design feedback
GitHub -> Godot 4 source, commits, tests and pull requests
Optional Cloudflare AI Gateway -> Gemini upstream requests, once configured

## Setup checklist
1. In Cloudflare dashboard, open AI > AI Gateway and create a gateway (e.g. `titan-legends-dev`). Review any billing options before enabling paid services.
2. In Google AI Studio, obtain a Gemini API key. Do not commit it or paste it in a chat.
3. Configure Cloudflare AI Gateway provider authentication using BYOK or request headers. Store secrets in Cloudflare or Android's secure environment, not in GitHub source files.
4. Test a low-cost Gemini request through the gateway using the official provider-specific Cloudflare documentation.
5. Keep OmniRoute's existing direct Gemini provider as fallback until gateway requests have been verified.
6. Use Gemini to review a specific GitHub commit/diff, then independently review the suggestions before merging.

## Review prompts for Titan Legends
- Verify the four-hero formation and the first-come-first-served single-tank role lock.
- No automatic tank reassignment, no resurrection, no tank HP regeneration.
- Check boss target selection: taunt priority; otherwise 65% tank preference.
- Review Godot 4 syntax, exported NodePaths, signals, and scene dependencies.
- Check Android performance and memory allocation.
- Flag temporary compatibility scripts; do not treat them as original Update 168 implementations.

## Security and cost boundaries
- No API keys, account IDs, or bearer tokens should be committed to this repository.
- AI Gateway may add visibility and routing but does not automatically make Gemini free.
- Avoid provisioning paid Workers AI, storage or logging services without confirming billing.
- Keep gameplay and balance deterministic; do not require a live Gemini/Cloudflare request for each in-game battle.

Official docs:
- https://developers.cloudflare.com/ai-gateway/get-started/
- https://developers.cloudflare.com/ai-gateway/configuration/bring-your-own-keys/
