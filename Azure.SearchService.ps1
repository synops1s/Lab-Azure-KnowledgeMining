Install-Module -Name Az.Search

Import-Module -Name Az.Search

$labId = 100

$Sku = @{ Name=''; Tier=''; Size=''; Family=''; Model=''; Capacity='' } 

$searchServiceName = "fujlabsas$($labId)"
$resourceGroup = "FUJ-D-WE-LAB$($labId)-RG"
$resourceGroupLocation = Get-AzLocation | Where-Object { $_.DisplayName -eq "West Europe" }

# === Create Azure Search Service Resource === #

$Sku.Name = "standard"
New-AzResource -Location $resourceGroupLocation.Location -ResourceGroupName $resourceGroup -ResourceName $searchServiceName -ResourceType "Microsoft.Search/searchServices" -Sku $Sku -Force

# === Create Azure Storage Account Resource === #

New-AzStorageAccount -ResourceGroupName $resourceGroup -Location $resourceGroupLocation.Location -Name "$($searchServiceName)sa" -SkuName Standard_LRS -Kind StorageV2 -AccessTier Hot

# === Create Azure Storage Containers in Storage Account === #

$sa = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name "$($searchServiceName)sa"

$containerName = "projections"
New-AzStorageContainer -Name $containerName -Context $sa.Context -Permission Container

$containerName = "basicdemo"
New-AzStorageContainer -Name $containerName -Context $sa.Context -Permission Container

Set-Location -LiteralPath C:\Lab\Search\Dataset

Get-Item -Path C:\Lab\Search\Dataset\* | ForEach-Object { Set-AzStorageBlobContent -File $_.FullName -Container $containerName -Blob $_.Name -Context $sa.Context }

# === Create Azure Cognitive Service === #

$cognitiveServiceName = "fujlabscogn$($labId)"

$Sku.Name = "S0"
New-AzResource -Location $resourceGroupLocation.Location -ResourceGroupName $resourceGroup -ResourceName $cognitiveServiceName -ResourceType "Microsoft.CognitiveServices/accounts" -Sku $Sku -Kind "CognitiveServices" -Force

# === Get Required API Keys === #

$keyPair = Get-AzSearchAdminKeyPair -ResourceGroupName $resourceGroup -ServiceName $searchServiceName

Write-Host "Search Service Name: " -ForegroundColor Green -NoNewline
Write-Host "$($searchServiceName)" -ForegroundColor White

Write-Host "Search Service API Key: " -ForegroundColor Green -NoNewline
Write-Host "$($keyPair.Primary)" -ForegroundColor White

Write-Host "Storage Account Name: " -ForegroundColor Green -NoNewline
Write-Host "$($searchServiceName)sa" -ForegroundColor White

Write-Host "Storage Account Key: " -ForegroundColor Green -NoNewline
Write-Host (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name "$($searchServiceName)sa")[0].Value -ForegroundColor White

Write-Host "Cognitive Services API Key: " -ForegroundColor Green -NoNewline
Write-Host (Get-AzCognitiveServicesAccountKey -ResourceGroupName $resourceGroup -Name $cognitiveServiceName).Key1 -ForegroundColor White
