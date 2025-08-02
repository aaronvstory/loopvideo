# Changelog

All notable changes to LoopVideo will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-02

### Added
- **Initial release** of LoopVideo seamless video loop creator
- **PowerShell script** with comprehensive GUI and CLI modes
- **Audio preservation** with synchronized ping-pong loops using FFmpeg areverse+concat
- **Drag & drop support** in GUI mode with visual feedback
- **Dark theme interface** with modern Windows Forms design
- **Multiple video format support**: MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV
- **Quality presets**: ultrafast through veryslow encoding options
- **Progress tracking** with time estimation and status updates
- **Overwrite protection** with user confirmation prompts
- **Error handling** with comprehensive FFmpeg output capture
- **Batch launcher** (LoopVideo-GUI.bat) for easy GUI access
- **Sample files** (test.mp4 and test-looped.mp4) for testing
- **Development documentation** (CLAUDE.md) for maintainers
- **AI agent guidelines** (.github/copilot-instructions.md) for development assistance
- **Comprehensive README** with usage examples and troubleshooting

### Technical Features
- **FFmpeg Integration**: Combined video and audio filter processing
  - Video: `[0:v]reverse[rv];[0:v][rv]concat=n=2:v=1:a=0[outv]`
  - Audio: `[0:a]areverse[ra];[0:a][ra]concat=n=2:v=0:a=1[outa]`
- **High-quality encoding**: H.264 with CRF 18, AAC audio at 192k bitrate
- **Automatic output naming**: Adds "-looped" suffix when output not specified
- **File validation**: Extension and existence checking before processing
- **Temporary file cleanup**: Proper resource management
- **Cross-platform PowerShell**: Compatible with PowerShell 5.1 and 7
- **ANSI color output**: Enhanced console experience with fallback support

### GUI Features
- **Multi-input methods**: Drag-drop, file browser, manual path entry
- **Real-time status updates** with color-coded progress indication
- **Optional success dialogs** (disabled by default for streamlined workflow)
- **Process multiple videos** without restarting application
- **Responsive design** with proper window sizing and element layout

### Developer Experience
- **No build system required**: Direct PowerShell script execution
- **Self-contained**: Single script with all functionality
- **Extensive documentation**: Multiple documentation formats for different audiences
- **Git integration**: Proper .gitignore and repository structure
- **Version control ready**: Clean commit history and semantic versioning

### Dependencies
- **Windows** (PowerShell 5.1+ or PowerShell 7)
- **FFmpeg** in system PATH
- **.NET Framework** (for Windows Forms GUI)

---

## Release Notes

### v1.0.0 Highlights
This initial release provides a complete, production-ready video looping solution with both novice-friendly GUI and power-user CLI interfaces. The focus on audio preservation sets it apart from basic video looping tools, maintaining audio synchronization throughout the ping-pong effect.

**Key Differentiators:**
- **Audio preservation** - Most loop tools strip audio or handle it poorly
- **Dual interface** - GUI for ease-of-use, CLI for automation
- **Quality focus** - High-quality encoding with configurable presets
- **Professional UX** - Dark theme, progress tracking, proper error handling

**Target Users:**
- Content creators needing seamless video loops
- Social media managers creating engaging content
- Video editors requiring quick loop generation
- Developers needing scriptable video processing
- Anyone wanting to create "boomerang" effects from videos

**Future Roadmap Considerations:**
- Batch processing multiple files simultaneously
- Additional codec support (HEVC, AV1)
- Advanced audio mixing options
- Integration with popular video editing workflows
- Custom loop timing and transition effects