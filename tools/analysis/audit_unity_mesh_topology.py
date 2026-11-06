#!/usr/bin/env python3
"""Read-only aggregate Unity mesh topology statistics; no geometry export.

Requires UnityPy. Reports only counts and distributions; never writes vertices,
indices, materials, bone transforms, names or per-mesh identifiable records.
"""
import argparse
import json
import math
import struct
from collections import Counter
from pathlib import Path

MAGIC = (b"UnityFS", b"UnityWeb", b"UnityRaw")


def _safe_int(value):
    try:
        result = int(value)
        return result if result >= 0 else None
    except (TypeError, ValueError, OverflowError):
        return None


def _summary(values):
    return {"count": len(values), **(
        {"min": min(values), "max": max(values),
         "mean": round(sum(values) / len(values), 2)} if values else {})}


def _validate_index_buffer(mesh, submeshes, vertices):
    """Decode indices in memory to validate submesh offsets and vertex bounds.

    Returns aggregate validation counts only; never exports decoded indices.
    Unity m_IndexFormat 0 = uint16, 1 = uint32.
    """
    raw = getattr(mesh, "m_IndexBuffer", None)
    fmt = _safe_int(getattr(mesh, "m_IndexFormat", None))
    if raw is None or fmt not in (0, 1):
        return {"status": "unavailable", "indices_checked": 0, "invalid_indices": 0}
    try:
        view = memoryview(raw).cast("B")
    except (TypeError, ValueError):
        return {"status": "unavailable", "indices_checked": 0, "invalid_indices": 0}
    width = 2 if fmt == 0 else 4
    unpack = "<H" if fmt == 0 else "<I"
    checked = 0
    invalid = 0
    for sub in submeshes:
        first = _safe_int(getattr(sub, "firstByte", None))
        count = _safe_int(getattr(sub, "indexCount", None))
        base = _safe_int(getattr(sub, "baseVertex", 0))
        if first is None or count is None or base is None or first % width:
            return {"status": "invalid_layout", "indices_checked": checked,
                    "invalid_indices": invalid}
        if first + count * width > len(view):
            return {"status": "invalid_layout", "indices_checked": checked,
                    "invalid_indices": invalid}
        for offset in range(first, first + count * width, width):
            value = struct.unpack_from(unpack, view, offset)[0]
            checked += 1
            if vertices is not None and value + base >= vertices:
                invalid += 1
    return {"status": "checked" if vertices is not None else "bounds_unknown",
            "indices_checked": checked, "invalid_indices": invalid}


# Unity VertexFormat byte widths for common formats. Unknown formats are
# reported rather than guessed. The buffer itself is never exported.
FORMAT_WIDTH = {0: 4, 1: 2, 2: 1, 3: 1, 4: 1, 5: 1, 6: 2,
                7: 2, 8: 4, 9: 4, 10: 4, 11: 4}


def _vertex_layout(mesh):
    """Inspect channel/stream byte layout without extracting vertex coordinates."""
    vertex_data = getattr(mesh, "m_VertexData", None)
    if vertex_data is None:
        return {"status": "unavailable", "channels": 0}
    channels = getattr(vertex_data, "m_Channels", None)
    streams = getattr(vertex_data, "m_Streams", None)
    if channels is None or streams is None:
        return {"status": "unavailable", "channels": 0}
    vertex_count = _safe_int(getattr(vertex_data, "m_VertexCount", None))
    data = getattr(vertex_data, "m_DataSize", None)
    try:
        data_bytes = len(memoryview(data).cast("B"))
    except (TypeError, ValueError):
        data_bytes = None
    if vertex_count is None or data_bytes is None:
        return {"status": "unavailable", "channels": len(channels)}
    invalid = 0
    unknown = 0
    active = 0
    for channel in channels:
        dimension = _safe_int(getattr(channel, "dimension", None))
        if not dimension:
            continue
        active += 1
        stream_idx = _safe_int(getattr(channel, "stream", None))
        fmt = _safe_int(getattr(channel, "format", None))
        offset = _safe_int(getattr(channel, "offset", None))
        if fmt not in FORMAT_WIDTH:
            unknown += 1
            continue
        if stream_idx is None or stream_idx >= len(streams) or offset is None:
            invalid += 1
            continue
        stream = streams[stream_idx]
        stride = _safe_int(getattr(stream, "stride", None))
        start = _safe_int(getattr(stream, "offset", None))
        width = dimension * FORMAT_WIDTH[fmt]
        if stride is None or start is None or offset + width > stride:
            invalid += 1
            continue
        if vertex_count and start + (vertex_count - 1) * stride + offset + width > data_bytes:
            invalid += 1
    status = "invalid_layout" if invalid else ("unknown_format" if unknown else "checked")
    return {"status": status, "channels": active,
            "invalid_channels": invalid, "unknown_channels": unknown}


