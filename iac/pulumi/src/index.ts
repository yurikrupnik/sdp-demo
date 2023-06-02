import * as pulumi from '@pulumi/pulumi';
import * as gcp from '@pulumi/gcp';
import { ArtifactoryResource } from './artifactory';
import { WorkloadIdentityResource } from './workloadIdentity';

const gcpConfig = new pulumi.Config('gcp');
const pulumiConfig = new pulumi.Config('pulumi');
const region = gcpConfig.get('region');
const project = gcpConfig.get('project');
const repos = pulumiConfig.requireObject('repos');
// const repos = pulumiConfig.get('repos');

console.log('repos', repos);
console.log('repos', typeof repos);

const artifactRegistry = new gcp.projects.Service(
  'artifactregistry.googleapis.com',
  {
    disableDependentServices: true,
    service: 'artifactregistry.googleapis.com',
  }
);

const dockerRegistry = new ArtifactoryResource(
  'docker-registry',
  {
    repositoryArgs: {
      mode: 'STANDARD_REPOSITORY',
      project,
      labels: {
        iac: 'pulumi',
      },
      repositoryId: 'container-repository',
      location: region,
      format: 'DOCKER',
      description: 'Example docker repository.',
    },
  },
  {
    parent: artifactRegistry,
    dependsOn: [artifactRegistry],
  }
);

const iamcredentials = new gcp.projects.Service(
  'iamcredentials.googleapis.com',
  {
    disableDependentServices: true,
    service: 'iamcredentials.googleapis.com',
  }
);

const workloadIdentity = new WorkloadIdentityResource(
  'WorkloadIdentityResource',
  {
    // repos: repos as [],
    repos: ['yurikrupnik/sdp-demo'],
    project,
  },
  { dependsOn: [iamcredentials], parent: iamcredentials }
);

export const dockerRepo = dockerRegistry.dockerRepo;
export const workloadName = workloadIdentity.workload_identity_provider;
export const workloadSAEmail = workloadIdentity.saEmail;
