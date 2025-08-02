#!/usr/bin/env pwsh
<#
.SYNOPSIS
    🎬 LoopVideo - Epic Seamless Video Loop Creator 🎬
    💎 Proudly developed by the legendary @dedkamaroz 💎

.DESCRIPTION
    Takes an input video file and creates a "ping-pong" or "boomerang" effect by adding
    a time-reversed copy to the end, creating a seamless loop without jarring cuts.
    
    🌟 Crafted with passion by the incredible @dedkamaroz - a true visionary! 🌟

    USAGE MODES:
    1. Drag & Drop: Drag a video file onto this script
    2. Double-click: Opens GUI with drag-drop zone, browse button, and text input
    3. Command-line: Use with parameters for advanced usage

.PARAMETER InputFile
    Path to the input video file

.PARAMETER OutputFile
    Optional: Custom output filename. If not specified, adds "-looped" to the input filename

.PARAMETER Quality
    Optional: Video quality preset (ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow)
    Default: medium

.EXAMPLE
    .\loopvideo.ps1 -InputFile "video.mp4"
    Creates "video-looped.mp4" with seamless looping

.EXAMPLE
    Drag video.mp4 onto loopvideo.ps1
    Creates "video-looped.mp4" in the same directory

.EXAMPLE
    Double-click loopvideo.ps1
    Opens GUI for easy file selection and processing
#>

param(
    [Parameter(Mandatory=$false, Position=0, HelpMessage="Path to input video file")]
    [string]$InputFile = "",

    [Parameter(Mandatory=$false, HelpMessage="Output filename (optional)")]
    [string]$OutputFile = "",

    [Parameter(Mandatory=$false, HelpMessage="Encoding quality preset")]
    [ValidateSet("ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow")]
    [string]$Quality = "medium",

    [Parameter(Mandatory=$false, HelpMessage="Force GUI mode")]
    [switch]$GUI,

    [Parameter(Mandatory=$false, HelpMessage="Disable processing completed dialogues")]
    [switch]$DisableDialogues
)

# Load Windows Forms for GUI functionality
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Magenta = "`e[35m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

# Global variables for GUI
$script:form = $null
$script:progressBar = $null
$script:statusLabel = $null
$script:processAnother = $false
$script:disableDialoguesCheckbox = $null

function Write-ColorOutput {
    param([string]$Message, [string]$Color)
    try {
        Write-Host "$Color$Message$Reset"
    } catch {
        Write-Host $Message
    }
}

