# Terrain3D integration gate (Android)
Target: Godot 4.7.x, GL Compatibility renderer, Android arm64.
Pinned Terrain3D release: **v1.0.2-stable**. Upstream supports Godot 4.4–4.7 and describes Android as experimental.

This directory adds a non-destructive inspection workflow. It downloads the official release ZIP from the upstream GitHub release, checks for a GDExtension manifest and Android binary candidates, and publishes a JSON report. It **does not install the addon, alter main.tscn, or assert that the Android build works**.

Next gates:
1. Check report and review addon file layout / Android binaries.
2. Add the official addon to an isolated test Godot project, preserving license.
3. Start Godot in headless mode to validate import, then export an Android APK.
4. Test APK on physical Android hardware, including Compatibility renderer.
5. Only after successful tests, connect terrain to Titan Legends main scene.

Upstream platform notes: https://terrain3d.readthedocs.io/en/stable/docs/platforms.html
