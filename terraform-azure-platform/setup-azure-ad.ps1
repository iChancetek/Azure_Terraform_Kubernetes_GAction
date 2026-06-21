$env:Path += ";C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin"

$APP_NAME="github-actions-strideiq"
$GITHUB_REPO="iChancetek/Azure_Terraform_Kubernetes_GAction"

Write-Host "Getting Subscription and Tenant details..."
$SUBSCRIPTION_ID = az account show --query id -o tsv
$TENANT_ID = az account show --query tenantId -o tsv

Write-Host "Creating Azure AD Application..."
$APP_ID = az ad app create --display-name $APP_NAME --query appId -o tsv
Start-Sleep -Seconds 10 # Wait for propagation

Write-Host "Creating Service Principal..."
$SP_ID = az ad sp create --id $APP_ID --query id -o tsv
Start-Sleep -Seconds 15 # Wait for propagation

Write-Host "Assigning Contributor Role..."
az role assignment create --assignee $SP_ID --role "Contributor" --scope "/subscriptions/$SUBSCRIPTION_ID"

Write-Host "Assigning User Access Administrator Role..."
az role assignment create --assignee $SP_ID --role "User Access Administrator" --scope "/subscriptions/$SUBSCRIPTION_ID"

Write-Host "Creating Federated Credentials..."
az ad app federated-credential create --id $APP_ID --parameters "{`"name`": `"github-main-branch`", `"issuer`": `"https://token.actions.githubusercontent.com`", `"subject`": `"repo:${GITHUB_REPO}:ref:refs/heads/main`", `"audiences`": [`"api://AzureADTokenExchange`"]}"
az ad app federated-credential create --id $APP_ID --parameters "{`"name`": `"github-pull-requests`", `"issuer`": `"https://token.actions.githubusercontent.com`", `"subject`": `"repo:${GITHUB_REPO}:pull_request`", `"audiences`": [`"api://AzureADTokenExchange`"]}"
az ad app federated-credential create --id $APP_ID --parameters "{`"name`": `"github-env-production`", `"issuer`": `"https://token.actions.githubusercontent.com`", `"subject`": `"repo:${GITHUB_REPO}:environment:production`", `"audiences`": [`"api://AzureADTokenExchange`"]}"
az ad app federated-credential create --id $APP_ID --parameters "{`"name`": `"github-env-disaster-recovery`", `"issuer`": `"https://token.actions.githubusercontent.com`", `"subject`": `"repo:${GITHUB_REPO}:environment:disaster-recovery`", `"audiences`": [`"api://AzureADTokenExchange`"]}"

Write-Host "`n==============================================="
Write-Host "AZURE AD CONFIGURATION COMPLETE!"
Write-Host "Please add these exact values to your GitHub Secrets:"
Write-Host "AZURE_CLIENT_ID: $APP_ID"
Write-Host "AZURE_TENANT_ID: $TENANT_ID"
Write-Host "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
Write-Host "===============================================`n"
