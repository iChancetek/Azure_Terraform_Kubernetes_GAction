$env:Path += ";C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin"
$APP_ID="6019be22-89e5-4cf6-a555-ee0d0847ddd6"

Write-Host "Writing JSON configs..."
$json1 = '{ "name": "github-main-branch", "issuer": "https://token.actions.githubusercontent.com", "subject": "repo:iChancetek/Azure_Terraform_Kubernetes_GAction:ref:refs/heads/main", "audiences": ["api://AzureADTokenExchange"] }'
$json1 | Out-File -FilePath main.json -Encoding utf8

$json2 = '{ "name": "github-pull-requests", "issuer": "https://token.actions.githubusercontent.com", "subject": "repo:iChancetek/Azure_Terraform_Kubernetes_GAction:pull_request", "audiences": ["api://AzureADTokenExchange"] }'
$json2 | Out-File -FilePath pr.json -Encoding utf8

$json3 = '{ "name": "github-env-production", "issuer": "https://token.actions.githubusercontent.com", "subject": "repo:iChancetek/Azure_Terraform_Kubernetes_GAction:environment:production", "audiences": ["api://AzureADTokenExchange"] }'
$json3 | Out-File -FilePath prod.json -Encoding utf8

$json4 = '{ "name": "github-env-disaster-recovery", "issuer": "https://token.actions.githubusercontent.com", "subject": "repo:iChancetek/Azure_Terraform_Kubernetes_GAction:environment:disaster-recovery", "audiences": ["api://AzureADTokenExchange"] }'
$json4 | Out-File -FilePath dr.json -Encoding utf8

Write-Host "Creating federated credentials..."
az ad app federated-credential create --id $APP_ID --parameters "@main.json"
az ad app federated-credential create --id $APP_ID --parameters "@pr.json"
az ad app federated-credential create --id $APP_ID --parameters "@prod.json"
az ad app federated-credential create --id $APP_ID --parameters "@dr.json"

Write-Host "Cleaning up..."
Remove-Item main.json, pr.json, prod.json, dr.json
Write-Host "DONE!"
