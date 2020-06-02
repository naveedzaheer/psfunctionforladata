using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

if ($env:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts)) {
    Connect-AzAccount -Identity
}

$queryResults = Invoke-AzOperationalInsightsQuery -WorkspaceId "c3a71a54-1e0a-4cb1-beb2-fae26ab60673" -Query "AzureActivity | where SubscriptionId=='7e0f910b-6182-434c-a552-2b63ad635f23'" -Timespan (New-TimeSpan -Hours 24)
$resultsArray = [System.Linq.Enumerable]::ToArray($queryResults.Results)
$results = $queryResults | ConvertTo-Json

foreach ($result in $resultsArray){
    $entity = [PSObject]@{
        partitionKey = 'myEvents'
        rowKey = $result.EventDataId
    }

    $jsonEntity =  $entity | ConvertTo-Json
    Write-Host "Table Entity: $jsonEntity"
    Push-OutputBinding -Name outputTable -Value $entity
}


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

Push-OutputBinding -name OutputBlob -value $results


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
