# LoopVideo

A PowerShell utility that creates seamless looping videos using FFmpeg. Generate "ping-pong" or "boomerang" effects by concatenating the original video with its time-reversed copy, creating smooth loops without jarring cuts.

## Features

- **🎥 Seamless Loops**: Creates smooth ping-pong loops with no jarring transitions
- **🔊 Audio Preservation**: Maintains synchronized audio throughout the loop  
- **🖥️ Dual Interface**: Both GUI and command-line modes available
- **📁 Drag & Drop**: Simple drag-and-drop functionality in GUI mode
- **⚙️ Quality Control**: Multiple encoding presets for different use cases
- **🎨 Dark Theme**: Modern, easy-on-the-eyes interface
- **📊 Progress Tracking**: Real-time processing updates with time estimates
- **🛡️ Safe Operations**: Overwrite confirmation and comprehensive error handling

## Prerequisites

- **Windows** (PowerShell 5.1 or PowerShell 7)
- **FFmpeg** installed and accessible via PATH

### Installing FFmpeg

1. Download FFmpeg from [ffmpeg.org](https://ffmpeg.org/download.html)
2. Extract to a folder (e.g., `C:\ffmpeg`)
3. Add `C:\ffmpeg\bin` to your system PATH
4. Restart PowerShell/Command Prompt

## Usage

### GUI Mode (Recommended)

#### Option 1: Double-click Launcher
```
Double-click LoopVideo-GUI.bat
```

#### Option 2: PowerShell Command
```powershell
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -GUI
```

#### Option 3: Drag & Drop
Drag a video file directly onto `loopvideo.ps1`

### Command-Line Mode

#### Basic Usage
```powershell
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "video.mp4"
```

#### Advanced Usage
```powershell
# Custom output filename
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "input.mp4" -OutputFile "custom-loop.mp4"

# Different quality preset
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "input.mp4" -Quality "fast"

# Combination
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "input.mp4" -OutputFile "output.mp4" -Quality "slow"
```

## Supported Formats

- **Video**: MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV
- **Audio**: Preserved with AAC encoding at 192k bitrate

## Quality Presets

Choose encoding speed vs quality tradeoff:

- `ultrafast` - Fastest encoding, larger files
- `superfast` - Very fast encoding  
- `veryfast` - Fast encoding
- `faster` - Faster than default
- `fast` - Fast encoding
- `medium` - **Default** - Balanced speed/quality
- `slow` - Slower, better quality
- `slower` - Much slower, higher quality  
- `veryslow` - Slowest, best quality

## How It Works

LoopVideo uses FFmpeg's filter_complex to create seamless loops:

1. **Video Processing**: `[0:v]reverse[rv];[0:v][rv]concat=n=2:v=1:a=0[outv]`
   - Reverses the original video
   - Concatenates original + reversed for ping-pong effect

2. **Audio Processing**: `[0:a]areverse[ra];[0:a][ra]concat=n=2:v=0:a=1[outa]`
   - Reverses the original audio  
   - Concatenates original + reversed to stay synchronized

3. **Output**: High-quality H.264 video with AAC audio

## Examples

### Create a loop with default settings
```powershell
.\loopvideo.ps1 -InputFile "dance.mp4"
# Output: dance-looped.mp4
```

### Fast encoding for quick preview
```powershell
.\loopvideo.ps1 -InputFile "dance.mp4" -Quality "fast"
```

### Custom output location
```powershell
.\loopvideo.ps1 -InputFile "dance.mp4" -OutputFile "C:\Videos\dance-final.mp4"
```

## File Structure

```
LoopVideo/
├── loopvideo.ps1              # Main PowerShell script
├── LoopVideo-GUI.bat          # GUI launcher 
├── CLAUDE.md                  # Development documentation
├── README.md                  # This file
├── CHANGELOG.md               # Version history
├── .gitignore                 # Git ignore rules
├── .github/
│   └── copilot-instructions.md # AI coding agent guidelines
├── test.mp4                   # Sample input video
└── test-looped.mp4           # Sample output video
```

## Development

This project is designed for simplicity and portability:

- **No build system** - Pure PowerShell script
- **No dependencies** - Only requires FFmpeg  
- **Self-contained** - All functionality in one script
- **Cross-Windows** - Works on PowerShell 5.1 and 7

### Testing

Use the provided test files:
```powershell
.\loopvideo.ps1 -InputFile "test.mp4"
```

Compare output with `test-looped.mp4` to verify functionality.

## Troubleshooting

### "FFmpeg not found"
- Ensure FFmpeg is installed and in your system PATH
- Test with: `ffmpeg -version` in Command Prompt

### "Execution Policy" errors  
- Use `-ExecutionPolicy Bypass` flag in PowerShell commands
- Or run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### GUI won't open
- Ensure you're on Windows with .NET Framework
- Try running the PowerShell command directly instead of the batch file

### Processing fails
- Check video file format is supported  
- Ensure sufficient disk space for output
- Review FFmpeg error messages in console output

## License

This project is open source. Feel free to modify and distribute.

## Contributing

1. Fork the repository
2. Make your changes
3. Test with various video formats
4. Submit a pull request

## Acknowledgments

- **FFmpeg** - The powerful multimedia framework that makes this possible
- **PowerShell** - Microsoft's versatile scripting platform
- **Windows Forms** - For the GUI functionality