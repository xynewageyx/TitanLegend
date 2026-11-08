extends SceneTree
## Runtime integration test for the ACTUAL four-hero Titan Legends team.
## All changes are visual; no battle damage, inventory or persistent data are altered.
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")

func _initialize() -> void:
 call_deferred("_run")

func _fail(reason: String) -> void:
 push_error(reason)
 quit(1)

func _run() -> void:
 # Load the formation only after the SceneTree/autoload initialization.
 var formation_script: Script = load("res://scripts/team_formation.gd")
 if formation_script == null:
  _fail("Formation script could not be loaded after autoload setup")
  return
 var team: Variant = formation_script.new()
 if not (team is Node3D):
  _fail("Formation script did not instantiate a Node3D")
  return
 team.name = "LiveTeamSmoke"
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
  var imported_view: Node3D = hero.get_node_or_null("ChibiGLBVisual") as Node3D
  var imported_skeleton: Skeleton3D = imported_view.get("imported_skeleton") as Skeleton3D if imported_view != null else null
  if imported_skeleton == null or not bool(imported_view.get_meta("imported_equipment_sockets_ready", false)):
   _fail("Imported GLB skeleton did not provide equipment anchors for hero %d" % index)
   return
  for socket_name in ADAPTER.SOCKETS:
   var glb_socket := imported_skeleton.get_node_or_null(NodePath(socket_name + "/EquipmentAnchor")) as Node3D
   if glb_socket == null or controller.call("_socket", socket_name) != glb_socket:
    _fail("Equipment controller failed to select imported GLB bone socket: %s" % socket_name)
    return
   checked_sockets += 1
  if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(int(team.class_ids[index])), 5)):
   _fail("Cannot equip live formation weapon")
   return
  if not bool(controller.call("equip_armor_slot", "ChestSocket", int(team.class_ids[index]), 5)):
   _fail("Cannot equip live formation chestplate")
   return
  await process_frame
  var weapon_anchor: Node3D = controller.call("_socket", "RightHandSocket") as Node3D
  var chest_anchor: Node3D = controller.call("_socket", "ChestSocket") as Node3D
  if weapon_anchor == null or weapon_anchor.get_child_count() != 1:
   _fail("Weapon missing from imported GLB bone")
   return
  if chest_anchor == null or chest_anchor.get_child_count() != 1:
   _fail("Armor missing from imported GLB chest")
   return
  # The old in-arm weapon AND the static class-role prop must be hidden,
  # otherwise two weapons remain rendered on the same live combat hero.
  var legacy_arm := hero.get_node_or_null("HeroCombatMotion/AnimatedRightArm/LegacyWeaponVisual") as Node3D
  var legacy_role := hero.get_node_or_null("LegacyRoleWeapon") as Node3D
  if legacy_arm == null or legacy_role == null:
   _fail("Older weapon fallback groups were not created for hero %d" % index)
   return
  if legacy_arm.visible or legacy_role.visible:
   _fail("Duplicated old weapon still visible after bone equipping: hero %d" % index)
   return
  # Removal restores the older fallback without removing the hero's armor.
  controller.call("unequip", "mainhand")
  await process_frame
  if not legacy_arm.visible or not legacy_role.visible:
   _fail("Older weapon fallback did not return on unequip: hero %d" % index)
   return
  if weapon_anchor.get_child_count() != 0:
   _fail("Bone weapon was not removed on unequip: hero %d" % index)
   return
  if chest_anchor.get_child_count() != 1:
   _fail("Unequipping weapon removed unrelated chest armor: hero %d" % index)
   return
  if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(int(team.class_ids[index])), 4)):
   _fail("Could not re-equip bone weapon for hero %d" % index)
   return
  await process_frame
  if legacy_arm.visible or legacy_role.visible:
   _fail("Legacy weapon reappeared after re-equip: hero %d" % index)
   return
  if weapon_anchor.get_child_count() != 1:
   _fail("Re-equipping left a duplicate or missing bone weapon: hero %d" % index)
   return
 var attacker: Node3D = team.heroes[0]
 var anim: AnimationPlayer = attacker.get_node("LiveFormationRig/Skeleton3D/TitanAnimations") as AnimationPlayer
 var chibi: Node3D = attacker.get_node("ChibiGLBVisual") as Node3D
 var rig: Skeleton3D = chibi.get("imported_skeleton") as Skeleton3D
 var glb_player: AnimationPlayer = chibi.get("animation_player") as AnimationPlayer
 if rig == null or glb_player == null or not glb_player.has_animation("Attack"):
  _fail("Missing imported warrior GLB animation")
  return
 var controller: Node3D = attacker.get_node("EquipmentController") as Node3D
 var active_weapon: Node3D = controller.call("_socket", "RightHandSocket") as Node3D
 var active_chest: Node3D = controller.call("_socket", "ChestSocket") as Node3D
 var weapon: Node3D = active_weapon.get_child(0) as Node3D
 var chest: Node3D = active_chest.get_child(0) as Node3D
 team.play_attack_for_hero(0)
 if anim.current_animation != "titan/attack":
  _fail("Attack event did not start bone animation")
  return
 var attack: Animation = glb_player.get_animation("Attack")
 var motion_start: float = maxf(0.0, attack.length - 0.95)
 var motion_peak: float = maxf(motion_start, attack.length - 0.35)
 glb_player.play("Attack")
 glb_player.seek(motion_start, true)
 rig.force_update_all_bone_transforms()
 await process_frame
 var weapon_before: Basis = weapon.global_transform.basis
 var chest_before: Basis = chest.global_transform.basis
 glb_player.seek(motion_peak, true)
 rig.force_update_all_bone_transforms()
 await process_frame
 if weapon_before.is_equal_approx(weapon.global_transform.basis):
  _fail("Live weapon did not rotate with attack bone")
  return
 if chest_before.is_equal_approx(chest.global_transform.basis):
  _fail("Live armor did not move with torso bone")
  return
 # Real skill cast visual now drives a separate bone animation without changing damage.
 var combat_motion: Node3D = attacker.get_node("HeroCombatMotion") as Node3D
 combat_motion.call("play_skill_cast", 1, 0)
 if anim.current_animation != "titan/cast":
  _fail("Skill cast visual did not start the skeletal cast animation")
  return
 var victim: Node3D = team.heroes[1]
 var hit_targets: Array[int] = [1]
 team.play_hit_targets(hit_targets)
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
 # Class-specific imported NLA suffixes must be selected automatically,
 # otherwise mage/paladin/etc can accidentally play a previous class's clip.
 team.play_attack_for_hero(1) # Default team second hero = mage, class 6.
 await process_frame
 var mage_view: Node3D = team.heroes[1].get_node("ChibiGLBVisual") as Node3D
 var mage_anim: AnimationPlayer = mage_view.get("animation_player") as AnimationPlayer
 if mage_anim == null or mage_anim.current_animation != "Attack_006":
  _fail("Mage did not select its own imported Attack_006 clip")
  return
 if mage_anim.current_animation_position < mage_anim.get_animation("Attack_006").length - 1.10:
  _fail("Mage attack clip did not skip Blender's inactive lead-in")
  return
 # Death Knight has 24 bones and its moving weapon bone is Hand_R_2.
 # Rebuild only this CI scene; the user save and combat stats remain untouched.
 team.class_ids[0] = 11
 team.create_team()
 await process_frame
 var dk: Node3D = team.heroes[0]
 var dk_view: Node3D = dk.get_node("ChibiGLBVisual") as Node3D
 var dk_skeleton: Skeleton3D = dk_view.get("imported_skeleton") as Skeleton3D
 var dk_controller: Node3D = dk.get_node("EquipmentController") as Node3D
 if dk_skeleton == null or dk_skeleton.get_bone_count() != 24:
  _fail("Death Knight missing the extended 24-bone original GLB rig")
  return
 var dk_attachment: BoneAttachment3D = dk_skeleton.get_node_or_null("RightHandSocket") as BoneAttachment3D
 if dk_attachment == null or dk_attachment.bone_name != "Hand_R_2":
  _fail("Death Knight weapon was not bound to the animated Hand_R_2 bone")
  return
 if not bool(dk_controller.call("equip_weapon", 1, 5)):
  _fail("Death Knight could not equip a high-rarity greatsword")
  return
 var dk_weapon_root: Node3D = dk_controller.call("_socket", "RightHandSocket") as Node3D
 await process_frame
 if dk_weapon_root == null or dk_weapon_root.get_child_count() != 1:
  _fail("Death Knight's imported socket lost its equipped weapon")
  return
 var dk_weapon: Node3D = dk_weapon_root.get_child(0) as Node3D
 var dk_player: AnimationPlayer = dk_view.get("animation_player") as AnimationPlayer
 var dk_clip: Animation = dk_player.get_animation("Attack")
 var dk_start: float = maxf(0.0, dk_clip.length - 0.95)
 team.play_attack_for_hero(0)
 dk_player.play("Attack")
 dk_player.seek(dk_start, true)
 dk_skeleton.force_update_all_bone_transforms()
 await process_frame
 var dk_before: Basis = dk_weapon.global_transform.basis
 dk_player.seek(maxf(dk_start, dk_clip.length - 0.35), true)
 dk_skeleton.force_update_all_bone_transforms()
 await process_frame
 if dk_before.is_equal_approx(dk_weapon.global_transform.basis):
  _fail("Death Knight's imported 24-bone greatsword did not follow attack")
  return
 print("LIVE_DEATH_KNIGHT_24BONE_OK weapon_bone=Hand_R_2")
 print("LIVE_FORMATION_ANIMATED_EQUIPMENT_OK heroes=4 bone_sockets=%d imported_sockets=4" % checked_sockets)
 team.queue_free()
 await process_frame
 quit(0)
