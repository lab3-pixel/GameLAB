Write-Host "Eliminando tarea 'RecordatorioAgua'..."
Unregister-ScheduledTask -TaskName "RecordatorioAgua" -Confirm:$false -ErrorAction SilentlyContinue
schtasks /delete /tn "RecordatorioAgua" /f 2>$null | Out-Null
Write-Host "Listo."
