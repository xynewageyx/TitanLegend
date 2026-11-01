"""Validate generated GLB structure without installing Python packages."""
import json,struct,pathlib,sys
root=pathlib.Path("assets/heroes/chibi")
names="warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler".split()
errors=[]
for name in names:
 path=root/(name+".glb")
 if not path.is_file():errors.append(f"{name}: missing GLB");continue
 raw=path.read_bytes()
 if len(raw)<32 or raw[:4]!=b"glTF":errors.append(f"{name}: invalid GLB header");continue
 length=struct.unpack_from("<I",raw,8)[0]
 json_len,chunk_type=struct.unpack_from("<II",raw,12)
 if length!=len(raw) or chunk_type!=0x4E4F534A:errors.append(f"{name}: invalid GLB chunks");continue
 doc=json.loads(raw[20:20+json_len])
 if not doc.get("skins"):errors.append(f"{name}: missing skeleton skin")
 if len(doc.get("animations",[]))<5:errors.append(f"{name}: fewer than five animations")
 if not doc.get("meshes"):errors.append(f"{name}: no mesh")
 print(name,"skins",len(doc.get("skins",[])),"animations",len(doc.get("animations",[])))
if errors:
 print("\n".join(errors),file=sys.stderr);sys.exit(1)
print("All 11 chibi GLBs passed structural validation")
