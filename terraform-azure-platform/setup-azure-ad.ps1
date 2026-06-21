<#
.SYNOPSIS
    Full bootstrap for GitHub Actions OIDC authentication to Azure.
    Run this ONCE from your local machine before your first pipeline run.

.DESCRIPTION
    This script:
      1. Creates an Azure AD App Registration
      2. Creates a Service Principal
      3. Assigns Contributor + User Access Administrator roles
      4. Creates 4 Federated Identity Credentials (OIDC — no passwords ever)
      5. Prints every GitHub Secret value you need to copy

.PREREQUISITES
    - Azure CLI installed and logged in (az login)
    - Must be Owner or have enough permissions to create role assignments
    - PowerShell 5.1+ or PowerShell Core

.USAGE
    .\setup-azure-ad.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Configuration ─────────────────────────────────────────────────────────────
$APP_NAME    = "github-actions-strideiq"
$GITHUB_ORG  = "iChancetek"
$GITHUB_REPO = "Azure_Terraform_Kubernetes_GAction"
$FULL_REPO   = "$GITHUB_ORG/$GITHUB_REPO"

# State storage (must be globally unique — change TF_STATE_SA if taken)
$TF_STATE_RG = "rg-tfstate-strideiq-prod"
$TF_STATE_SA = "strtfstatestride001"     # 3-24 chars, lowercase letters and numbers only

# AKS cluster names (set these after Terraform creates the clusters)
$AKS_CLUSTER_PRIMARY   = "aks-prod-eastus"
$AKS_CLUSTER_SECONDARY = "aks-prod-centralus"
$AZURE_RG_PRIMARY      = "rg-strideiq-eastus"
$AZURE_RG_SECONDARY    = "rg-strideiq-centralus"

# ACR name (must be globally unique)
$ACR_NAME = "acrstrideiqqprod"
# ─────────────────────────────────────────────────────────────────────────────

function Write-Step($msg) {
    Write-Host "`n▶ $msg" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "  ✓ $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "  ⚠ $msg" -ForegroundColor Yellow
}

# ── 1. Get Subscription & Tenant ─────────────────────────────────────────────
Write-Step "Fetching subscription and tenant details..."
$SUBSCRIPTION_ID = az account show --query id -o tsv
$TENANT_ID       = az account show --query tenantId -o tsv
$ACCOUNT_NAME    = az account show --query name -o tsv

Write-Success "Subscription : $ACCOUNT_NAME ($SUBSCRIPTION_ID)"
Write-Success "Tenant       : $TENANT_ID"

# ── 2. Create App Registration ────────────────────────────────────────────────
Write-Step "Creating Azure AD App Registration: $APP_NAME ..."

# Check if it already exists
$EXISTING_APP_ID = az ad app list --display-name $APP_NAME --query "[0].appId" -o tsv 2>$null

if ($EXISTING_APP_ID -and $EXISTING_APP_ID -ne "") {
    Write-Warn "App '$APP_NAME' already exists — reusing it (AppId: $EXISTING_APP_ID)"
    $APP_ID = $EXISTING_APP_ID
} else {
    $APP_ID = az ad app create --display-name $APP_NAME --query appId -o tsv
    Write-Success "Created App Registration (AppId: $APP_ID)"
    Write-Host "  Waiting 15s for Azure AD propagation..." -ForegroundColor Gray
    Start-Sleep -Seconds 15
}

# ── 3. Create Service Principal ───────────────────────────────────────────────
Write-Step "Creating Service Principal..."

$EXISTING_SP = az ad sp show --id $APP_ID --query id -o tsv 2>$null

if ($EXISTING_SP -and $EXISTING_SP -ne "") {
    Write-Warn "Service Principal already exists — reusing it"
    $SP_ID = $EXISTING_SP
} else {
    $SP_ID = az ad sp create --id $APP_ID --query id -o tsv
    Write-Success "Created Service Principal (ObjectId: $SP_ID)"
    Write-Host "  Waiting 20s for Azure AD propagation..." -ForegroundColor Gray
    Start-Sleep -Seconds 20
}

# ── 4. Role Assignments ───────────────────────────────────────────────────────
Write-Step "Assigning roles at subscription scope..."

$SCOPE = "/subscriptions/$SUBSCRIPTION_ID"

az role assignment create --assignee $APP_ID --role "Contributor"              --scope $SCOPE 2>$null | Out-Null
Write-Success "Assigned: Contributor"

