using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

if ($env:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts)) {
    Connect-AzAccount -Identity
}

$queryResults = Invoke-AzOperationalInsightsQuery -WorkspaceId "c3a71a54-1e0a-4cb1-beb2-fae26ab60673" -Query "AzureActivity | where SubscriptionId=='7e0f910b-6182-434c-a552-2b63ad635f23'" -Timespan (New-TimeSpan -Hours 24)
$results = $queryResults | ConvertTo-Json

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

if ($name) {
    $status = [HttpStatusCode]::OK
    $body = "Hello $results"
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = "Please pass a name on the query string or in the request body."
}

foreach ($style in $beerStyles.data){
    $entity = [PSObject]@{
        partitionKey = 'myEvents'
        rowKey = $style.name.Replace("/","-")
        name = $style.shortName
        ibuMin = $style.ibuMin
        ibuMax = $style.ibuMax
        abvMax = $style.abvMax
        abvMin = $style.abvMin
        srmMax = $style.srmMax
        srmMin = $style.srmMin
        ogMax = $style.ogMax
        ogMin = $style.ogMin
        fgMax = $style.fgMax
        fgMin = $style.fgMin        
    }
    $outputArray += $entity
}

Push-OutputBinding -name OutputBlob -value $SomeValue 

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
