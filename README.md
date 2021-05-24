# PoshOver - A PowerShell module for PushOver

There are a couple of existing PowerShell modules on GitHub and PSGallery for this, but truth-be-told the API is relatively easy to wrap in PowerShell so I wanted to write one in a format I'm used to.

## To-do
 
 - Implement a mechanism to save the application API token to disk securely using DPAPI (system.security.cryptography or just convert*-securestring) so you don't have to supply the token with every function call.
 - Implement a mechanism to save user/group ID's as either a named value or just set a default. Then if the caller doesn't specify a user in the function call, the default user/group ID will be used instead.
 - Make a better README.
 - Make use of receipts to follow-up on emergency priority messages and take an action after they're acknowledged or if they remain unacknowledged.
