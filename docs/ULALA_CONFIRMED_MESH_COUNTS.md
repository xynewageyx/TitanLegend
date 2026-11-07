# Verified Unity mesh geometry counts (reference only)

The following figures were measured from six Unity 2019.4 serialized Mesh objects extracted from eight legally held Ulala reference bundles. A local stdlib/LZ4 reader traversed the serialized type trees, including 4-byte alignment; all six objects parsed to their exact byte lengths. Triangle counts equal the sum of `indexCount / 3` for submeshes with topology 0 (Triangles).

| Mesh | Vertices | Triangle indices | Triangles |
|---|---:|---:|---:|
| DaDuWa_huo | 1379 | 6618 | 2206 |
| wugui_boss | 2544 | 11019 | 3673 |
| DuJiaoXing | 1710 | 7386 | 2462 |
| ShiTou | 44 | 180 | 60 |
| JuQianXie | 1286 | 5934 | 1978 |
| DanXiaoZhu_CongLin | 1672 | 7734 | 2578 |

These are **mesh-local triangle counts**, not whole-character or full-scene draw-call counts. Geometry is analyzed for original Titan Legends art direction only; no third-party meshes or animations are redistributed. The reference bundles are not stored in this repository.