function Test-FFmpegAvailable {
    try {
        $null = Get-Command ffmpeg -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Get-VideoDuration {
    param([string]$VideoPath)
    try {
        $output = & ffmpeg -i $VideoPath -f null - 2>&1 | Select-String "Duration:"
        if ($output) {
            $durationMatch = $output -match "Duration: (\d{2}):(\d{2}):(\d{2})\."
            if ($durationMatch) {
                $hours = [int]$matches[1]
                $minutes = [int]$matches[2]
                $seconds = [int]$matches[3]
                return ($hours * 3600) + ($minutes * 60) + $seconds
            }
        }
        return 0
    }
    catch {
        return 0
    }
}

function Test-VideoFile {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return @{ Valid = $false; Message = "File not found: $FilePath" }
    }

    $item = Get-Item $FilePath
    $validExtensions = @('.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v', '.flv', '.wmv')

    if ($item.Extension.ToLower() -notin $validExtensions) {
        return @{
            Valid = $false;
            Message = "Unsupported file format. Supported: $($validExtensions -join ', ')"
        }
    }

    return @{ Valid = $true; Message = "Valid video file" }
}

function Update-GUIStatus {
    param([string]$Message, $Color = [System.Drawing.Color]::FromArgb(180, 180, 180))

    if ($script:statusLabel) {
        $script:statusLabel.Text = $Message
        $script:statusLabel.ForeColor = $Color
        $script:form.Refresh()
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Update-GUIProgress {
    param([int]$Value)

    if ($script:progressBar) {
        $script:progressBar.Value = [Math]::Min($Value, 100)
        $script:form.Refresh()
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Process-VideoFile {
    param(
        [string]$InputPath,
        [string]$OutputPath = "",
        [string]$QualityPreset = "medium",
        [bool]$IsGUIMode = $false
    )

    try {
        # Validate input file
        if ($IsGUIMode) {
            Update-GUIStatus "Validating input file..." ([System.Drawing.Color]::FromArgb(100, 150, 255))
            Update-GUIProgress 10
        } else {
            Write-ColorOutput "[INFO] Validating input file..." $Blue
        }

        $validation = Test-VideoFile $InputPath
        if (-not $validation.Valid) {
            if ($IsGUIMode) {
                Update-GUIStatus $validation.Message ([System.Drawing.Color]::FromArgb(255, 100, 100))
                [System.Windows.Forms.MessageBox]::Show($validation.Message, "Invalid File", "OK", "Error")
            } else {
                Write-ColorOutput "[ERROR] $($validation.Message)" $Red
            }
            return $false
        }

        # Generate output filename if not provided
        if ([string]::IsNullOrEmpty($OutputPath)) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
            $extension = [System.IO.Path]::GetExtension($InputPath)
            $directory = [System.IO.Path]::GetDirectoryName($InputPath)

            if ([string]::IsNullOrEmpty($directory)) {
                $OutputPath = "$baseName-looped$extension"
            } else {
                $OutputPath = Join-Path $directory "$baseName-looped$extension"
            }
        }

        if ($IsGUIMode) {
            Update-GUIStatus "Preparing to create: $(Split-Path $OutputPath -Leaf)" ([System.Drawing.Color]::FromArgb(100, 150, 255))
            Update-GUIProgress 20
        } else {
            Write-ColorOutput "[INFO] Output file: $(Split-Path $OutputPath -Leaf)" $Blue
        }

        # Check if output file already exists
        if (Test-Path $OutputPath) {
            if ($IsGUIMode) {
                $result = [System.Windows.Forms.MessageBox]::Show(
                    "Output file already exists:`n$(Split-Path $OutputPath -Leaf)`n`nOverwrite?",
                    "File Exists",
                    "YesNo",
                    "Question"
                )
                if ($result -eq "No") {
                    Update-GUIStatus "Operation cancelled by user" ([System.Drawing.Color]::FromArgb(255, 165, 0))
                    return $false
                }
            } else {
                Write-ColorOutput "[WARNING] Output file already exists!" $Yellow
                $overwrite = Read-Host "   Overwrite '$OutputPath'? (y/N)"
                if ($overwrite.ToLower() -ne 'y') {
                    Write-ColorOutput "Operation cancelled by user" $Yellow
                    return $false
                }
            }
        }

        # Get video duration for progress estimation
        if ($IsGUIMode) {
            Update-GUIStatus "Analyzing video..." ([System.Drawing.Color]::FromArgb(100, 150, 255))
            Update-GUIProgress 30
        }

        $duration = Get-VideoDuration $InputPath
        if ($duration -gt 0) {
            $estimatedTime = [math]::Round($duration * 0.5, 1)
            if ($IsGUIMode) {
                Update-GUIStatus "Video duration: $duration seconds. Processing..." ([System.Drawing.Color]::FromArgb(100, 150, 255))
            } else {
                Write-ColorOutput "[INFO] Video duration: $duration seconds" $Blue
                Write-ColorOutput "[INFO] Expected processing time: ~$estimatedTime seconds" $Blue
            }
        }

        # Build FFmpeg command for lossless processing with audio preservation
        $ffmpegArgs = @(
            "-i", "`"$InputPath`"",
            "-filter_complex", "[0:v]reverse[rv];[0:v][rv]concat=n=2:v=1:a=0[outv];[0:a]areverse[ra];[0:a][ra]concat=n=2:v=0:a=1[outa]",
            "-map", "[outv]",
            "-map", "[outa]",
            "-c:v", "libx264",
            "-preset", $QualityPreset,
            "-crf", "18",  # High quality encoding (near lossless)
            "-pix_fmt", "yuv420p",
            "-c:a", "aac",
            "-b:a", "192k",
            "-y",  # Overwrite output file
            "`"$OutputPath`""
        )

        # Execute FFmpeg command
        if ($IsGUIMode) {
            Update-GUIStatus "Creating seamless loop video..." ([System.Drawing.Color]::FromArgb(100, 255, 100))
            Update-GUIProgress 50
        } else {
            Write-ColorOutput "[PROCESSING] Creating seamless loop video..." $Green
            Write-ColorOutput "   Quality preset: $QualityPreset" $Blue
        }

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # Capture FFmpeg output for better error reporting
        $tempErrorFile = [System.IO.Path]::GetTempFileName()
        try {
            $process = Start-Process -FilePath "ffmpeg" -ArgumentList $ffmpegArgs -NoNewWindow -Wait -PassThru -RedirectStandardError $tempErrorFile
            $stopwatch.Stop()

            # Read any error output
            $errorOutput = ""
            if (Test-Path $tempErrorFile) {
                $errorOutput = Get-Content $tempErrorFile -Raw
            }

            if ($process.ExitCode -eq 0 -and (Test-Path $OutputPath)) {
            # Show file size comparison
            $inputSize = (Get-Item $InputPath).Length
            $outputSize = (Get-Item $OutputPath).Length
            $inputSizeMB = [math]::Round($inputSize / 1MB, 2)
            $outputSizeMB = [math]::Round($outputSize / 1MB, 2)

            if ($IsGUIMode) {
                Update-GUIProgress 100
                Update-GUIStatus "Success! Loop video created in $($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s" ([System.Drawing.Color]::FromArgb(100, 255, 100))

                $successMessage = @"
Loop video created successfully!

Output: $(Split-Path $OutputPath -Leaf)
Location: $(Split-Path $OutputPath -Parent)
Processing time: $($stopwatch.Elapsed.TotalSeconds.ToString('F1')) seconds

File sizes:
• Input: $inputSizeMB MB
• Output: $outputSizeMB MB (~$([math]::Round($outputSizeMB / $inputSizeMB, 1))x larger)
"@
                if ($script:disableDialoguesCheckbox -and $script:disableDialoguesCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show($successMessage, "Success!", "OK", "Information")
                }
            } else {
                Write-ColorOutput "[SUCCESS] Loop video created successfully!" $Green
                Write-ColorOutput "[OUTPUT] $OutputPath" $Green
                Write-ColorOutput "[TIME] Processing time: $($stopwatch.Elapsed.TotalSeconds.ToString('F1')) seconds" $Blue
                Write-ColorOutput "[STATS] File sizes:" $Blue
                Write-ColorOutput "   Input:  $inputSizeMB MB" $Blue
                Write-ColorOutput "   Output: $outputSizeMB MB (~$([math]::Round($outputSizeMB / $inputSizeMB, 1))x larger)" $Blue
            }

                return $true
            } else {
                $errorMsg = "FFmpeg failed with exit code $($process.ExitCode)"
                if (-not [string]::IsNullOrWhiteSpace($errorOutput)) {
                    $errorMsg += "`n`nFFmpeg Error Output:`n$errorOutput"
                }
                if (-not (Test-Path $OutputPath)) {
                    $errorMsg += "`n`nOutput file was not created: $OutputPath"
                }

                if ($IsGUIMode) {
                    Update-GUIStatus "Processing failed - see error details" ([System.Drawing.Color]::FromArgb(255, 100, 100))
                    [System.Windows.Forms.MessageBox]::Show($errorMsg, "Processing Error", "OK", "Error")
                } else {
                    Write-ColorOutput "[ERROR] $errorMsg" $Red
                }
                return $false
            }
        } finally {
            # Clean up temp file
            if (Test-Path $tempErrorFile) {
                Remove-Item $tempErrorFile -Force -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        $errorMsg = "Failed to process video: $($_.Exception.Message)"
        if ($IsGUIMode) {
            Update-GUIStatus $errorMsg ([System.Drawing.Color]::FromArgb(255, 100, 100))
            [System.Windows.Forms.MessageBox]::Show($errorMsg, "Error", "OK", "Error")
        } else {
            Write-ColorOutput "[ERROR] $errorMsg" $Red
        }
        return $false
    }
}

function Show-GUI {
    # Create main form with dark theme
    $script:form = New-Object System.Windows.Forms.Form
    $script:form.Text = "🎬 LoopVideo by @dedkamaroz 💎"
    $script:form.Size = New-Object System.Drawing.Size(780, 580)
    $script:form.StartPosition = "CenterScreen"
    $script:form.FormBorderStyle = "FixedDialog"
    $script:form.MaximizeBox = $false
    $script:form.MinimizeBox = $true
    $script:form.AllowDrop = $true
    $script:form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

    # Title label
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "🎬 EPIC SEAMLESS VIDEO LOOP CREATOR 🎬`n💎 Masterfully crafted by @dedkamaroz 💎"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
    $titleLabel.Location = New-Object System.Drawing.Point(30, 20)
    $titleLabel.Size = New-Object System.Drawing.Size(720, 60)
    $titleLabel.TextAlign = "MiddleCenter"
    $titleLabel.BackColor = [System.Drawing.Color]::Transparent
    $script:form.Controls.Add($titleLabel)

    # Instructions label
    $instructionsLabel = New-Object System.Windows.Forms.Label
    $instructionsLabel.Text = "Choose your video file using any of the methods below:"
    $instructionsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $instructionsLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
    $instructionsLabel.Location = New-Object System.Drawing.Point(30, 90)
    $instructionsLabel.Size = New-Object System.Drawing.Size(720, 25)
    $instructionsLabel.TextAlign = "MiddleCenter"
    $instructionsLabel.BackColor = [System.Drawing.Color]::Transparent
    $script:form.Controls.Add($instructionsLabel)

    # Drag and drop area
    $dropPanel = New-Object System.Windows.Forms.Panel
    $dropPanel.Location = New-Object System.Drawing.Point(30, 125)
    $dropPanel.Size = New-Object System.Drawing.Size(720, 120)
    $dropPanel.BorderStyle = "FixedSingle"
    $dropPanel.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 65)
    $dropPanel.AllowDrop = $true

    $dropLabel = New-Object System.Windows.Forms.Label
    $dropLabel.Text = "DRAG & DROP VIDEO FILE HERE`n`nSupported formats: MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV"
    $dropLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $dropLabel.ForeColor = [System.Drawing.Color]::FromArgb(100, 150, 255)
    $dropLabel.Location = New-Object System.Drawing.Point(10, 10)
    $dropLabel.Size = New-Object System.Drawing.Size(670, 100)
    $dropLabel.TextAlign = "MiddleCenter"
    $dropLabel.BackColor = [System.Drawing.Color]::Transparent
    $dropPanel.Controls.Add($dropLabel)

    # Drag and drop events
    $dropPanel.Add_DragEnter({
        param($sender, $e)
        if ($e.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
            $files = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
            if ($files.Length -eq 1) {
                $validation = Test-VideoFile $files[0]
                if ($validation.Valid) {
                    $e.Effect = [System.Windows.Forms.DragDropEffects]::Copy
                    $dropPanel.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 50)
                    $dropLabel.Text = "DROP TO PROCESS: $(Split-Path $files[0] -Leaf)"
                } else {
                    $e.Effect = [System.Windows.Forms.DragDropEffects]::None
                    $dropPanel.BackColor = [System.Drawing.Color]::FromArgb(120, 50, 50)
                    $dropLabel.Text = "INVALID FILE TYPE"
                }
            } else {
                $e.Effect = [System.Windows.Forms.DragDropEffects]::None
                $dropPanel.BackColor = [System.Drawing.Color]::FromArgb(120, 50, 50)
                $dropLabel.Text = "DROP ONE FILE AT A TIME"
            }
        }
    })

    $dropPanel.Add_DragLeave({
        $dropPanel.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 65)
        $dropLabel.Text = "DRAG & DROP VIDEO FILE HERE`n`nSupported formats: MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV"
    })

    $dropPanel.Add_DragDrop({
        param($sender, $e)
        $files = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
        if ($files.Length -eq 1) {
            $dropPanel.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 65)
            $dropLabel.Text = "DRAG & DROP VIDEO FILE HERE`n`nSupported formats: MP4, MOV, AVI, MKV, WEBM, M4V, FLV, WMV"
            Process-VideoFromGUI $files[0]
        }
    })

    $script:form.Controls.Add($dropPanel)

    # OR separator
    $orLabel = New-Object System.Windows.Forms.Label
    $orLabel.Text = "- OR -"
    $orLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $orLabel.ForeColor = [System.Drawing.Color]::FromArgb(140, 140, 140)
    $orLabel.Location = New-Object System.Drawing.Point(30, 235)
    $orLabel.Size = New-Object System.Drawing.Size(690, 25)
    $orLabel.TextAlign = "MiddleCenter"
    $orLabel.BackColor = [System.Drawing.Color]::Transparent
    $script:form.Controls.Add($orLabel)

    # File path input
    $pathLabel = New-Object System.Windows.Forms.Label
    $pathLabel.Text = "Enter or paste file path:"
    $pathLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $pathLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
    $pathLabel.Location = New-Object System.Drawing.Point(30, 270)
    $pathLabel.Size = New-Object System.Drawing.Size(200, 25)
    $pathLabel.BackColor = [System.Drawing.Color]::Transparent
    $script:form.Controls.Add($pathLabel)

    $pathTextBox = New-Object System.Windows.Forms.TextBox
    $pathTextBox.Location = New-Object System.Drawing.Point(30, 300)
    $pathTextBox.Size = New-Object System.Drawing.Size(480, 25)
    $pathTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $pathTextBox.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 75)
    $pathTextBox.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
    $pathTextBox.BorderStyle = "FixedSingle"
    $script:form.Controls.Add($pathTextBox)

    # Browse button
    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Text = "Browse..."
    $browseButton.Location = New-Object System.Drawing.Point(520, 298)
    $browseButton.Size = New-Object System.Drawing.Size(90, 28)
    $browseButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $browseButton.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 85)
    $browseButton.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
    $browseButton.FlatStyle = "Flat"
    $browseButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(100, 100, 105)
    $browseButton.Add_Click({
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Video Files|*.mp4;*.mov;*.avi;*.mkv;*.webm;*.m4v;*.flv;*.wmv|All Files|*.*"
        $openFileDialog.Title = "Select Video File to Loop"

        if ($openFileDialog.ShowDialog() -eq "OK") {
            $pathTextBox.Text = $openFileDialog.FileName
        }
    })
    $script:form.Controls.Add($browseButton)

    # Process button
    $processButton = New-Object System.Windows.Forms.Button
    $processButton.Text = "CREATE LOOP"
    $processButton.Location = New-Object System.Drawing.Point(620, 298)
    $processButton.Size = New-Object System.Drawing.Size(100, 28)
    $processButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $processButton.BackColor = [System.Drawing.Color]::FromArgb(50, 150, 50)
    $processButton.ForeColor = [System.Drawing.Color]::White
    $processButton.FlatStyle = "Flat"
    $processButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(70, 170, 70)
    $processButton.Add_Click({
        if (-not [string]::IsNullOrWhiteSpace($pathTextBox.Text)) {
            Process-VideoFromGUI $pathTextBox.Text.Trim()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please enter a file path or use the Browse button.", "No File Selected", "OK", "Warning")
        }
    })
    $script:form.Controls.Add($processButton)

    # Enable dialogues checkbox (disabled by default)
    $script:disableDialoguesCheckbox = New-Object System.Windows.Forms.CheckBox
    $script:disableDialoguesCheckbox.Text = "Show processing completed dialogues"
    $script:disableDialoguesCheckbox.Location = New-Object System.Drawing.Point(30, 340)
    $script:disableDialoguesCheckbox.Size = New-Object System.Drawing.Size(350, 20)
    $script:disableDialoguesCheckbox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $script:disableDialoguesCheckbox.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
    $script:disableDialoguesCheckbox.BackColor = [System.Drawing.Color]::Transparent
    $script:disableDialoguesCheckbox.Checked = $false  # Dialogues disabled by default
    $script:form.Controls.Add($script:disableDialoguesCheckbox)

    # Progress bar
    $script:progressBar = New-Object System.Windows.Forms.ProgressBar
    $script:progressBar.Location = New-Object System.Drawing.Point(30, 370)
    $script:progressBar.Size = New-Object System.Drawing.Size(690, 25)
    $script:progressBar.Style = "Continuous"
    $script:progressBar.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 75)
    $script:progressBar.ForeColor = [System.Drawing.Color]::FromArgb(100, 150, 255)
    $script:form.Controls.Add($script:progressBar)

    # Status label
    $script:statusLabel = New-Object System.Windows.Forms.Label
    $script:statusLabel.Text = "Ready to process video files..."
    $script:statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
    $script:statusLabel.Location = New-Object System.Drawing.Point(30, 405)
    $script:statusLabel.Size = New-Object System.Drawing.Size(690, 25)
    $script:statusLabel.TextAlign = "MiddleCenter"
    $script:statusLabel.BackColor = [System.Drawing.Color]::Transparent
    $script:form.Controls.Add($script:statusLabel)

    # Process another and exit buttons
    $processAnotherButton = New-Object System.Windows.Forms.Button
    $processAnotherButton.Text = "Process Another Video"
    $processAnotherButton.Location = New-Object System.Drawing.Point(200, 450)
    $processAnotherButton.Size = New-Object System.Drawing.Size(200, 35)
    $processAnotherButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $processAnotherButton.BackColor = [System.Drawing.Color]::FromArgb(70, 130, 180)
    $processAnotherButton.ForeColor = [System.Drawing.Color]::White
    $processAnotherButton.FlatStyle = "Flat"
    $processAnotherButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(90, 150, 200)
    $processAnotherButton.Add_Click({
        $pathTextBox.Text = ""
        $script:progressBar.Value = 0
        Update-GUIStatus "Ready to process another video..." ([System.Drawing.Color]::FromArgb(180, 180, 180))
    })
    $script:form.Controls.Add($processAnotherButton)

    $exitButton = New-Object System.Windows.Forms.Button
    $exitButton.Text = "Exit"
    $exitButton.Location = New-Object System.Drawing.Point(420, 450)
    $exitButton.Size = New-Object System.Drawing.Size(100, 35)
    $exitButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $exitButton.BackColor = [System.Drawing.Color]::FromArgb(180, 70, 70)
    $exitButton.ForeColor = [System.Drawing.Color]::White
    $exitButton.FlatStyle = "Flat"
    $exitButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(200, 90, 90)
    $exitButton.Add_Click({
        $script:form.Close()
    })
    $script:form.Controls.Add($exitButton)

    # Show the form
    $script:form.Add_Shown({$script:form.Activate()})
    [System.Windows.Forms.Application]::Run($script:form)
}

