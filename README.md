# Hytale Linux NVIDIA GPU Fix

Automatic fix for Hytale flatpak using Intel integrated graphics instead of NVIDIA GPU on Linux.

## The Problem

Hytale flatpak defaults to Mesa/Intel integrated graphics even when an NVIDIA GPU is available, resulting in poor performance (~30 FPS instead of 100+ FPS).

**Symptoms:**
- Debug overlay (F7, requires Developer Mode in settings) shows: `GPU Renderer: Mesa Intel(R) UHD Graphics`
- Low FPS despite having a powerful NVIDIA GPU
- Game runs sluggishly

## Quick Fix (One-Liner)

Copy and paste this into your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/Mr-Renegade/hytale-nvidia-fix/master/fix-hytale-nvidia.sh | bash
```

That's it! The script will:
1. Detect your NVIDIA driver version
2. Install the matching flatpak GL extension
3. Verify the installation

### Alternative: Download and Run

```bash
wget https://raw.githubusercontent.com/Mr-Renegade/hytale-nvidia-fix/master/fix-hytale-nvidia.sh
chmod +x fix-hytale-nvidia.sh
./fix-hytale-nvidia.sh
```

## Manual Fix

If you prefer to do it manually:

### Step 1: Check Your NVIDIA Driver Version

```bash
nvidia-smi
```

Look for the driver version in the output (e.g., `Driver Version: 580.119.02`)

### Step 2: Install Matching NVIDIA Flatpak Extension

Replace `580-119-02` with your driver version (use dashes instead of dots):

```bash
flatpak install -y flathub org.freedesktop.Platform.GL.nvidia-580-119-02
```

**Examples for other driver versions:**
- Driver `535.183.01` → `flatpak install flathub org.freedesktop.Platform.GL.nvidia-535-183-01`
- Driver `550.90.07` → `flatpak install flathub org.freedesktop.Platform.GL.nvidia-550-90-07`
- Driver `565.57.01` → `flatpak install flathub org.freedesktop.Platform.GL.nvidia-565-57-01`

### Step 3: Launch Hytale

```bash
flatpak run com.hypixel.HytaleLauncher
```

**That's it!** No environment variables, no config changes, no overrides needed.

To verify it's working:
1. In Hytale, go to **Settings** and enable **Developer Mode**
2. Press **F7** in-game to open the debug overlay
3. Check the **RENDERING** section - you should now see:
   - `GPU: NVIDIA GeForce RTX [YOUR MODEL]`
   - `OpenGL: [VERSION] NVIDIA [DRIVER VERSION]`
   - Significantly higher FPS

## Why This Works

Flatpak apps run in sandboxes isolated from the host system. The Hytale flatpak uses the GNOME Platform runtime, which only includes Mesa (open-source) graphics drivers by default.

The `org.freedesktop.Platform.GL.nvidia-*` extensions provide NVIDIA proprietary drivers to flatpak applications. Without the extension, flatpak apps fall back to Mesa/Intel graphics.

## Finding Available NVIDIA Extensions

To see all available NVIDIA GL extensions:

```bash
flatpak remote-ls flathub | grep "GL.nvidia"
```

## Compatibility

This fix works on **any Linux distribution** that uses:
- Flatpak
- NVIDIA proprietary drivers
- The Hytale flatpak from Hypixel

**Tested on:**
- Pop!_OS 22.04 LTS (NVIDIA ISO)
- NVIDIA GeForce RTX 4070 Laptop GPU
- Driver version 580.119.02

## Results

**Before fix:**
- GPU: Mesa Intel UHD Graphics
- FPS: ~30
- OpenGL: Mesa 25.2.6

**After fix:**
- GPU: NVIDIA GeForce RTX 4070
- FPS: 146+
- OpenGL: 3.3.0 NVIDIA 580.119.02
- VRAM: 8188 MB available

## Troubleshooting

### Still showing Mesa/Intel after installing extension?

1. **Verify the extension is installed:**
   ```bash
   flatpak list | grep nvidia
   ```

2. **Check your driver version matches:**
   ```bash
   nvidia-smi | grep "Driver Version"
   ```

3. **Try restarting Hytale** (close completely and relaunch)

4. **If using hybrid graphics (laptop), ensure NVIDIA mode is active:**
   ```bash
   # For Pop!_OS:
   system76-power graphics nvidia
   sudo reboot
   ```

### Extension not found?

Your driver version might be very new. Check available extensions:
```bash
flatpak search nvidia
```

Install the closest version available, or update your NVIDIA drivers to a version that has a flatpak extension.

## Additional Notes

- This fix applies to **any flatpak game or application** that needs NVIDIA GPU support
- The extension downloads ~300-350 MB
- You need to install a new extension when you update your NVIDIA drivers
- This is not needed for native (non-flatpak) games, as they access system drivers directly

## Contributing

Found this helpful? Have suggestions? Feel free to open an issue or submit a pull request!

## License

MIT License - feel free to use and share!

---

**Original Issue:** Hytale defaulted to Intel integrated graphics on Fedora and Pop!_OS  
**Solution:** Install matching NVIDIA flatpak GL extension  
**Result:** Full NVIDIA GPU acceleration with 4-5x performance improvement  

Enjoy gaming at full performance! 🎮🚀
