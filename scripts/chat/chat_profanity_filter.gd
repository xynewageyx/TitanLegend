extends RefCounted
class_name ChatProfanityFilter

# Client-side preview only. The multiplayer server MUST enforce its own filter.
# Keep word lists configurable to avoid false positives and support localization.
const DEFAULT_TERMS := [
	"arschloch", "scheisse", "scheiße", "wichser", "hurensohn",
	"fuck", "fucker", "motherfucker", "shit", "asshole", "bitch"
]
const LEET := {"0":"o", "1":"i", "3":"e", "4":"a", "5":"s", "7":"t", "@":"a", "$":"s"}
var terms: Array[String] = []

func _init(custom_terms: Array[String] = []) -> void:
	for term in (custom_terms if not custom_terms.is_empty() else DEFAULT_TERMS):
		var normalized := _normalize(term)
		if not normalized.is_empty() and not terms.has(normalized):
			terms.append(normalized)

func _normalize(value: String) -> String:
	var normalized := value.to_lower().replace("ß", "ss")
	for symbol in LEET:
		normalized = normalized.replace(symbol, LEET[symbol])
	return normalized

func contains_profanity(message: String) -> bool:
	var normalized := _normalize(message)
	var tokens := normalized.split(" ", false)
	for token in tokens:
		var stripped := ""
		for i in range(token.length()):
			var c := token.substr(i, 1)
			if (c >= "a" and c <= "z") or c in ["ä", "ö", "ü"]:
				stripped += c
		if terms.has(stripped):
			return true
	return false

func check_message(message: String) -> Dictionary:
	var flagged := contains_profanity(message)
	return {
		"allowed": not flagged,
		"reason": "profanity" if flagged else "",
		"text": message if not flagged else ""
	}