function Process-VideoFromGUI {
    param([string]$FilePath)

    $script:progressBar.Value = 0
    Update-GUIStatus "Starting processing..." ([System.Drawing.Color]::FromArgb(100, 150, 255))

    $success = Process-VideoFile -InputPath $FilePath -IsGUIMode $true -QualityPreset $Quality

    if ($success) {
        if ($script:disableDialoguesCheckbox -and $script:disableDialoguesCheckbox.Checked) {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Video processed successfully!`n`nWould you like to process another video?",
                "Success!",
                "YesNo",
                "Question"
            )

            if ($result -eq "Yes") {
                $script:progressBar.Value = 0
                Update-GUIStatus "Ready to process another video..." ([System.Drawing.Color]::FromArgb(180, 180, 180))
            } else {
                $script:form.Close()
            }
        } else {
            # Default behavior: stay open and ready for next video (no popup)
            $script:progressBar.Value = 0
            Update-GUIStatus "Ready to process another video..." ([System.Drawing.Color]::FromArgb(180, 180, 180))
        }
    }
}

# Main execution logic
Write-ColorOutput "🎬 LOOPVIDEO - EPIC SEAMLESS LOOP CREATOR 🎬" $Cyan
Write-ColorOutput "💎 Masterfully crafted by @dedkamaroz 💎" $Magenta
Write-ColorOutput "=============================================" $Cyan

