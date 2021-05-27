function Get-PushoverStatus {
    <#
    .SYNOPSIS
        Gets the status of a Pushover notification using the receipt from Send-Pushover
    .DESCRIPTION
        When sending a Pushover notification with MessagePriority of 'Emergency', a receipt
        is returned. This receipt is a random string associated with the notification and
        can be used to check if and when the notification was delivered and acknowledged, or
        if it has expired and is no longer causing notifications to be sent to the user(s).

        When the notification is acknowledged, the user and device performing the acknowledgement
        will be included in the returned [PoshoverNotificationStatus] response.
    .EXAMPLE
        PS C:\> $receipt = Send-Pushover -Message 'Are we there yet?' -MessagePriority Emergency -Sound tugboat
        PS C:\> Get-PushoverStatus -Receipt $receipt
        Sends an emergency Pushover message and then uses the receipt to check the status of that notification.
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
        $Receipt
    )

    begin {
        $config = Get-PushoverConfig
        $uriBuilder = [uribuilder]($config.ApiUri + '/receipts')
    }

    process {
        if ($null -eq $Token) {
            $Token = $config.Token
            if ($null -eq $Token) {
                throw "Token not provided and no default application token has been set using Set-PushoverConfig."
            }
        }
        $uriBuilder.Path += "/$Receipt.json"
        $uriBuilder.Query = "token=" + ($Token | ConvertTo-PlainText)
        try {
            $uriBuilder.Query = "token=" + ($Token | ConvertTo-PlainText)
            $response = Invoke-RestMethod -Method Get -Uri $uriBuilder.Uri
        }
        catch {
            Write-Verbose 'Handling HTTP error in Invoke-RestMethod response'
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Verbose "HTTP status code $statusCode"
            if ($statusCode -lt 400 -or $statusCode -gt 499) {
                throw
            }

            try {
                Write-Verbose 'Parsing HTTP request error response'
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = [io.streamreader]::new($stream)
                $response = $reader.ReadToEnd() | ConvertFrom-Json
                if ([string]::IsNullOrWhiteSpace($response)) {
                    throw $_
                }
                Write-Verbose "Response body:`r`n$response"
            }
            finally {
                $reader.Dispose()
            }
        }

        if ($response.status -eq 1) {
            [PoshoverNotificationStatus]@{
                Receipt = $Receipt
                Acknowledged = [bool]$response.acknowledged
                AcknowledgedAt = [datetimeoffset]::FromUnixTimeSeconds($response.acknowledged_at).DateTime.ToLocalTime()
                AcknowledgedBy = $response.acknowledged_by
                AcknowledgedByDevice = $response.acknowledged_by_device
                LastDeliveredAt = [datetimeoffset]::FromUnixTimeSeconds($response.last_delivered_at).DateTime.ToLocalTime()
                Expired = [bool]$response.expired
                ExpiresAt = [datetimeoffset]::FromUnixTimeSeconds($response.expires_at).DateTime.ToLocalTime()
                CalledBack = [bool]$response.called_back
                CalledBackAt = [datetimeoffset]::FromUnixTimeSeconds($response.called_back_at).DateTime.ToLocalTime()
            }
        }
        else {
            if ($null -ne $response.error) {
                Write-Error $response.error
            }
            elseif ($null -ne $response.errors) {
                foreach ($problem in $response.errors) {
                    Write-Error $problem
                }
            }
            else {
                $response
            }
        }
    }
}