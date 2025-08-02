# Copilot Project Instructions

## Scope
- Windows PowerShell utility that creates seamless "ping‑pong" looped videos using FFmpeg.
- Single entrypoint: loopvideo.ps1 with GUI and CLI modes.
- Script-first repo; no packaging or CI.

## Architecture
- loopvideo.ps1
  - Validation: Test-FFmpegAvailable, Test-VideoFile, Get-VideoDuration
  - Processing: Process-VideoFile composes and runs ffmpeg for reverse + concat
  - GUI: Show-GUI (WinForms), Process-VideoFromGUI, Update-GUIStatus/Progress
- Launchers/usage: LoopVideo-GUI.bat, drag & drop onto loopvideo.ps1
- Samples: test.mp4 (input), test-looped.mp4 (example output)

## Processing pipeline
- Validate input file exists and extension is one of: .mp4, .mov, .avi, .mkv, .webm, .m4v, .flv, .wmv
- Probe duration via ffmpeg "Duration:" to estimate time and drive coarse progress
- FFmpeg composition (audio preserved):
  - Video: "[0:v]reverse[rv];[0:v][rv]concat=n=2:v=1:a=0[outv]"
  - Audio: "[0:a]areverse[ra];[0:a][ra]concat=n=2:v=0:a=1[outa]"
  - Encode: -c:v libx264 -preset <Quality> -crf 18 -pix_fmt yuv420p -c:a aac -b:a 192k
  - Map: -map "[outv]" -map "[outa]"
- Output naming: "<basename>-looped<ext>" unless -OutputFile is provided
- Overwrite safety: if output exists, prompt (GUI Yes/No; CLI Read-Host); ffmpeg uses -y only after confirmation

## Conventions and behaviors
- Quality presets: ultrafast…veryslow (default: medium); only -preset varies
- Console output uses ANSI color with graceful fallback to plain Write-Host
- GUI defaults: dark theme; success popups OFF by default (checkbox toggles showing them)
- Audio is always preserved; no -an path

## Developer workflows
- GUI
  - LoopVideo-GUI.bat
  - powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -GUI
  - Drag & drop a single supported file onto loopvideo.ps1
- CLI
  - powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile ".\test.mp4"
  - Options: -OutputFile ".\out\test-looped.mp4" -Quality fast
- Prerequisite: FFmpeg must be in PATH; script checks and provides install steps if missing

## Error handling and UX
- ffmpeg stderr redirected to a temp file; on failure, report exit code, stderr, and whether output was created; temp file is cleaned up
- Progress updates: coarse steps (10/20/30/50/100) with ETA derived from duration
- Cancel cleanly if overwrite declined

## File references
- loopvideo.ps1: validation, GUI, ffmpeg assembly/invocation, error reporting
- LoopVideo-GUI.bat: convenience launcher
- CLAUDE.md: narrative overview; keep aligned with this document when behavior changes

## Examples
- Fast preset with audio preserved:
  ```powershell
  powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile ".\test.mp4" -Quality fast
  ```
- Custom output path:
  ```powershell
  powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile ".\test.mp4" -OutputFile ".\output\test-looped.mp4"
  ```

## Gotchas
- Very short clips yield rough ETAs; processing still succeeds
- Windows Forms requires Windows (PowerShell 5.1 or PowerShell 7 on Windows with WinForms)
- If adding codecs (HEVC/AV1), verify reverse+concat compatibility and player support for pixel format

## Contributor tips
- When changing ffmpeg arguments, keep video and audio graphs in sync to maintain ping‑pong alignment
- Maintain supported extensions list in both Test-VideoFile and GUI labels
- Keep overwrite prompts unless adding an explicit non-interactive flag