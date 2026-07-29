Write-Host "Eliminando tarea 'PausaActiva'..."
Unregister-ScheduledTask -TaskName "PausaActiva" -Confirm:$false -ErrorAction SilentlyContinue
schtasks /delete /tn "PausaActiva" /f 2>$null | Out-Null
Write-Host "Listo."
