$prData = Get-ChildItem "C:\Lab" -Filter "FUJ-D-WE-LAB*-RG.txt" | Get-Content | Out-String | ConvertFrom-Json

Set-Clipboard -Value $prData.Secret

$Credential = Get-Credential -UserName $prData.ApplicationId -Message "Provide Password"

Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $prData.TenantId -Subscription $prData.SubscriptionId

Get-AzResourceGroup
Get-AzResource
