import * as pulumi from '@pulumi/pulumi';
import * as gcp from '@pulumi/gcp';

export interface WorkloadIdentityResourceProps {
  repos: Array<string>;
  project?: string;
}

export class WorkloadIdentityResource extends pulumi.ComponentResource {
  public workload_identity_provider: pulumi.Output<string>;
  public saEmail: pulumi.Output<string>;

  constructor(
    name: string,
    workloadIdentityResourceProps: WorkloadIdentityResourceProps,
    opts?: pulumi.ResourceOptions
  ) {
    super('iac:core:workloadIdentityPool:', name, {}, opts);

    const { repos, project } = workloadIdentityResourceProps;

    const sa = new gcp.serviceaccount.Account(
      'container-writer',
      {
        project,
        accountId: 'container-writer',
        disabled: false,
        description: 'Github actions service account to create containers',
        displayName: 'Container writer',
      },
      { parent: this, ...opts }
    );

    new gcp.projects.IAMBinding(
      'github-sa-artifact-registry-writer',
      {
        project: project,
        members: [sa.email.apply((email) => `serviceAccount:${email}`)],
        role: 'roles/artifactregistry.writer',
      },
      { parent: this, ...opts }
    );

    const pool = new gcp.iam.WorkloadIdentityPool(
      'example-pool-pulumi2',
      {
        description: 'Github Pool',
        displayName: 'Github pool',
        workloadIdentityPoolId: 'github-pool', // change pu to "te" - as in terraform,
        // if u create it and delete it - u must change the name here - can not really delete the resource.
        project,
      },
      { parent: this, ...opts }
    );
    const poolProvider = new gcp.iam.WorkloadIdentityPoolProvider(
      'github-pool-provider',
      {
        workloadIdentityPoolId: pool.workloadIdentityPoolId,
        workloadIdentityPoolProviderId: 'github-provider',
        displayName: 'Github provider',
        attributeMapping: {
          'google.subject': 'assertion.sub',
          'attribute.actor': 'assertion.actor',
          'attribute.repository': 'assertion.repository',
        },
        oidc: {
          issuerUri: 'https://token.actions.githubusercontent.com',
        },
      },
      { parent: this, ...opts }
    );

    const members = repos.map((repo) => {
      return pulumi.interpolate`principalSet://iam.googleapis.com/${pool.name}/attribute.repository/${repo}`;
    });

    new gcp.serviceaccount.IAMBinding(
      'workloadIdentityUser',
      {
        serviceAccountId: sa.id,
        role: 'roles/iam.workloadIdentityUser',
        members: members,
      },
      { parent: this, ...opts }
    );

    this.workload_identity_provider = poolProvider.name;
    this.saEmail = sa.email;
  }
}