def _decode_positions(mesh):
    """Decode float32 position channel in memory; return aggregate diagnostics only.

    Unity channel 0 is position for the supported layout. Other formats are
    explicitly unsupported rather than guessed.
    """
    vd = getattr(mesh, "m_VertexData", None)
    if vd is None:
        return {"status": "unavailable"}
    channels = getattr(vd, "m_Channels", None)
    streams = getattr(vd, "m_Streams", None)
    count = _safe_int(getattr(vd, "m_VertexCount", None))
    if not channels or not streams or count is None:
        return {"status": "unavailable"}
    ch = channels[0]
    fmt = _safe_int(getattr(ch, "format", None))
    if fmt not in (0, 1) or _safe_int(getattr(ch, "dimension", None)) != 3:
        return {"status": "unsupported_format"}
    width = 4 if fmt == 0 else 2
    unpack = "<fff" if fmt == 0 else "<eee"
    stream_id = _safe_int(getattr(ch, "stream", None))
    offset = _safe_int(getattr(ch, "offset", None))
    if stream_id is None or stream_id >= len(streams) or offset is None:
        return {"status": "invalid_layout"}
    stream = streams[stream_id]
    stride = _safe_int(getattr(stream, "stride", None))
    start = _safe_int(getattr(stream, "offset", None))
    try:
        data = memoryview(getattr(vd, "m_DataSize")).cast("B")
    except (TypeError, ValueError):
        return {"status": "unavailable"}
    if stride is None or start is None or offset + 3 * width > stride:
        return {"status": "invalid_layout"}
    if count and start + (count - 1) * stride + offset + 3 * width > len(data):
        return {"status": "invalid_layout"}
    minimum = [math.inf] * 3
    maximum = [-math.inf] * 3
    nonfinite = 0
    for i in range(count):
        xyz = struct.unpack_from(unpack, data, start + i * stride + offset)
        if not all(math.isfinite(v) for v in xyz):
            nonfinite += 1
            continue
        for axis, value in enumerate(xyz):
            minimum[axis] = min(minimum[axis], value)
            maximum[axis] = max(maximum[axis], value)
    return {"status": "decoded", "positions_checked": count,
            "nonfinite_positions": nonfinite,
            "finite_positions": count - nonfinite,
            "extent": [round(hi - lo, 4) for lo, hi in zip(minimum, maximum)]
            if count > nonfinite else None}


