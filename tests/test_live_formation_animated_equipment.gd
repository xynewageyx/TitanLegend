extends SceneTree
## Runtime integration test for the ACTUAL four-hero Titan Legends team.
## All changes are visual; no battle damage, inventory or persistent data are altered.
const FORMATION = preload("res://scripts/team_formation.gd")
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")

func _initialize() -> void:
 call_deferred("_run")

func _fail(reason: String) -> void:
 push_error(reason)
 quit(1)

func _run() -> void:
 var team := Node3D.new()
 team.name = "LiveTeamSmoke"
 team.set_script(FORMATION)
 root.add_child(team)
 await process_frame
 if team.heroes.size() != 4:
  _fail("Live team did not spawn four heroes")
  return
 var checked_sockets := 0
 for index in range(4):
  var hero: Node3D = team.heroes[index]
  var bridge: Node3D = hero.get_node_or_null("LiveFormationRig") as Node3D
  var skeleton: Skeleton3D = hero.get_node_or_null("LiveFormationRig/Skeleton3D") as Skeleton3D
  var animator: AnimationPlayer = hero.get_node_or_null("LiveFormationRig/Skeleton3D/TitanAnimations") as AnimationPlayer
  var controller: Node3D = hero.get_node_or_null("EquipmentController") as Node3D
  if bridge == null or skeleton == null or animator == null or controller == null:
   _fail("Missing live rig/controller for hero %d" % index)
   return
  if skeleton.get_bone_count() != 18:
   _fail("Incorrect live rig bone count for hero %d" % index)
   return
  for socket_name in ADAPTER.SOCKETS:
   var bone_socket := skeleton.get_node_or_null(NodePath(socket_name)) as BoneAttachment3D
   if bone_socket == null or controller.call("_socket", socket_name) != bone_socket:
    _fail("Equipment controller failed to select animated bone socket: %s" % socket_name)
    return
   checked_sockets += 1
  if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(int(team.class_ids[index])), 5)):
   _fail("Cannot equip live formation weapon")
   return
  if not bool(controller.call("equip_armor_slot", "ChestSocket", int(team.class_ids[index]), 5)):
   _fail("Cannot equip live formation chestplate")
   return
  await process_frame
  if skeleton.get_node("RightHandSocket").get_child_count() != 1:
   _fail("Weapon missing from live bone")
   return
  if skeleton.get_node("ChestSocket").get_child_count() != 1:
   _fail("Armor missing from live chest")
   return
 var attacker: Node3D = team.heroes[0]
 var anim: AnimationPlayer = attacker.get_node("LiveFormationRig/Skeleton3D/TitanAnimations") as AnimationPlayer
 var rig: Skeleton3D = attacker.get_node("LiveFormationRig/Skeleton3D") as Skeleton3D
 var weapon: Node3D = rig.get_node("RightHandSocket").get_child(0) as Node3D
 var chest: Node3D = rig.get_node("ChestSocket").get_child(0) as Node3D
 team.play_attack_for_hero(0)
 if anim.current_animation != "titan/attack":
  _fail("Attack event did not start bone animation")
  return
 anim.seek(0.0, true)
 rig.force_update_all_bone_transforms()
 await process_frame
 var weapon_before: Basis = weapon.global_transform.basis
 var chest_before: Basis = chest.global_transform.basis
 anim.seek(0.30, true)
 rig.force_update_all_bone_transforms()
 await process_frame
 if weapon_before.is_equal_approx(weapon.global_transform.basis):
  _fail("Live weapon did not rotate with attack bone")
  return
 if chest_before.is_equal_approx(chest.global_transform.basis):
  _fail("Live armor did not move with torso bone")
  return
 var victim: Node3D = team.heroes[1]
 team.play_hit_targets([1])
 var hit_anim: AnimationPlayer = victim.get_node("LiveFormationRig/Skeleton3D/TitanAnimations") as AnimationPlayer
 if hit_anim.current_animation != "titan/hit":
  _fail("Targeted hit did not reach the correct hero")
  return
 team.play_hero_defeat(2)
 if not bool(team.heroes[2].get_node("LiveFormationRig").get("defeated")):
  _fail("Defeated hero was not marked in cosmetic rig")
  return
 team.reset_individual_defeat_poses()
 if bool(team.heroes[2].get_node("LiveFormationRig").get("defeated")):
  _fail("Rig was not restored for next encounter")
  return
 team.stop_walking()
 team.start_walking()
 for hero in team.heroes:
  var player: AnimationPlayer = hero.get_node("LiveFormationRig/Skeleton3D/TitanAnimations") as AnimationPlayer
  if player.current_animation != "titan/run":
   _fail("Hero did not start run motion")
   return
 team.stop_walking()
 for hero in team.heroes:
  var player: AnimationPlayer = hero.get_node("LiveFormationRig/Skeleton3D/TitanAnimations") as AnimationPlayer
  if player.current_animation != "titan/idle":
   _fail("Hero did not restore idle motion")
   return
 print("LIVE_FORMATION_ANIMATED_EQUIPMENT_OK heroes=4 bone_sockets=%d" % checked_sockets)
 team.queue_free()
 await process_frame
 quit(0)
