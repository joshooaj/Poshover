function Get-PushoverSound {
    <#
    .SYNOPSIS
        Gets a hashtable containing the names of sounds available on Pushover, and the description of those sounds
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # Specifies the Pushover application API token/key.
        # Note: The default value will be used if it has been previously set with Set-PushoverConfig
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [securestring]
        $Token
    )

    begin {
        $config = Get-PushoverConfig
        $uriBuilder = [uribuilder]($config.ApiUri + '/sounds.json')
    }

    process {
        if ($null -eq $Token) {
            $Token = $config.Token
            if ($null -eq $Token) {
                throw "Token not provided and no default application token has been set using Set-PushoverConfig."
            }
        }

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
            $sounds = @{}
            foreach ($name in $response.sounds | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) {
                $sounds.$name = $response.sounds.$name
            }
            Write-Output $sounds
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