# Titan Legends – Update 45: GDScript-Warnungen bereinigt

- `design_details.gd`: ungenutzte Variable `scale_factor` entfernt.
- `hero_polish.gd`: ungenutzte Variable `skin` entfernt.
- `ui_manager.gd`: Schleifenvariable `name` in `channel_name` umbenannt, um Node-Eigenschaft nicht zu überschatten.
- `biome_manager.gd`: Gebietsindex mit expliziter Gleitkommadivision und `floori()` berechnet; weiterhin ein Gebietswechsel alle 100 Stages.

Hinweis: OpenGL-Treiberwarnungen zum RGBAFloat-Format sind hardware-/rendererabhängig und nicht durch diese Scriptänderungen behoben. Laufzeittest in Godot/Android ausstehend.
