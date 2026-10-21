extends Node
signal skins_changed
signal gems_changed(value: int)
var gems: int = 1500
var unlocked_skins: Array[String] = []
var equipped_skins: Array[String] = ["", "", "", ""]
# Store IDs must be registered with Google Play / App Store before enabling purchases.
const CATALOG: Dictionary = {
 "olympus_god": {"title": "Götter-Kaiser des Olymps", "premium": true, "price": "4,99 €", "product_id": "titan.olympus_god", "kind": "hero"},
 "cosmic_pet": {"title": "Kosmischer Weltenschlinger", "premium": true, "price": "2,99 €", "product_id": "titan.cosmic_pet", "kind": "pet"},
 "lucifer_blade": {"title": "Luzifers Flammenschwert", "premium": true, "price": "1,99 €", "product_id": "titan.lucifer_blade", "kind": "weapon"},
 "shadow_ninja": {"title": "Schatten-Ninja", "premium": false, "cost": 800, "min_r": 0, "kind": "hero"},
 "light_paladin": {"title": "Lichtbringer-Ritter", "premium": false, "cost": 1200, "min_r": 2, "kind": "hero"}
}
func add_gems(amount: int) -> void:
 gems = maxi(0, gems + amount)
 gems_changed.emit(gems)
 SaveManager.save_game()
func buy_with_gems(skin_id: String) -> bool:
 if not CATALOG.has(skin_id) or unlocked_skins.has(skin_id):
  return false
 var item: Dictionary = CATALOG[skin_id]
 if bool(item.get("premium", false)) or GameManager.current_reincarnation_level < int(item.get("min_r", 0)):
  return false
 var cost: int = int(item.get("cost", 0))
 if gems < cost:
  return false
 gems -= cost
 _unlock(skin_id)
 gems_changed.emit(gems)
 return true
func request_real_money_purchase(skin_id: String) -> bool:
 # No billing plugin configured. Never unlock on a button press.
 if not CATALOG.has(skin_id) or not bool(CATALOG[skin_id].get("premium", false)):
  return false
 push_warning("Store-Billing noch nicht eingerichtet: " + skin_id)
 return false
func grant_verified_purchase(skin_id: String, verified_by_store: bool) -> bool:
 # Call only after verified store purchase/restore. For production, verify receipts server-side.
 if not verified_by_store or not CATALOG.has(skin_id) or not bool(CATALOG[skin_id].get("premium", false)):
  return false
 _unlock(skin_id)
 return true
func _unlock(skin_id: String) -> void:
 if not unlocked_skins.has(skin_id):
  unlocked_skins.append(skin_id)
 skins_changed.emit()
 SaveManager.save_game()
func equip(skin_id: String, hero_slot: int) -> bool:
 if hero_slot < 0 or hero_slot >= 4:
  return false
 if skin_id != "" and (not unlocked_skins.has(skin_id) or str(CATALOG[skin_id].get("kind", "")) != "hero"):
  return false
 equipped_skins[hero_slot] = skin_id
 skins_changed.emit()
 SaveManager.save_game()
 return true
func restore_state(data: Dictionary) -> void:
 gems = maxi(0, int(data.get("gems", 1500)))
 unlocked_skins.clear()
 var saved: Variant = data.get("unlocked_skins", [])
 if saved is Array:
  for key in saved:
   if CATALOG.has(str(key)) and not unlocked_skins.has(str(key)):
    unlocked_skins.append(str(key))
 equipped_skins = ["", "", "", ""]
 var equipped: Variant = data.get("equipped_skins", [])
 if equipped is Array:
  for i in range(mini(4, equipped.size())):
   var key: String = str(equipped[i])
   if unlocked_skins.has(key) and str(CATALOG[key].get("kind", "")) == "hero":
    equipped_skins[i] = key
 gems_changed.emit(gems)
 skins_changed.emit()
