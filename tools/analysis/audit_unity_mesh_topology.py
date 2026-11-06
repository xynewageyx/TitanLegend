#!/usr/bin/env python3
"""Read-only aggregate Unity mesh topology statistics; no geometry export.

Requires UnityPy. Reports only counts and distributions; never writes vertices,
indices, materials, bone transforms, names or per-mesh identifiable records.
"""
import argparse
import json
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


def inspect(root, limit=0, max_bytes=250 * 1024 * 1024):
    import UnityPy
    metrics = {"vertex_count": [], "submesh_count": [], "index_count": [],
               "triangle_count": [], "skinned_bone_refs": []}
    topologies = Counter()
    errors = Counter()
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
                kind = obj.type.name
                if kind not in ("Mesh", "SkinnedMeshRenderer"):
                    continue
                try:
                    data = obj.read()
                    if kind == "SkinnedMeshRenderer":
                        bones = getattr(data, "m_Bones", None)
                        if bones is not None:
                            metrics["skinned_bone_refs"].append(len(bones))
                        continue
                    vertices = _safe_int(getattr(data, "m_VertexCount", None))
                    if vertices is not None:
                        metrics["vertex_count"].append(vertices)
                    subs = getattr(data, "m_SubMeshes", None)
                    if subs is None:
                        continue
                    metrics["submesh_count"].append(len(subs))
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
        "metrics": {key: _summary(values) for key, values in metrics.items()},
        "submesh_topology_codes": dict(sorted(topologies.items())),
        "errors": dict(sorted(errors.items())),
        "caveats": [
            "Triangle counts include only topology 0 triangle-list submeshes.",
            "Index count is taken from m_SubMeshes.indexCount; raw index buffers are not decoded.",
            "Skinned bone references do not prove hierarchy, weights or bind poses.",
            "No vertex coordinates, indices, names or original assets are exported."
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
