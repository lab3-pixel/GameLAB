$scriptDir = $PSScriptRoot
$breakVbs = Join-Path $scriptDir "Run-ActiveBreak.vbs"
$taskName = "PausaActiva"

$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

Write-Host "Instalando tarea: $taskName (cada 2 horas)..."

Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$breakVbs`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 2) -RepetitionDuration (New-TimeSpan -Days 3650)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew

try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        Write-Host "  -> OK: '$taskName' creada correctamente."
        Write-Host ""
        Write-Host "Listo. Se activara cada 2 horas mientras tu sesion de Windows este iniciada."
        Write-Host "Para desinstalarla, ejecuta Desinstalar.bat"
    } else {
        Write-Host "  -> ERROR: no se encontro la tarea despues de crearla."
    }
} catch {
    Write-Host "  -> ERROR: $($_.Exception.Message)"
}
