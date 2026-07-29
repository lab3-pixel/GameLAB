$scriptDir = $PSScriptRoot
$waterVbs = Join-Path $scriptDir "Run-WaterReminder.vbs"
$taskName = "RecordatorioAgua"

$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

Write-Host "Instalando tarea: $taskName (cada hora, de 8:00 a 17:00)..."

Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$waterVbs`""
# Un disparador diario independiente por cada hora, de 8:00 a 17:00 (mas simple y confiable
# que combinar -Daily con repeticion, que falla en algunas versiones de PowerShell).
$triggers = 8..17 | ForEach-Object { New-ScheduledTaskTrigger -Daily -At ([datetime]::Today.AddHours($_)) }
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew

try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Principal $principal -Settings $settings -Force | Out-Null
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        Write-Host "  -> OK: '$taskName' creada correctamente."
        Write-Host ""
        Write-Host "Listo. Sonara cada hora entre 8:00 am y 5:00 pm, todos los dias."
        Write-Host "Para desinstalarla, ejecuta Desinstalar.bat"
    } else {
        Write-Host "  -> ERROR: no se encontro la tarea despues de crearla."
    }
} catch {
    Write-Host "  -> ERROR: $($_.Exception.Message)"
}
