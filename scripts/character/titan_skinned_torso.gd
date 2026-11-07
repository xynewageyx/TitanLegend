extends Node3D
class_name TitanSkinnedTorso
## Original, continuous torso surface with pelvis/spine/chest skin weights.
## A prototype for Godot Compatibility renderer, not final character art.

var mesh_instance: MeshInstance3D

func build_torso(skeleton: Skeleton3D, radius: float = 0.32) -> bool:
    if skeleton == null or radius <= 0.0:
        return false
    var names := ["pelvis", "spine", "chest"]
    var ids := PackedInt32Array()
    for bone_name in names:
        var idx := skeleton.find_bone(bone_name)
        if idx < 0:
            return false
        ids.append(idx)
    if skeleton.get_bone_parent(ids[1]) != ids[0] or skeleton.get_bone_parent(ids[2]) != ids[1]:
        return false
    var bottom: Vector3 = skeleton.get_bone_global_rest(ids[0]).origin
    var top: Vector3 = skeleton.get_bone_global_rest(ids[2]).origin
    var vertices := PackedVector3Array()
    var normals := PackedVector3Array()
    var bone_indices := PackedInt32Array()
    var weights := PackedFloat32Array()
    var triangles := PackedInt32Array()
    const RINGS := 9
    const SIDES := 12
    for ring in range(RINGS):
        var t := float(ring) / float(RINGS - 1)
        var center := bottom.lerp(top, t)
        var width := radius * (0.88 + 0.24 * sin(PI * t))
        for side in range(SIDES):
            var a := TAU * float(side) / float(SIDES)
            var normal := Vector3(cos(a), 0.0, sin(a))
            vertices.append(center + normal * width)
            normals.append(normal)
            bone_indices.append_array(PackedInt32Array([0, 1, 2, 0]))
            var pelvis_weight := 1.0 - smoothstep(0.0, 0.55, t)
            var chest_weight := smoothstep(0.45, 1.0, t)
            var spine_weight := maxf(0.0, 1.0 - pelvis_weight - chest_weight)
            var total := pelvis_weight + spine_weight + chest_weight
            weights.append_array(PackedFloat32Array([
                pelvis_weight / total, spine_weight / total, chest_weight / total, 0.0
            ]))
    for ring in range(RINGS - 1):
        for side in range(SIDES):
            var a := ring * SIDES + side
            var b := ring * SIDES + (side + 1) % SIDES
            var c := (ring + 1) * SIDES + side
            var d := (ring + 1) * SIDES + (side + 1) % SIDES
            triangles.append_array(PackedInt32Array([a, c, b, b, c, d]))
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_NORMAL] = normals
    arrays[Mesh.ARRAY_BONES] = bone_indices
    arrays[Mesh.ARRAY_WEIGHTS] = weights
    arrays[Mesh.ARRAY_INDEX] = triangles
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    var skin := Skin.new()
    for idx in ids:
        skin.add_bind(idx, skeleton.get_bone_global_rest(idx).affine_inverse())
    if mesh_instance != null and is_instance_valid(mesh_instance):
        remove_child(mesh_instance)
        mesh_instance.free()
    mesh_instance = MeshInstance3D.new()
    mesh_instance.name = "SkinnedTorso"
    mesh_instance.mesh = mesh
    add_child(mesh_instance)
    mesh_instance.skin = skin
    mesh_instance.skeleton = mesh_instance.get_path_to(skeleton)
    return true
