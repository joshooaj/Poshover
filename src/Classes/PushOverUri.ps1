class PushoverUri {
    hidden static [string]$BaseUri = 'https://api.pushover.net/1'

    static [uri]$Messages = [PushoverUri]::BaseUri + '/messages.json'

    # See https://pushover.net/api/receipts for details. You must add /(your-receipt).json?token=(your token) or /(your-receipt)/cancel.json or /cancel_by_tag/(your-tag).json
    static [uri]$Receipts = [PushoverUri]::BaseUri + '/receipts'
}