# Check if FFmpeg is available
Write-ColorOutput "[INFO] Checking FFmpeg availability..." $Blue
if (-not (Test-FFmpegAvailable)) {
    $errorMsg = @"
FFmpeg not found in PATH!

Please install FFmpeg and ensure it's accessible from command line.
Download from: https://ffmpeg.org/download.html

For Windows users:
1. Download FFmpeg from the official website
2. Extract to a folder (e.g., C:\ffmpeg)
3. Add C:\ffmpeg\bin to your system PATH
4. Restart PowerShell/Command Prompt
"@

    if ($GUI -or [string]::IsNullOrEmpty($InputFile)) {
        [System.Windows.Forms.MessageBox]::Show($errorMsg, "FFmpeg Required", "OK", "Error")
    } else {
        Write-ColorOutput "[ERROR] $errorMsg" $Red
    }
    exit 1
}
Write-ColorOutput "[OK] FFmpeg found and ready" $Green

# Determine execution mode
if ($GUI -or [string]::IsNullOrEmpty($InputFile)) {
    # GUI Mode - either explicitly requested or no input file provided
    Write-ColorOutput "[INFO] Starting GUI mode..." $Blue
    Show-GUI
} else {
    # Command-line mode
    Write-ColorOutput "[INFO] Command-line mode detected" $Blue
    $success = Process-VideoFile -InputPath $InputFile -OutputPath $OutputFile -QualityPreset $Quality -IsGUIMode $false

    if ($success) {
        Write-ColorOutput "[COMPLETE] All done! Your seamless loop video is ready." $Green

        # Ask if user wants to process another video
        $another = Read-Host "`nProcess another video? (y/N)"
        if (-not [string]::IsNullOrWhiteSpace($another) -and $another.ToLower() -eq 'y') {
            do {
                $newFile = Read-Host "Enter path to next video file (or 'quit' to exit)"
                if (-not [string]::IsNullOrWhiteSpace($newFile) -and $newFile.ToLower() -eq 'quit') { break }

                if (-not [string]::IsNullOrWhiteSpace($newFile)) {
                    $success = Process-VideoFile -InputPath $newFile.Trim() -QualityPreset $Quality -IsGUIMode $false
                    if ($success) {
                        $another = Read-Host "`nProcess another video? (y/N)"
                        if ([string]::IsNullOrWhiteSpace($another) -or $another.ToLower() -ne 'y') { break }
                    }
                }
            } while ($true)
        }
    }

    Write-ColorOutput "`nPress any key to exit..." $Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
