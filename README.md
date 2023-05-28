## Sdp-Demo

### GCP setup
#### Login to GCP and set gcloud with the current project
```
gcloud auth login
gcloud config set project [your-gcp-project-id]
```

### Pulumi setup
You should have created an account in pulumi at https://app.pulumi.com/
#### Login to pulumi
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
