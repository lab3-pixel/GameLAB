Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = "¡Pausa activa!"
$form.Size = New-Object Drawing.Size(480,340)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedToolWindow'
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.BackColor = [Drawing.Color]::FromArgb(255,140,0)

$titleLabel = New-Object Windows.Forms.Label
$titleLabel.Text = "¡Es hora de movernos!"
$titleLabel.Font = New-Object Drawing.Font("Segoe UI",18,[Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [Drawing.Color]::White
$titleLabel.TextAlign = 'MiddleCenter'
$titleLabel.Dock = 'Top'
$titleLabel.Height = 55
$form.Controls.Add($titleLabel)

$exercises = @(
    "Estira los brazos hacia arriba",
    "Gira el cuello suavemente",
    "Ponte de pie y camina un poco",
    "Haz 10 sentadillas",
    "Estira la espalda",
    "Sacude las manos y los pies",
    "Haz 10 saltos suaves"
)
$subLabel = New-Object Windows.Forms.Label
$subLabel.Text = $exercises[(Get-Random -Minimum 0 -Maximum $exercises.Count)]
$subLabel.Font = New-Object Drawing.Font("Segoe UI",12)
$subLabel.ForeColor = [Drawing.Color]::White
$subLabel.TextAlign = 'MiddleCenter'
$subLabel.Dock = 'Bottom'
$subLabel.Height = 45
$form.Controls.Add($subLabel)

$closeBtn = New-Object Windows.Forms.Button
$closeBtn.Text = "¡Listo, ya me moví! 💪"
$closeBtn.Dock = 'Bottom'
$closeBtn.Height = 40
$closeBtn.Add_Click({ $form.Close() })
$form.Controls.Add($closeBtn)

$mover = New-Object Windows.Forms.Label
$frames = @("🏃","🤸","🧘","🚶","🤾","🕺")
$script:frameIndex = 0
$mover.Text = $frames[0]
$mover.Font = New-Object Drawing.Font("Segoe UI Emoji",44)
$mover.AutoSize = $true
$mover.BackColor = [Drawing.Color]::Transparent
$form.Controls.Add($mover)
$mover.BringToFront()
$mover.Location = New-Object Drawing.Point(40,110)

$script:dx = 7
$script:dy = 5

$moveTimer = New-Object Windows.Forms.Timer
$moveTimer.Interval = 50
$moveTimer.Add_Tick({
    $top = 60
    $bottom = $form.ClientSize.Height - 90
    $right = $form.ClientSize.Width

    $newX = $mover.Left + $script:dx
    $newY = $mover.Top + $script:dy

    if ($newX -le 0 -or ($newX + $mover.Width) -ge $right) {
        $script:dx = -$script:dx
        $script:frameIndex = ($script:frameIndex + 1) % $frames.Count
        $mover.Text = $frames[$script:frameIndex]
    }
    if ($newY -le $top -or ($newY + $mover.Height) -ge $bottom) {
        $script:dy = -$script:dy
        $script:frameIndex = ($script:frameIndex + 1) % $frames.Count
        $mover.Text = $frames[$script:frameIndex]
    }

    $mover.Left = $mover.Left + $script:dx
    $mover.Top = $mover.Top + $script:dy
})
$moveTimer.Start()

$closeTimer = New-Object Windows.Forms.Timer
$closeTimer.Interval = 30000
$closeTimer.Add_Tick({ $closeTimer.Stop(); $form.Close() })
$closeTimer.Start()

try { [System.Media.SystemSounds]::Exclamation.Play() } catch {}

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
