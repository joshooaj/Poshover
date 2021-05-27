function Wait-Pushover {
    <#
    .SYNOPSIS
        Waits for a user to acknowledge receipt of the Pushover message or for the notification to expire
    .DESCRIPTION
        Waits for a user to acknowledge receipt of the Pushover message or for the notification to expire
        then returns the last [PoshoverNotificationStatus] response object.
    .EXAMPLE
        PS C:\> Send-Pushover -Message 'Please clap' -MessagePriority Emergency | Wait-Pushover
        Sends an emergency Pushover notification and then waits for the notification to expire or for at least one user to acknowledge it.
    #>
    [CmdletBinding()]
    [OutputType([PoshoverNotificationStatus])]
    param (
        # Specifies the Pushover application API token/key.
        # Note: The default value will be used if it has been previously set with Set-PushoverConfig
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [securestring]
        $Token,

        # Specifies the receipt received from emergency notifications sent using Send-Pushover
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Receipt,

        # Specifies the interval between each Pushover API request for receipt status
        [Parameter()]
        [ValidateRange(5, 10800)]
        [int]
        $Interval = 10
    )

    begin {
        $config = Get-PushoverConfig
    }

    process {
        if ($null -eq $Token) {
            $Token = $config.Token
            if ($null -eq $Token) {
                throw "Token not provided and no default application token has been set using Set-PushoverConfig."
            }
        }

        $timeoutAt = (Get-Date).AddHours(3)
        while ((Get-Date) -lt $timeoutAt.AddSeconds($Interval)) {
            $status = Get-PushoverStatus -Token $Token -Receipt $Receipt -ErrorAction Stop
            $timeoutAt = $status.ExpiresAt
            if ($status.Acknowledged -or $status.Expired) {
                break
            }
            Start-Sleep -Seconds $Interval
        }
        Write-Output $status
    }
}