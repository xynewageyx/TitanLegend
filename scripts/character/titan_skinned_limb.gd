extends Node3D
class_name TitanSkinnedLimb
## Original procedural two-bone skinned mesh. This is a prototype, not final art.
## Add this node as a sibling of Skeleton3D and call build_limb(skeleton, ...).

var mesh_instance: MeshInstance3D

func build_limb(skeleton: Skeleton3D, upper_bone: String, lower_bone: String, radius: float = 0.12) -> bool:
    if skeleton == null or radius <= 0.0:
        return false
    var upper := skeleton.find_bone(upper_bone)
    var lower := skeleton.find_bone(lower_bone)
    if upper < 0 or lower < 0 or skeleton.get_bone_parent(lower) != upper:
        push_warning("Invalid two-bone chain: " + upper_bone + " -> " + lower_bone)
        return false
    var upper_global := skeleton.get_bone_global_rest(upper)
    var lower_global := skeleton.get_bone_global_rest(lower)
    var start := upper_global.origin
    var end := lower_global.origin
    var length := start.distance_to(end)
    if length < 0.01:
        return false
    var direction := (end - start).normalized()
    var tangent := direction.cross(Vector3.FORWARD).normalized()
    if tangent.length_squared() < 0.1:
        tangent = direction.cross(Vector3.RIGHT).normalized()
    var bitangent := direction.cross(tangent).normalized()
    var vertices := PackedVector3Array()
    var normals := PackedVector3Array()
    var bones := PackedInt32Array()
    var weights := PackedFloat32Array()
    var indices := PackedInt32Array()
    const SIDES := 8
    const RINGS := 7
    for ring in range(RINGS):
        var fraction := float(ring) / float(RINGS - 1)
        var center := start.lerp(end, fraction)
        for side in range(SIDES):
            var angle := TAU * float(side) / float(SIDES)
            var normal := (tangent * cos(angle) + bitangent * sin(angle)).normalized()
            vertices.append(center + normal * radius)
            normals.append(normal)
            bones.append_array(PackedInt32Array([0, 1, 0, 0]))
            # Smoothly transition influence between the two joints.
            var lower_weight := smoothstep(0.15, 0.85, fraction)
            weights.append_array(PackedFloat32Array([1.0 - lower_weight, lower_weight, 0.0, 0.0]))
    for ring in range(RINGS - 1):
        for side in range(SIDES):
            var next_side := (side + 1) % SIDES
            var a := ring * SIDES + side
            var b := ring * SIDES + next_side
            var c := (ring + 1) * SIDES + side
            var d := (ring + 1) * SIDES + next_side
            indices.append_array(PackedInt32Array([a, c, b, b, c, d]))
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_NORMAL] = normals
    arrays[Mesh.ARRAY_BONES] = bones
    arrays[Mesh.ARRAY_WEIGHTS] = weights
    arrays[Mesh.ARRAY_INDEX] = indices
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    var skin := Skin.new()
    for bone_id in [upper, lower]:
        var rest := skeleton.get_bone_global_rest(bone_id)
        skin.add_bind(bone_id, rest.affine_inverse())
    if mesh_instance != null and is_instance_valid(mesh_instance):
        remove_child(mesh_instance)
        mesh_instance.free()
    mesh_instance = MeshInstance3D.new()
    mesh_instance.name = "SkinnedLimb"
    mesh_instance.mesh = mesh
    mesh_instance.skin = skin
    add_child(mesh_instance)
    mesh_instance.skeleton = mesh_instance.get_path_to(skeleton)
    return true
