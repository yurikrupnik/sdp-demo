## Sdp-Demo
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
## Choose IaC you would like to use - Terraform/Pulumi/Crossplane
### Pulumi setup
You should have created pulumi account at https://app.pulumi.com/

#### Install npm modules via pnpm
```
pnpm i
```
#### Login to pulumi from local machine
```
pulumi login 
```

#### Create pulumi stack
```
pulumi stack init [your-org]/dev
```

#### Set pulumi configs for current stack
```
pulumi config set gcp:project [your-gcp-project-id]
pulumi config set gcp:region europe-central2
```

#### Run pulumi locally to deploy the infrastructure
```
cd iac/pulumi
pulumi up
```

#### Run pulumi locally to delete the infrastructure
```
pulumi destroy 
```

### Terraform setup
You should have created terraform account at https://app.terraform.io/

#### Login to terraform from local machine
```
terraform login
```

#### Init the project
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

