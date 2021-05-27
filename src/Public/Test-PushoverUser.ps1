function Test-PushoverUser {
    <#
    .SYNOPSIS
        Test a given user key and optionally device name to see if it is valid according to the Pushover API
    .DESCRIPTION
        If you are collecting user key's, you may want to verify that the key is valid before accepting it. Use
        this cmdlet to test the key to see if it is in fact valid.

        Similar to the Test-NetConnection cmdlet, this can return detailed information or it can return a simple
        boolean value. The detailed information can be used to provide a better error message such as 'device name is not valid for user'.
    .EXAMPLE
        PS C:\> if ($null -eq (Get-PushoverConfig).Token) { Set-PushoverConfig -Token (Read-Host -Prompt 'Pushover Application Token' -AsSecureString) }
        PS C:\> Test-PushoverUser -User (Read-Host -Prompt 'Pushover User Key' -AsSecureString)
        Checks whether the current user's Pushover config includes a default application token. If not, request the user to enter the application token
        and save it for future use. Then request the Pushover user key and test whether the key is valid.
    #>
    [CmdletBinding()]
    [OutputType([PoshoverUserValidation])]
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

        # Optionally specifies the device on the user account to validate
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Device,

        # Specifies the information level desired in the response. Quiet means a boolean will be returned while Detailed will return an object with more information.
        [Parameter()]
        [PoshoverInformationLevel]
        $InformationLevel = [PoshoverInformationLevel]::Detailed
    )

    begin {
        $config = Get-PushoverConfig
        $uri = $config.ApiUri + '/users/validate.json'
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

        $body = [ordered]@{
            token = $Token | ConvertTo-PlainText
            user = $User | ConvertTo-PlainText
            device = $Device
        }

        try {
            $bodyJson = $body | ConvertTo-Json
            Write-Verbose "Message body:`r`n$($bodyJson.Replace($Body.token, "********").Replace($Body.user, "********"))"
            $response = Invoke-RestMethod -Method Post -Uri $uri -Body $bodyJson -ContentType application/json -UseBasicParsing
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

        if ($null -ne $response.status) {
            switch ($InformationLevel) {
                ([PoshoverInformationLevel]::Quiet) {
                    Write-Output ($response.status -eq 1)
                }

                ([PoshoverInformationLevel]::Detailed) {
                    [PoshoverUserValidation]@{
                        Valid = $response.status -eq 1
                        IsGroup = $response.group -eq 1
                        Devices = $response.devices
                        Licenses = $response.licenses
                        Error = $response.errors | Select-Object -First 1
                    }
                }
                Default { throw "InformationLevel $InformationLevel not implemented." }
            }
        }
        else {
            Write-Error "Unexpected response: $($response | ConvertTo-Json)"
        }
    }
}