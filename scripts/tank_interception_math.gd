extends RefCounted
class_name TitanTankInterceptionMath

# Transfer only HP actually preserved on the intercepted ally.
# Overkill must never turn into phantom damage on the tank.
# All values are nonnegative whole-number HP / damage.
static func prevented_hp_loss(current_hp: int, normal_damage: int, guarded_damage: int) -> int:
 var available_hp: int = maxi(0, current_hp)
 var normal_loss: int = mini(available_hp, maxi(0, normal_damage))
 var guarded_loss: int = mini(available_hp, maxi(0, guarded_damage))
 return maxi(0, normal_loss - guarded_loss)