az role assignment create --assignee $APP_ID --role "User Access Administrator" --scope $SCOPE 2>$null | Out-Null
Write-Success "Assigned: User Access Administrator"

az role assignment create --assignee $APP_ID --role "Storage Blob Data Contributor" --scope $SCOPE 2>$null | Out-Null
Write-Success "Assigned: Storage Blob Data Contributor (required for Terraform state)"

# ── 5. Federated Identity Credentials (OIDC) ──────────────────────────────────
Write-Step "Creating Federated Identity Credentials (OIDC)..."

$ISSUER    = "https://token.actions.githubusercontent.com"
$AUDIENCES = '["api://AzureADTokenExchange"]'

$CREDS = @(
    @{ name = "github-main-branch";        subject = "repo:${FULL_REPO}:ref:refs/heads/main" },
    @{ name = "github-pull-requests";      subject = "repo:${FULL_REPO}:pull_request" },
    @{ name = "github-env-production";     subject = "repo:${FULL_REPO}:environment:production" },
    @{ name = "github-env-disaster-recovery"; subject = "repo:${FULL_REPO}:environment:disaster-recovery" }
)

foreach ($cred in $CREDS) {
    $existing = az ad app federated-credential list --id $APP_ID --query "[?name=='$($cred.name)'].name" -o tsv 2>$null
    if ($existing -and $existing -ne "") {
        Write-Warn "Federated credential '$($cred.name)' already exists — skipping"
    } else {
        $params = @{
            name      = $cred.name
            issuer    = $ISSUER
            subject   = $cred.subject
            audiences = @("api://AzureADTokenExchange")
        } | ConvertTo-Json -Compress

        az ad app federated-credential create --id $APP_ID --parameters $params | Out-Null
        Write-Success "Created: $($cred.name)"
    }
}

# ── 6. Output GitHub Secrets ──────────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  GITHUB SECRETS — copy these into your repository secrets     " -ForegroundColor Magenta
Write-Host "  GitHub → Settings → Secrets and variables → Actions          " -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host "  AZURE_CLIENT_ID          = $APP_ID"          -ForegroundColor Yellow
Write-Host "  AZURE_TENANT_ID          = $TENANT_ID"       -ForegroundColor Yellow
Write-Host "  AZURE_SUBSCRIPTION_ID    = $SUBSCRIPTION_ID" -ForegroundColor Yellow
Write-Host ""
Write-Host "  TF_STATE_RG              = $TF_STATE_RG"     -ForegroundColor Yellow
Write-Host "  TF_STATE_SA              = $TF_STATE_SA"     -ForegroundColor Yellow
Write-Host ""
Write-Host "  ACR_NAME                 = $ACR_NAME"              -ForegroundColor Yellow
Write-Host "  AZURE_RG_PRIMARY         = $AZURE_RG_PRIMARY"      -ForegroundColor Yellow
Write-Host "  AZURE_RG_SECONDARY       = $AZURE_RG_SECONDARY"    -ForegroundColor Yellow
Write-Host "  AKS_CLUSTER_PRIMARY      = $AKS_CLUSTER_PRIMARY"   -ForegroundColor Yellow
Write-Host "  AKS_CLUSTER_SECONDARY    = $AKS_CLUSTER_SECONDARY" -ForegroundColor Yellow
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta

# ── 7. GitHub Environments Reminder ──────────────────────────────────────────
Write-Host ""
Write-Host "NEXT STEPS — Complete these manually in GitHub:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Go to: https://github.com/$FULL_REPO/settings/environments"
Write-Host "     Create environment: [production]"
Write-Host "     → Enable 'Required reviewers' and add yourself"
Write-Host ""
Write-Host "  2. Create environment: [disaster-recovery]"
Write-Host "     → Enable 'Required reviewers' and add yourself"
Write-Host "     → Optionally: restrict to 'main' branch only"
Write-Host ""
Write-Host "  3. Add all secrets listed above to:"
Write-Host "     https://github.com/$FULL_REPO/settings/secrets/actions"
Write-Host ""
Write-Host "  4. After Terraform apply completes, update these secrets:"
Write-Host "     AKS_CLUSTER_PRIMARY, AKS_CLUSTER_SECONDARY"
Write-Host "     AZURE_RG_PRIMARY, AZURE_RG_SECONDARY"
Write-Host "     (Terraform outputs will show the exact names)"
Write-Host ""
Write-Host "Done! Your pipeline is ready to run." -ForegroundColor Green
