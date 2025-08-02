# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LoopVideo is a PowerShell-based video processing utility that creates seamless looping videos using FFmpeg. It generates "ping-pong" or "boomerang" effects by concatenating the original video with its time-reversed copy, creating smooth loops without jarring cuts.

## Development Commands

### Running the Application
```bash
# GUI Mode (Windows batch launcher)
LoopVideo-GUI.bat

# PowerShell GUI Mode
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -GUI

# Command-line Mode
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "video.mp4"

# With custom output and quality
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "video.mp4" -OutputFile "custom-loop.mp4" -Quality "fast"
```

### FFmpeg Dependency
The application requires FFmpeg to be installed and accessible via PATH. The script automatically checks for FFmpeg availability and provides installation guidance if missing.

## Architecture & Key Components

### Core Script Structure
- **Main Script**: `loopvideo.ps1` - Complete PowerShell application with GUI and CLI modes
- **GUI Launcher**: `LoopVideo-GUI.bat` - Windows batch file for easy GUI access
- **Video Processing**: Uses FFmpeg with filter_complex for seamless video concatenation

### Processing Pipeline
1. **Input Validation**: File existence, format validation, and FFmpeg availability check
2. **Video Analysis**: Duration extraction for progress estimation
3. **FFmpeg Processing**: Uses combined video and audio filter chains for seamless ping-pong loops with preserved audio
4. **Output Generation**: Creates `-looped` suffixed filename with size comparison

### Supported Video Formats
- MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV

### Quality Presets
- ultrafast, superfast, veryfast, faster, fast, medium (default), slow, slower, veryslow

## Key Functions

### Video Processing (`Process-VideoFile`)
- **Input**: Video file path, optional output path, quality preset
- **Processing**: FFmpeg command execution with progress tracking
- **Output**: Success/failure status with detailed error reporting
- **Features**: Overwrite confirmation, file size comparison, processing time tracking

### GUI System (`Show-GUI`)
- **Dark Theme**: Custom Windows Forms interface with drag-drop support
- **Multiple Input Methods**: Drag-drop zone, file browser, manual path entry
- **Progress Tracking**: Real-time status updates and progress bar
- **User Options**: Configurable success dialogues, process multiple files

### Validation Functions
- **`Test-FFmpegAvailable`**: Checks FFmpeg installation
- **`Test-VideoFile`**: Validates file existence and format
- **`Get-VideoDuration`**: Extracts video duration for progress estimation

## Usage Modes

### 1. Drag & Drop
Drag video files directly onto `loopvideo.ps1` for instant processing

### 2. GUI Mode
Double-click script or run `LoopVideo-GUI.bat` for interactive interface with:
- Drag-drop zone with visual feedback
- File browser integration
- Manual path entry
- Progress monitoring
- Batch processing capability

### 3. Command-Line Mode
Direct PowerShell execution with parameters for automation:
```powershell
.\loopvideo.ps1 -InputFile "input.mp4" -OutputFile "output.mp4" -Quality "fast"
```

## Development Notes

### PowerShell Requirements
- Windows PowerShell 5.1 or PowerShell Core 6+
- Execution Policy: Bypass required for unsigned script execution
- Windows Forms assemblies: `System.Windows.Forms` and `System.Drawing`

### FFmpeg Integration
- Uses filter_complex for combined video and audio processing:
  - Video: `[0:v]reverse[rv];[0:v][rv]concat=n=2:v=1:a=0[outv]`
  - Audio: `[0:a]areverse[ra];[0:a][ra]concat=n=2:v=0:a=1[outa]`
- Encoding settings: libx264 codec, CRF 18 (high quality), yuv420p pixel format
- Audio codec: AAC at 192k bitrate for broad compatibility
- Audio preserved: Creates seamless ping-pong loops with synchronized audio reverse

### Error Handling
- Comprehensive FFmpeg output capture
- User-friendly error messages
- Validation at multiple stages
- Graceful degradation for missing dependencies

### File Management
- Automatic output filename generation with `-looped` suffix
- Overwrite confirmation prompts
- Temporary file cleanup
- File size comparison reporting

## Testing Considerations

### Test Files
- `test.mp4` and `test-looped.mp4` - Sample input/output files for validation
- Various video formats and durations
- Edge cases: very short videos, large files, unusual aspect ratios

### Environment Testing
- FFmpeg availability in different PATH configurations
- PowerShell execution policy variations
- GUI responsiveness across Windows versions
- Drag-drop functionality testing

### Performance Testing
- Processing time vs video duration correlation
- Quality preset impact on output file size
- Memory usage during processing
- Concurrent processing limitations