# LoopVideo

Create seamless looping videos with audio preservation. Turn any video into a smooth "ping-pong" or "boomerang" effect.

## Quick Start

### 1. Download & Setup
```
1. Download this repository
2. Run setup.bat for automatic dependency checking
3. Start creating loops!
```

### 2. Three Ways to Use

**🖱️ GUI Mode (Easiest)**
- Double-click `LoopVideo-GUI.bat`
- Drag & drop your video file
- Click "CREATE LOOP"

**⌨️ Command Line**
```cmd
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "your-video.mp4"
```

**📁 Drag & Drop**
- Drag your video file onto `loopvideo.ps1`

## Requirements

- **Windows** (any recent version)
- **FFmpeg** - [Download here](https://ffmpeg.org/download.html)

*The setup script will check and guide you through any missing requirements.*

## Supported Formats

**Input:** MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV  
**Output:** High-quality MP4 with preserved audio

## Examples

```cmd
# Basic usage
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "dance.mp4"

# Fast encoding
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "dance.mp4" -Quality "fast"

# Custom output
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "dance.mp4" -OutputFile "dance-loop.mp4"
```

## How It Works

1. **Reverses** your video and audio
2. **Concatenates** original + reversed for seamless loop
3. **Preserves** audio quality and synchronization
4. **Outputs** a smooth looping video

Perfect for social media, presentations, or any creative project!

## Troubleshooting

**"FFmpeg not found"** → Run `setup.bat` for installation guide  
**"Execution Policy"** → Use `-ExecutionPolicy Bypass` in commands  
**GUI won't open** → Try the command line version  

Need help? The setup script will check your system and guide you through any issues.

---

*No installation required - just download and run!*