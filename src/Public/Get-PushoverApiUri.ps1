function Get-PushoverApiUri {
    <#
    .SYNOPSIS
        Gets the currently configured API URI to which all HTTP requests from this module will be sent.
    #>
    [CmdletBinding()]
    param ()

    process {
        $script:PushoverApiUri
    }
}