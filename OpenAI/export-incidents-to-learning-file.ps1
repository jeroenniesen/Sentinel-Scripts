# Import the necessary module
Import-Module Az.SecurityInsights

# Set your Azure context
$subscriptionId = '' 
$resourceGroupName = ''
$workspaceName = ''

# Get the Azure context
$context = Get-AzContext

# If no context, login to Azure
if($context -eq $null){
    Connect-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}

# Get incidents
$incidents = Get-AzSentinelIncident -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName -Filter "properties/Status eq 'Closed'" -Top 100 | select Title, Description, Classification    

# Transforming Incidents into JSONL Format
$jsonlData = @()

foreach ($incident in $incidents) {
    # Check if the incident is closed and has a classification
    # Combine title, description and entities for the prompt
    $prompt = "Title: " + $incident.Title + "\nDescription: " + $incident.Description + "\n"

    # Transform each incident into an example
    $example = @{
        'prompt'   = $prompt
        'completion' = $incident.Classification.ToString() + " END"
    }

    # Add example to JSONL data
    $jsonlData += ,($example | ConvertTo-Json -Compress)
}

# Write JSONL data to a file
$jsonlData -join "`n" | Out-File -FilePath .\learning-file.jsonl