extends RefCounted
class_name TitanChat

# Client-side message model. Server must authorize channel membership and recipients.
enum Channel { WORLD, TEAM, GUILD, PRIVATE, COMBAT, SYSTEM }

const MAX_MESSAGE_LENGTH := 300
const MAX_LOCAL_HISTORY := 100
const CHANNEL_NAMES := ["world", "team", "guild", "private", "combat", "system"]

var histories: Dictionary = {}
var unread: Dictionary = {}

func _init() -> void:
	for channel in Channel.values():
		histories[channel] = []
		unread[channel] = 0

func prepare_outgoing(channel: int, message: String, recipient_id: String = "") -> Dictionary:
	if channel not in [Channel.WORLD, Channel.TEAM, Channel.GUILD, Channel.PRIVATE]:
		return {}
	var clean := message.strip_edges()
	if clean.is_empty() or clean.length() > MAX_MESSAGE_LENGTH:
		return {}
	if channel == Channel.PRIVATE and recipient_id.is_empty():
		return {}
	return {
		"channel": CHANNEL_NAMES[channel],
		"text": clean,
		"recipient_id": recipient_id if channel == Channel.PRIVATE else ""
	}

func receive_verified(channel: int, sender_id: String, sender_name: String, text: String, timestamp: int, active_channel: int) -> void:
	# Call only after a trusted server message has been validated.
	if not histories.has(channel) or text.length() > MAX_MESSAGE_LENGTH:
		return
	var messages: Array = histories[channel]
	messages.append({
		"sender_id": sender_id,
		"sender_name": sender_name,
		"text": text,
		"timestamp": timestamp
	})
	if messages.size() > MAX_LOCAL_HISTORY:
		messages.pop_front()
	if channel != active_channel:
		unread[channel] = int(unread[channel]) + 1

func open_channel(channel: int) -> Array:
	if not histories.has(channel):
		return []
	unread[channel] = 0
	return histories[channel].duplicate(true)
