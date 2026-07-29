Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function New-RoundedPath([int]$width, [int]$height, [int]$radius) {
    $path = New-Object Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc(0, 0, $d, $d, 180, 90)
    $path.AddArc($width - $d, 0, $d, $d, 270, 90)
    $path.AddArc($width - $d, $height - $d, $d, $d, 0, 90)
    $path.AddArc(0, $height - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

$W = 380
$H = 260

$form = New-Object Windows.Forms.Form
$form.FormBorderStyle = 'None'
$form.Size = New-Object Drawing.Size($W, $H)
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.StartPosition = 'Manual'
$form.BackColor = [Drawing.Color]::FromArgb(14,22,40)

$screen = [Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$form.Location = New-Object Drawing.Point(($screen.Width - $W - 24), ($screen.Height - $H - 24))

$roundedPath = New-RoundedPath $W $H 24
$form.Region = New-Object Drawing.Region($roundedPath)

$dbFlag = [Reflection.BindingFlags]::SetProperty -bor [Reflection.BindingFlags]::Instance -bor [Reflection.BindingFlags]::NonPublic
$form.GetType().InvokeMember("DoubleBuffered", $dbFlag, $null, $form, @($true)) | Out-Null

$form.Add_Paint({
    param($s, $e)
    $rect = New-Object Drawing.Rectangle(0, 0, $W, $H)
    $brush = New-Object Drawing.Drawing2D.LinearGradientBrush($rect, [Drawing.Color]::FromArgb(56, 145, 255), [Drawing.Color]::FromArgb(15, 60, 168), 55)
    $e.Graphics.FillPath($brush, $roundedPath)
    $brush.Dispose()

    $glowRect = New-Object Drawing.Rectangle(-40, -60, 220, 220)
    $glowBrush = New-Object Drawing.Drawing2D.LinearGradientBrush($glowRect, [Drawing.Color]::FromArgb(60, 255, 255, 255), [Drawing.Color]::FromArgb(0, 255, 255, 255), 45)
    $e.Graphics.FillEllipse($glowBrush, $glowRect)
    $glowBrush.Dispose()
})

$icon = New-Object Windows.Forms.Label
$icon.Text = "💧"
$icon.Font = New-Object Drawing.Font("Segoe UI Emoji", 32)
$icon.ForeColor = [Drawing.Color]::White
$icon.BackColor = [Drawing.Color]::Transparent
$icon.AutoSize = $true
$icon.Location = New-Object Drawing.Point(28, 28)
$form.Controls.Add($icon)

$title = New-Object Windows.Forms.Label
$title.Text = "¡Hora de hidratarte!"
$title.Font = New-Object Drawing.Font("Segoe UI Semibold", 17, [Drawing.FontStyle]::Bold)
$title.ForeColor = [Drawing.Color]::White
$title.BackColor = [Drawing.Color]::Transparent
$title.AutoSize = $true
$title.Location = New-Object Drawing.Point(28, 100)
$form.Controls.Add($title)

$subtitle = New-Object Windows.Forms.Label
$subtitle.Text = "Un vaso de agua ahora le hace bien a tu cuerpo y tu mente."
$subtitle.Font = New-Object Drawing.Font("Segoe UI", 10)
$subtitle.ForeColor = [Drawing.Color]::FromArgb(225, 235, 255)
$subtitle.BackColor = [Drawing.Color]::Transparent
$subtitle.MaximumSize = New-Object Drawing.Size(320, 0)
$subtitle.AutoSize = $true
$subtitle.Location = New-Object Drawing.Point(28, 138)
$form.Controls.Add($subtitle)

$doneBtn = New-Object Windows.Forms.Button
$doneBtn.Text = "Ya tomé agua"
$doneBtn.Size = New-Object Drawing.Size(324, 46)
$doneBtn.Location = New-Object Drawing.Point(28, 186)
$doneBtn.FlatStyle = 'Flat'
$doneBtn.FlatAppearance.BorderSize = 0
$doneBtn.BackColor = [Drawing.Color]::White
$doneBtn.ForeColor = [Drawing.Color]::FromArgb(20, 80, 200)
$doneBtn.Font = New-Object Drawing.Font("Segoe UI Semibold", 11, [Drawing.FontStyle]::Bold)
$doneBtn.Cursor = [Windows.Forms.Cursors]::Hand
$doneBtn.Region = New-Object Drawing.Region((New-RoundedPath 324 46 23))
$doneBtn.FlatAppearance.MouseOverBackColor = [Drawing.Color]::FromArgb(230, 240, 255)
$doneBtn.FlatAppearance.MouseDownBackColor = [Drawing.Color]::FromArgb(210, 225, 255)
$form.Controls.Add($doneBtn)

$mp3Path = Join-Path $PSScriptRoot "Assets\gota.mp3"
$wavPath = Join-Path $PSScriptRoot "Assets\gota.wav"

$wmp = $null
$wavPlayer = $null
$beepTimer = $null

function Stop-Sound {
    if ($wmp) { try { $wmp.controls.stop() } catch {} }
    if ($wavPlayer) { try { $wavPlayer.Stop() } catch {} }
    if ($beepTimer) { try { $beepTimer.Stop() } catch {} }
}

$soundStarted = $false

if (Test-Path $mp3Path) {
    try {
        $wmp = New-Object -ComObject WMPlayer.OCX
        $wmp.URL = $mp3Path
        $wmp.settings.setMode("loop", $true)
        $wmp.controls.play()
        $soundStarted = $true
    } catch { $wmp = $null }
}

if (-not $soundStarted -and (Test-Path $wavPath)) {
    try {
        $wavPlayer = New-Object System.Media.SoundPlayer($wavPath)
        $wavPlayer.PlayLooping()
        $soundStarted = $true
    } catch { $wavPlayer = $null }
}

if (-not $soundStarted) {
    $beepTimer = New-Object Windows.Forms.Timer
    $beepTimer.Interval = 1500
    $beepTimer.Add_Tick({ try { [System.Media.SystemSounds]::Asterisk.Play() } catch {} })
    $beepTimer.Start()
    try { [System.Media.SystemSounds]::Asterisk.Play() } catch {}
}

$doneBtn.Add_Click({
    Stop-Sound
    $form.Close()
})
$form.Add_FormClosing({ Stop-Sound })

# Fade-in de entrada para un efecto mas moderno
$form.Opacity = 0
$fadeTimer = New-Object Windows.Forms.Timer
$fadeTimer.Interval = 15
$fadeTimer.Add_Tick({
    if ($form.Opacity -lt 1) {
        $form.Opacity = [Math]::Min(1, $form.Opacity + 0.08)
    } else {
        $fadeTimer.Stop()
    }
})

$form.Add_Shown({
    $form.Activate()
    $fadeTimer.Start()
})
[void]$form.ShowDialog()
