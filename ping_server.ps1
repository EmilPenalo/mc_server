# The name of the Java program to search for
$javaProgram = "fabric-server-launch.jar"

# Get all Java processes (assuming java.exe is the executable)
$javaProcesses = Get-CimInstance Win32_Process -Filter "Name = 'java.exe'"

# Find the Java process running the specified program
$javaProcess = $javaProcesses | Where-Object {
    $_.CommandLine -match [regex]::Escape($javaProgram)
}

# Check if the process is found
if ($javaProcess) {
    $pid = $javaProcess.ProcessId
    Write-Host "[INFO] Found Java process running '$javaProgram' with PID: $pid"

    # Assuming you want to send commands to a server running in this process:
    # Note: For Minecraft or similar servers, you usually interact with the process via its standard input/output or through a dedicated console.

    # Here, you could try to interact with the process if it exposes a standard input/output
    # However, without specific access to the Java process's console, you might need to send commands another way
    # For example, if the server has a rcon or other remote control mechanism, use that instead

    # Example: Starting a new process to interact with it
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true

    $p = [System.Diagnostics.Process]::Start($psi)
    Start-Sleep -Seconds 2  # Wait for the process to be up and running

    Write-Host "[INFO] Sending 'say TEST' command to the server every 5 seconds."

    while ($true) {
        Write-Host "[INFO] Pinging server..."
        $p.StandardInput.WriteLine("say TEST")
        Start-Sleep -Seconds 5
    }
} else {
    Write-Host "[ERROR] Could not find a Java process running '$javaProgram'."
    exit 1
}
