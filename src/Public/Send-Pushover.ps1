function Send-Pushover {
    <#
    .SYNOPSIS
        Sends a message to the Pushover API
    .EXAMPLE
        PS C:\> Send-PushoverMessage -Token $token -User $user -Title 'What time is it?' -Message 'It''s time for lunch'
        Sends a notification to the user or group specified in the $user string variable, from the application designed by the application API token value in $token
    .EXAMPLE
        PS C:\> Send-PushoverMessage -Token $token -User $user -Title 'What time is it?' -Message 'It''s time for lunch' -MessagePriority Emergency -RetryInterval (New-TimeSpan -Seconds 60) -ExpireAfter (New-TimeSpan -Hours 1)
        Sends the same notification as Example 1, except with emergency priority which results in the notification being repeated every 60 seconds, until an hour has passed or the message has been acknowledged.
    .OUTPUTS
        Returns a receipt string if the MessagePriority value was 'Emergency' (2)
    #>
    [CmdletBinding()]
    param (
        # Specifies the application API token/key from which the Pushover notification should be sent.
        # Note: The default value will be used if it has been previously set with Set-PushoverConfig
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [securestring]
        $Token,

        # Specifies the User or Group identifier to which the Pushover message should be sent.
        # Note: The default value will be used if it has been previously set with Set-PushoverConfig
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [securestring]
        $User,

        # Optionally specifies one or more devices to which notifications should be sent. Useful for sending notifications to a targetted device instead of all of the user's devices.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Device,

        # Specifies the title of the Pushover notification. The default will be the application name configured for the application API token supplied.
        [Parameter()]
        [string]
        $Title,

        # Specifies the message to be sent with the Pushover notification.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        # Optionally specifies an image in bytes to be attached to the message.
        [Parameter()]
        [byte[]]
        $Attachment,

        # Optionally specifies the file name to associate with the attachment.
        [Parameter()]
        [string]
        $FileName = 'attachment.jpg',

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

        # Specifies the interval between emergency Pushover notifications. Pushover will retry until the message is acknowledged, or expired. Valid only with MessagePriority of 'Emergency'.
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

        # Specifies the amount of time unacknowledged notifications will be retried before Pushover stops sending notifications. Valid only with MessagePriority of 'Emergency'.
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

        # Optionally specifies the notification sound to use
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Sound,

        # Optionally specifies one or more tags to associate with the Pushover notification. Tags can be used to cancel emergency notifications in bulk.
        [Parameter()]
        [string[]]
        $Tags
    )

    begin {
        $config = Get-PushoverConfig
        $uri = $config.ApiUri + '/messages.json'
    }

    process {
        if ($null -eq $Token) {
            $Token = $config.Token
            if ($null -eq $Token) {
                throw "Token not provided and no default application token has been set using Set-PushoverConfig."
            }
        }
        if ($null -eq $User) {
            $User = $config.User
            if ($null -eq $User) {
                throw "User not provided and no default user id has been set using Set-PushoverConfig."
            }
        }

        $deviceList = if ($null -ne $Device) {
            [string]::Join(',', $Device)
        } else { $null }

        $tagList = if ($null -ne $Tags) {
            [string]::Join(',', $Tags)
        } else { $null }

        $body = [ordered]@{
            token = $Token | ConvertTo-PlainText
            user = $User | ConvertTo-PlainText
            device = $deviceList
            title = $Title
            message = $Message
            url = $Url
            url_title = $UrlTitle
            priority = [int]$MessagePriority
            retry = [int]$RetryInterval.TotalSeconds
            expire = [int]$ExpireAfter.TotalSeconds
            timestamp = [int]([datetimeoffset]::new($Timestamp).ToUnixTimeMilliseconds() / 1000)
            tags = $tagList
            sound = $Sound
        }

        try {
            if ($Attachment.Length -eq 0) {
                $bodyJson = $body | ConvertTo-Json
                Write-Verbose "Message body:`r`n$($bodyJson.Replace($Body.token, "********").Replace($Body.user, "********"))"
                $response = Invoke-RestMethod -Method Post -Uri $uri -Body $bodyJson -ContentType application/json -UseBasicParsing
            }
            else {
                $response = Send-MessageWithAttachment -Body $body -Attachment $Attachment -FileName $FileName
            }
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

        if ($response.status -ne 1) {
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

        if ($null -ne $response.receipt) {
            Write-Output $response.receipt
        }
    }
}