def inspect(root, limit=0, max_bytes=250 * 1024 * 1024):
    import UnityPy
    metrics = {"vertex_count": [], "submesh_count": [], "index_count": [],
               "triangle_count": [], "skinned_bone_refs": [], "decoded_indices": []}
    topologies = Counter()
    unity_object_types = Counter()
    serialized_objects = 0
    errors = Counter()
    index_validation = Counter()
    vertex_validation = Counter()
    position_validation = Counter()
    scanned = 0
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        try:
            if path.stat().st_size > max_bytes:
                errors["oversized_file"] += 1
                continue
            with path.open("rb") as f:
                if not f.read(16).startswith(MAGIC):
                    continue
            if limit and scanned >= limit:
                break
            scanned += 1
            env = UnityPy.load(str(path))
            for obj in env.objects:
                serialized_objects += 1
                kind = obj.type.name
                unity_object_types[kind] += 1
                if kind not in ("Mesh", "SkinnedMeshRenderer"):
                    continue
                try:
                    data = obj.read()
                    if kind == "SkinnedMeshRenderer":
                        bones = getattr(data, "m_Bones", None)
                        if bones is not None:
                            metrics["skinned_bone_refs"].append(len(bones))
                        continue
                    positions = _decode_positions(data)
                    position_validation[positions["status"]] += 1
                    if positions.get("nonfinite_positions"):
                        errors["nonfinite_positions"] += positions["nonfinite_positions"]
                    layout = _vertex_layout(data)
                    vertex_validation[layout["status"]] += 1
                    if layout.get("invalid_channels", 0):
                        errors["invalid_vertex_channels"] += layout["invalid_channels"]
                    vertices = _safe_int(getattr(data, "m_VertexCount", None))
                    if vertices is None:
                        vertex_data = getattr(data, "m_VertexData", None)
                        vertices = _safe_int(getattr(vertex_data, "m_VertexCount", None))
                    if vertices is not None:
                        metrics["vertex_count"].append(vertices)
                    subs = getattr(data, "m_SubMeshes", None)
                    if subs is None:
                        continue
                    metrics["submesh_count"].append(len(subs))
                    check = _validate_index_buffer(data, subs, vertices)
                    index_validation[check["status"]] += 1
                    if check["status"] in ("checked", "bounds_unknown"):
                        metrics["decoded_indices"].append(check["indices_checked"])
                        if check["invalid_indices"]:
                            errors["out_of_range_indices"] += check["invalid_indices"]
                    mesh_indices = 0
                    mesh_triangles = 0
                    for sub in subs:
                        count = _safe_int(getattr(sub, "indexCount", None))
                        topology = _safe_int(getattr(sub, "topology", None))
                        if topology is not None:
                            topologies[str(topology)] += 1
                        if count is not None:
                            mesh_indices += count
                            # Unity MeshTopology.Triangles = 0; other topologies
                            # must not be interpreted as triangle lists.
                            if topology == 0:
                                mesh_triangles += count // 3
                    metrics["index_count"].append(mesh_indices)
                    metrics["triangle_count"].append(mesh_triangles)
                except Exception:
                    errors["object_read_failed"] += 1
        except Exception:
            errors["bundle_read_failed"] += 1
    return {
        "format": "aggregate Unity mesh topology audit v1",
        "scanned_bundles": scanned,
        "serialized_objects": serialized_objects,
        "unity_object_types": dict(sorted(unity_object_types.items())),
        "metrics": {key: _summary(values) for key, values in metrics.items()},
        "submesh_topology_codes": dict(sorted(topologies.items())),
        "index_validation": dict(sorted(index_validation.items())),
        "vertex_layout_validation": dict(sorted(vertex_validation.items())),
        "position_decode_validation": dict(sorted(position_validation.items())),
        "errors": dict(sorted(errors.items())),
        "caveats": [
            "Triangle counts include only topology 0 triangle-list submeshes.",
            "Index counts come from submeshes; when present, raw uint16/uint32 index buffers are decoded in memory and bounds checked.",
            "Float32 and Float16 XYZ position channels are decoded in memory to check finite values and bounds; no coordinates or per-mesh bounds are exported.",
            "Unity version-specific vertex formats outside the known format map are marked unknown.",
            "Skinned bone references do not prove hierarchy, weights or bind poses.",
            "Unity object types and counts are aggregate only; no object names or asset payloads are exported."
        ],
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--output", type=Path, default=Path("ulala_mesh_topology_summary.json"))
    parser.add_argument("--max-files", type=int, default=0)
    args = parser.parse_args()
    if not args.root.is_dir() or args.max_files < 0:
        parser.error("invalid root or max-files")
    try:
        report = inspect(args.root, limit=args.max_files)
    except ImportError:
        parser.error("UnityPy missing: pip install UnityPy")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
