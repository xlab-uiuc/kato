# Porting a new operator

To port a new operator to Kato and test it, users would need to create a configuration file in JSON and follow the steps to fill the configuration.

## Providing operator deployment script
The minimum requirement for Kato to test an operator is to provide a way to deploy the operator.

Kato supports three different ways for specifying the deployment method: YAML, Helm, and Kustomize.
To specify operators' deployment method in a YAML way, users need to bundle all the required 
  resources into a yaml file, e.g. Namespace, ClusterRole, ServiceAccount, and Deployment.

After aggregating the required resources into a file
Then, specify the deployment in the configuration file through the `deploy` property, e.g.:
```json
{
  "deploy": {
      "method": "YAML",
      "file": "data/rabbitmq-operator/operator.yaml",
  }
}
```

## Providing the name of the CRD to be tested
Specify the name of the CRD to be tested in the configuration through the `crd_name` property. Only required if the operator defines multiple CRDs.
E.g.:
```json
{
  "crd_name": "RabbitmqCluster"
}
```

## Providing the mapping from CR to Kubernetes resources
Run `python3 -m kato.input.known_schemas.known_schemas` which would automatically generate mappings from the properties in the CRD to the corresponding fields in the Kubernetes resources, e.g. `K8sField(['spec', 'affinity'], AffinitySchema)`
Create a file and copy the mapping into it, and specify the file through the `k8s_mapping` property in the configuration.

## Providing a seed CR for the testing to start with
Provide a sample CR which will be used by Kato as the seed. This can be any valid CR, usually operator repos contain multiple sample CRs. Specify this through the `seed_custom_resource` property in the configuration.

## Providing source code information for whitebox mode (optional)
Kato supports a whitebox mode to enable more accurate testing by utilizing source code information.
To provide the source code information to Kato, users need to specify the following fields in the port config file:
- `github_link`: the Github link to the operator repo
- `commit`: the commit hash to test
- `entrypoint`: [optional] the location of the operator's main function if it is not at the root
- `type`: the type name of the managed resource (e.g. `RabbitmqCluster` for the rabbitmq's cluster-operator)
- `package`: the package name where the type of the managed resource is defined (e.g. `github.com/rabbitmq/cluster-operator/api/v1beta1`)
Kato uses these information to accurately find the type in the source corresponding to the tested CR.

Example:
```json
{
  "analysis": {
      "github_link": "https://github.com/rabbitmq/cluster-operator.git",
      "commit": "f2ab5cecca7fa4bbba62ba084bfa4ae1b25d15ff",
      "entrypoint": null,
      "type": "RabbitmqCluster",
      "package": "github.com/rabbitmq/cluster-operator/api/v1beta1"
  }
}
```