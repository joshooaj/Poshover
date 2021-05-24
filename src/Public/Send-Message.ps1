function Send-Message {
    <#
    .SYNOPSIS
        Sends a message to the PushOver API
    .EXAMPLE
        PS C:\> Send-PushOverMessage -Token $token -User $user -Title 'What time is it?' -Message 'It''s time for lunch'
        Sends a notification to the user or group specified in the $user string variable, from the application designed by the application API token value in $token
    .EXAMPLE
        PS C:\> Send-PushOverMessage -Token $token -User $user -Title 'What time is it?' -Message 'It''s time for lunch' -MessagePriority Emergency -RetryInterval (New-TimeSpan -Seconds 60) -ExpireAfter (New-TimeSpan -Hours 1)
        Sends the same notification as Example 1, except with emergency priority which results in the notification being repeated every 60 seconds, until an hour has passed or the message has been acknowledged.
    .OUTPUTS
        Returns a receipt string if the MessagePriority value was 'Emergency' (2)
    #>
    [CmdletBinding()]
    param (
        # Specifies the application API token/key from which the PushOver notification should be sent.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Token,

        # Specifies the User or Group identifier to which the PushOver message should be sent.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $User,

        # Optionally specifies one or more devices to which notifications should be sent. Useful for sending notifications to a targetted device instead of all of the user's devices.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Device,

        # Specifies the title of the PushOver notification. The default will be the application name configured for the application API token supplied.
        [Parameter()]
        [string]
        $Title,

        # Specifies the message to be sent with the PushOver notification.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        # Optionally specifies a supplementary URL associated with the message.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [uri]
        $Url,

        # Optionally specifies a title for the supplementary URL if specified.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $UrlTitle,

        # Parameter help description
        [Parameter()]
        [MessagePriority]
        $MessagePriority,

        # Specifies the interval between emergency PushOver notifications. PushOver will retry until the message is acknowledged, or expired. Valid only with MessagePriority of 'Emergency'.
        [Parameter()]
        [ValidateScript({
            if ($_.TotalSeconds -lt 30) {
                throw 'RetryInterval must be at least 30 seconds'
            }
            if ($_.TotalSeconds -gt 10800) {
                throw 'RetryInterval cannot exceed maximum ExpireAfter value of 3 hours'
            }
            $true
        })]
        [timespan]
        $RetryInterval = (New-TimeSpan -Minutes 1),

        # Specifies the amount of time unacknowledged notifications will be retried before PushOver stops sending notifications. Valid only with MessagePriority of 'Emergency'.
        [Parameter()]
        [ValidateScript({
            if ($_.TotalSeconds -le 30) {
                throw 'ExpireAfter must be greater than the minimum RetryInterval value of 30 seconds'
            }
            if ($_.TotalSeconds -gt 10800) {
                throw 'ExpireAfter cannot exceed 3 hours'
            }
            $true
        })]
        [timespan]
        $ExpireAfter = (New-TimeSpan -Minutes 10),

        # Optionally specifies the timestamp associated with the message. Default is DateTime.Now.
        [Parameter()]
        [datetime]
        $Timestamp = (Get-Date),

        # Optionally specifies one or more tags to associate with the PushOver notification. Tags can be used to cancel emergency notifications in bulk.
        [Parameter()]
        [string[]]
        $Tags
    )

    process {
        $uri = [uri]"$($script:BaseUri)/messages.json"

        $deviceList = if ($null -ne $Device) {
            [string]::Join(',', $Device)
        } else { $null }

        $tagList = if ($null -ne $Tags) {
            [string]::Join(',', $Tags)
        } else { $null }

        $body = @{
            token = $Token
            user = $User
            device = $deviceList
            title = $Title
            message = $Message
            url = $Url
            url_title = $UrlTitle
            priority = $MessagePriority
            retry = [int]$RetryInterval.TotalSeconds
            expire = [int]$ExpireAfter.TotalSeconds
            timestamp = [int]([datetimeoffset]::new($Timestamp).ToUnixTimeMilliseconds() / 1000)
            tags = $tagList
        } | ConvertTo-Json

        Write-Verbose "Message body:`r`n$body"

        try {
            $response = Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType application/json -UseBasicParsing
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            if ($statusCode -lt 400 -or $statusCode -gt 499) {
                throw
            }

            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = [io.streamreader]::new($stream)
                $response = $reader.ReadToEnd() | ConvertFrom-Json
            }
            finally {
                $reader.Dispose()
            }
        }

        if ($response.status -ne 1) {
            foreach ($problem in $response.errors) {
                Write-Error $problem -TargetObject $response
            }
            return
        }

        if ($null -ne $response.receipt) {
            Write-Output $response.receipt
        }
    }
}