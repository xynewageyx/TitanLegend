#!/usr/bin/env python3
"""Inspect official Terrain3D release for Android GDExtension binaries.
Does not modify Godot's project or claim runtime compatibility."""
import io, json, pathlib, urllib.request, zipfile
TAG="v1.0.2-stable"
ROOT=pathlib.Path("terrain3d-inspection")
ROOT.mkdir(exist_ok=True)
req=urllib.request.Request(f"https://api.github.com/repos/TokisanGames/Terrain3D/releases/tags/{TAG}",headers={"User-Agent":"TitanLegends-CI","Accept":"application/vnd.github+json"})
with urllib.request.urlopen(req,timeout=30) as r: release=json.load(r)
assets=release.get("assets",[])
matches=[a for a in assets if a["name"].lower().endswith(".zip") and "terrain3d" in a["name"].lower()]
if not matches: raise RuntimeError("No official Terrain3D zip release asset found")
asset=next((a for a in matches if "1.0.2" in a["name"]),matches[0])
req=urllib.request.Request(asset["browser_download_url"],headers={"User-Agent":"TitanLegends-CI"})
with urllib.request.urlopen(req,timeout=120) as r: payload=r.read()
with zipfile.ZipFile(io.BytesIO(payload)) as z:
 names=z.namelist()
 android=[n for n in names if ("android" in n.lower() or "arm64" in n.lower()) and (n.endswith(".so") or n.endswith(".gdextension"))]
 extensions=[n for n in names if n.endswith(".gdextension")]
 report={"tag":TAG,"asset":asset["name"],"download_url":asset["browser_download_url"],"android_binary_candidates":android,"gdextension_manifests":extensions,"total_files":len(names)}
 (ROOT/"report.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
 print(json.dumps(report,indent=2))
 if not extensions: raise RuntimeError("No GDExtension manifest found")
 if not android: raise RuntimeError("No Android binary candidates found; inspect release packaging")
