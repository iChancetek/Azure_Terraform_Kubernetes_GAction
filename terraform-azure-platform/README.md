# Enterprise Azure Platform for AKS & StrideIQ

This repository contains an Enterprise-grade Terraform platform for provisioning a highly available, multi-region Azure Kubernetes Service (AKS) environment. It also includes GitOps, DevSecOps, and FinOps practices, designed to deploy the `strideiq` application automatically.

## Architecture
- **Primary Region**: `eastus`
- **Secondary Region**: `centralus`
- **Failover**: Azure Traffic Manager
- **Networking**: Custom VNet, dedicated subnets, Azure Private DNS Zones.
- **Identity**: Azure User Assigned Managed Identity, Workload Identity Federation for GitHub Actions.
- **Observability**: Azure Monitor, Log Analytics Workspace, Container Insights, Application Insights.
- **Security**: Azure Key Vault, Azure Policy, Microsoft Defender for Cloud, Network Policies.
- **Addons**: NGINX Ingress, Cert Manager, External DNS, Key Vault CSI Driver, KEDA, Metrics Server.

## Prerequisites
- Azure Subscription
- Terraform CLI >= 1.5.0
- Azure CLI
- GitHub Repository connected to Workload Identity Federation

## Authentication
This project uses Azure Workload Identity Federation for GitHub Actions. You must configure OIDC federated credentials in your Azure AD tenant.
1. Create a Managed Identity or App Registration in Azure.
2. Configure Federated Credentials for your GitHub repository and environment (`production`, `disaster-recovery`).
3. Add the following secrets to your GitHub repository:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_RG_PRIMARY`
   - `AZURE_RG_SECONDARY`
   - `AKS_CLUSTER_PRIMARY`
   - `AKS_CLUSTER_SECONDARY`
   - `ACR_NAME`

## Initialization & Deployment
1. Initialize Terraform:
   ```bash
   cd terraform-azure-platform
   terraform init -backend-config="resource_group_name=..." -backend-config="storage_account_name=..."
   ```
2. Validate Configuration:
   ```bash
   terraform validate
   ```
3. Plan deployment:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```
4. Apply infrastructure:
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

## AKS Verification
Verify cluster connectivity and addons:
```bash
az aks get-credentials --resource-group <primary_rg> --name <primary_aks_name>
kubectl get pods --all-namespaces
kubectl get ingress -n strideiq
```

## High Availability & Disaster Recovery
Traffic Manager routes users to the primary region (`eastus`). If the primary region health probes fail, Traffic Manager will automatically route traffic to the secondary region (`centralus`) within 60 seconds.

## GitHub Actions
The `.github/workflows` directory contains all CI/CD automation:
- **terraform-plan / apply**: Automated infrastructure deployment.
- **security-scan**: TruffleHog, Checkov, tfsec, and Trivy security scans.
- **container-build**: Builds the Docker image for `strideiq` and pushes to ACR.
- **aks-deploy**: Applies Kubernetes manifests to primary and secondary AKS clusters.

## Resource Deletion Order
To avoid orphaned resources, Terraform must destroy components in this specific order. The terraform dependency graph handles this automatically when running:
```bash
terraform destroy
```
The internal deletion sequence is:
1. Helm Addons
2. Traffic Manager
3. Node Pools
4. AKS Clusters
5. Managed Identities
6. Key Vault
7. Container Registry
8. Monitoring
9. Networking
10. Storage

## Cost Optimization
- AKS clusters autoscale down to the configured `min_node_count`.
- Azure Advisor recommends rightsizing.
- Management locks prevent accidental deletion.
