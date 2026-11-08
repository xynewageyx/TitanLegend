"""Regression checks for compact portrait HUD and optional network diagnostics."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

def source(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")

class MobileOverlayNetworkTests(unittest.TestCase):
    def test_multiplayer_test_is_hidden_until_requested(self):
        code = source("scripts/network/titan_multiplayer_connect_panel.gd")
        self.assertIn("popup.hide()", code)
        self.assertIn("func open_panel() -> void:", code)
        self.assertIn("func close_panel() -> void:", code)
        self.assertIn("CenterContainer.new()", code)
        self.assertIn("127.0.0.1 = dieses Handy", code)
        self.assertNotIn('host_input.text = "127.0.0.1"', code)

    def test_network_client_does_not_reject_default_offline_peer(self):
        code = source("scripts/network/titan_multiplayer_client.gd")
        self.assertIn("current_peer is OfflineMultiplayerPeer", code)
        self.assertIn("multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()", code)
        self.assertNotIn("if multiplayer.has_multiplayer_peer():", code)

    def test_graphics_and_network_buttons_live_in_more_menu(self):
        overlay = source("scripts/adventure_hud_overlay.gd")
        graphics = source("scripts/graphics_settings_menu.gd")
        self.assertIn('["⚙ Grafik", "graphics"]', overlay)
        self.assertIn('["⌁ Netzwerk-Test", "network_test"]', overlay)
        self.assertIn('settings.call("open_menu")', overlay)
        self.assertIn('network_panel.call("open_panel")', overlay)
        self.assertIn("func open_menu() -> void:", graphics)
        self.assertNotIn('open_button.text = "Grafik"', graphics)
        talents = source("scripts/talent_menu_v2.gd")
        self.assertIn('["✥ Talentbaum", "talents_v2"]', overlay)
        self.assertIn('talent_editor.call("open_menu")', overlay)
        self.assertIn("func open_menu() -> void:", talents)
        self.assertNotIn('open_button.text = "Talente +"', talents)

    def test_android_debug_apk_has_network_permission(self):
        export = source("export_presets.cfg")
        self.assertIn("permissions/internet=true", export)

if __name__ == "__main__":
    unittest.main()
