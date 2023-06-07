## Sdp-Demo - Enabling keyless authentication from GitHub Actions

This repository is a [NX](https://nx.dev/) monorepo housing two backend applications: Golang App and Node App. Both applications can be found within the "apps" folder.



Within the repository, you will find a single Dockerfile utilized by our GitHub Actions CI workflow. This Dockerfile is responsible for generating each of the applications, and it employs a specific target, namely "alpine," for creating the Go application.
Following the image creation process, the workflow proceeds to push the freshly generated images to the GCP Artifact Registry.

```docker
FROM alpine AS alpine
WORKDIR /
ARG DIST_PATH
RUN test -n "$DIST_PATH" || (echo "DIST_PATH not set" && false)
ARG ENTRY_NAME=app
ENV PORT=8080
COPY $DIST_PATH ./app
EXPOSE ${PORT}
ENTRYPOINT ["/app"]
```

<details>
<summary>Go application project.json that contains the scripts for each app - see docker</summary>

```json
{
  "name": "go-app",
  "$schema": "../../node_modules/nx/schemas/project-schema.json",
  "projectType": "application",
  "sourceRoot": "apps/go-app",
  "targets": {
    "build": {
      "executor": "@nx-go/nx-go:build",
      "options": {
        "outputPath": "dist/apps/go-app",
        "main": "apps/go-app/main.go"
      }
    },
    "serve": {
      "executor": "@nx-go/nx-go:serve",
      "options": {
        "main": "apps/go-app/main.go"
      }
    },
    "test": {
      "executor": "@nx-go/nx-go:test"
    },
    "lint": {
      "executor": "@nx-go/nx-go:lint"
    },
    "docker": {
      "executor": "@nx-tools/nx-container:build",
      "dependsOn": [
        {
          "target": "build",
          "projects": "self",
          "params": "forward"
        }
      ],
      "options": {
        "push": true,
        "file": "./Dockerfile",
        "target": "alpine",
        "platforms": ["linux/amd64"],
        "build-args": ["DIST_PATH=dist/apps/go-app"],
        "metadata": {
          "images": ["$REGISTRY/go-app"],
          "tags": [
            "type=schedule",
            "type=ref,event=branch",
            "type=ref,event=tag",
            "type=ref,event=pr",
            "type=semver,pattern={{version}}",
            "type=semver,pattern={{major}}.{{minor}}",
            "type=semver,pattern={{major}}",
            "type=sha"
          ]
        }
      }
    }
  },
  "tags": []
}

```
</details>

Additionally, the repository encompasses three essential Infrastructure as Code (IaC) tools used to deploy our GCP resources: [Terraform](https://www.terraform.io/), [Pulumi](https://www.pulumi.com/), and [Crossplane](https://www.crossplane.io/). These tools reside in the "iac" folder. Your should choose 1 of them to deploy your infrastructure. Which includes GCP Artifact Registry repository and Workload Identity resources.

### Start the demo

#### Fork the repo
```
gh repo fork https://github.com/yurikrupnik/sdp-demo --clone
```

### GCP setup
#### Login to GCP and set gcloud with the current project
```
gcloud auth login
gcloud config set project [your-gcp-project-id]
```
### Choose IaC you would like to use - Terraform/Pulumi/Crossplane

<details>
<summary>Terraform setup</summary>

Create an account at [Terraform](https://app.terraform.io/)

#### Login to terraform from local machine
```
terraform login
```

#### Go to Terraform folder code
```
cd iac/terraform
```

#### Init the project to download the gcp provider for terraform
```
terraform init
```
#### Set terraform values at variables.tf file
```terraform
variable "project_id" {
  type = string
  default = "PROJECT_ID" # Change to to your GCP project id
}

variable "repo_names" {
  type    = list(string)
  default = ["GITHUB_ORG/REPO_NAME"] # Change to to your github org
}
```

#### Deploy the infra and pay attention to the outputs.
```
terraform apply
```
</details>

<details>
<summary>Pulumi setup</summary>

Create an account at [Pulumi](https://app.pulumi.com/)

#### Install npm modules via pnpm
```
pnpm i
```
#### Login to pulumi from local machine
```
pulumi login 
```

#### Go to Pulumi folder code
```
cd iac/pulumi
```

#### Create pulumi stack
```
pulumi stack init [your-org]/dev
```

#### Set pulumi configs for current stack
```
pulumi config set gcp:project <GCP_PROJECT_ID>
pulumi config set gcp:region europe-central2
pulumi config set --path repos[0] <GITHUB_ORG/REPO_NAME>
```

#### Deploy the infra and pay attention to the outputs.
```
pulumi up
```

</details>

<details>
<summary>Crossplane setup - sadly not generic yet</summary>


#### Create local minikube cluster with gcp-auth addon for automatic secret creation
```
minikube start
minikube addons enable gcp-auth
```

#### Install Crossplane on the cluster
```
helm repo add crossplane-stable https://charts.crossplane.io/stable && helm repo update
helm install crossplane --namespace crossplane-system --create-namespace crossplane-stable/crossplane
```

#### Set up your projectID in gcpProviderConfig.yaml
```yaml
apiVersion: gcp.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: "***"
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: gcp-auth
      key: creds
```

#### Apply the gcp provider and the config with the built secret
```
kubectl apply -f gcpProvider.yaml
kubectl wait "providers.pkg.crossplane.io/provider-gcp" --for=condition=Installed --timeout=180s
kubectl wait "providers.pkg.crossplane.io/provider-gcp" --for=condition=Healthy --timeout=180s
kubectl get providers
kubectl apply -f gcpProviderConfig.yaml
```

#### Set project id in artifactory.yaml file
```yaml
apiVersion: cloudplatform.gcp.upbound.io/v1beta1
kind: ProjectService
metadata:
  annotations:
    meta.upbound.io/example-id: cloudplatform/v1beta1/artifactregistry
  labels:
    testing.upbound.io/example-name: artifactregistry
  name: artifactregistry
spec:
  forProvider:
    disableDependentServices: false
    service: artifactregistry.googleapis.com
    project: "***"
```

#### Set project id in workloadIdentity.yaml file, including GIT_ORG and PROJECT_NUMBER
```yaml
apiVersion: cloudplatform.gcp.upbound.io/v1beta1
kind: ProjectService
metadata:
  annotations:
    meta.upbound.io/example-id: cloudplatform/v1beta1/artifactregistry
  labels:
    testing.upbound.io/example-name: iamcredentials
  name: iamcredentials
spec:
  forProvider:
    disableDependentServices: false
    service: iamcredentials.googleapis.com
    project: "***"
---
apiVersion: cloudplatform.gcp.upbound.io/v1beta1
kind: ServiceAccount
metadata:
  annotations:
    meta.upbound.io/example-id: cloudplatform/v1beta1/artifactory
  labels:
    testing.upbound.io/example-name: container-builder
  name: container-builder
spec:
  forProvider:
    displayName: Container builder
    description: Github actions service account to create containers
---
apiVersion: cloudplatform.gcp.upbound.io/v1beta1
kind: ProjectIAMMember
metadata:
  annotations:
    meta.upbound.io/example-id: logging/v1beta1/container-builder
  labels:
    testing.upbound.io/example-name: container-builder-role
  name: container-builder-role
spec:
  forProvider:
    member: serviceAccount:container-builder@***.iam.gserviceaccount.com
    project: "***"
    role: "roles/artifactregistry.writer"
---
apiVersion: iam.gcp.upbound.io/v1beta1
kind: WorkloadIdentityPool
metadata:
  annotations:
    meta.upbound.io/example-id: iam/v1beta1/workloadidentitypool
    upjet.upbound.io/manual-ntervention: Needs permissions for Pool creation
  labels:
    testing.upbound.io/example-name: github-pool
  name: github-pool-cr2
spec:
  forProvider:
    description: 'Github Pool Crossplane'
    displayName: 'Github Pool Crossplane'
---
apiVersion: iam.gcp.upbound.io/v1beta1
kind: WorkloadIdentityPoolProvider
metadata:
  annotations:
    meta.upbound.io/example-id: iam/v1beta1/workloadidentitypoolprovider
  labels:
    testing.upbound.io/example-name: identity-pool-provider
  name: identity-pool-provider4
spec:
  forProvider:
    project: "***"
    displayName: "github-provider1"
    description: "Github Provider1"
    attributeMapping:
      'google.subject': 'assertion.sub'
      'attribute.actor': 'assertion.actor'
      'attribute.repository': 'assertion.repository'
    oidc:
      - issuerUri: 'https://token.actions.githubusercontent.com'
    workloadIdentityPoolId: github-pool-cr2
---
apiVersion: cloudplatform.gcp.upbound.io/v1beta1
kind: ServiceAccountIAMMember
metadata:
  annotations:
    meta.upbound.io/example-id: cloudplatform/v1beta1/serviceaccountiammember
  labels:
    testing.upbound.io/example-name: service-account-iam-member
  name: service-account-iam-member1
spec:
  forProvider:
    member: 'principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool-cr2/attribute.repository/GIT_ORG/sdp-demo'
    role: roles/iam.workloadIdentityUser
    serviceAccountIdSelector:
      matchLabels:
        testing.upbound.io/example-name: container-builder

```

#### Apply the resources
```
kubectl apply -f artifactory.yaml
kubectl apply -f workloadIdentity.yaml
```
</details>

#### To modify the "docker" job in GitHub Actions based on the IaC outputs, follow these steps:
1. Navigate to the ".github" folder in your repository.
2. Locate the "node.js.yml" file within the ".github" folder.
3. Open the "node.js.yml" file in a text editor or code editor of your choice.
4. Look for the job named "docker" within the YAML file.
5. Make the necessary changes to the "docker" job based on the IaC outputs.

```yaml
- id: 'auth'
  uses: 'google-github-actions/auth@v1'
  with:
    # change here to your workload_identity_provider and service_account
    workload_identity_provider: '***'
    service_account: '***'
- name: Container build
  run: pnpm nx affected --target=docker --parallel --max-parallel=3 --prod
  env:
    GOOS: linux
    GOARCH: amd64
    CGO_ENABLED: 0
    INPUT_GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    # change here to your REGISTRY
    REGISTRY: '***'
```
#### Change the code of our 2 apps by adding "!" to the response.
```go
app.Get("/", func(c *fiber.Ctx) error {
  return c.SendString("Hello SDP!!")
})
```
```js
app.get('/', (req, res) => {
  res.send({ message: 'Hello SDP!!' });
});
```
By changing the code, we are telling our monorepo to run the jobs of the changed apps.
#### Test the CI job 
Create a pull request with updated changes from pulumi outputs, make sure they are all green.

As a result of successful CI, we should see 2 new docker images in the Artifact Registry.

### Clean up
<details>
<summary>Terraform</summary>

```
terraform destroy
```
</details>

<details>
<summary>Pulumi</summary>

```
pulumi destroy
```
</details>

<details>
<summary>Crossplane</summary>

```
kubectl delete -f artifactory.yaml
kubectl delete -f workloadIdentity.yaml
minikube delete
```
</details>

### References
[Workload identity federation](https://cloud.google.com/iam/docs/workload-identity-federation)

[Manage Workload identity pools providers](https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers)

[Github actions GCP Auth](https://github.com/google-github-actions/auth)

[Enabling keyless authentication](https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions)

[How does the GCP Workload Identity Federation work with Github Provider?](https://medium.com/google-cloud/how-does-the-gcp-workload-identity-federation-work-with-github-provider-a9397efd7158)

[CircleCi with GCP Workload Identity Federation](https://discuss.circleci.com/t/gcloud-oidc-connect-full-example/44045)

[Bitbucket CI with GCP Workload Identity Federation](https://community.atlassian.com/t5/Bitbucket-questions/How-set-up-bitbucket-pipeline-using-a-gcp-private-image-via-OIDC/qaq-p/1792393)

