function Wait-Pushover {
    [CmdletBinding()]
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