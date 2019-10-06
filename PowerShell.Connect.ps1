$prData = Get-Content -LiteralPath "C:\Lab\FUJ-D-WE-LAB100-RG.txt" | Out-String | ConvertFrom-Json

Set-Clipboard -Value $prData.Secret

$Credential = Get-Credential -UserName $prData.ApplicationId -Message "Provide Password"

Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $prData.TenantId -Subscription $prData.SubscriptionId

Get-AzResourceGroup
