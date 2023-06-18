# Kato: Automatic Correctness Testing for (Kubernetes) Operators
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Regression Test](https://github.com/xlab-uiuc/kato/actions/workflows/unittest.yaml/badge.svg)](https://github.com/xlab-uiuc/kato/actions/workflows/unittest.yaml)


## Overview
Kato is a tool to help developers test the correctness of their Kubernetes operators.

Many cloud systems today have operators to manage them atop the Kubernetes platform.
These operators automate important management
tasks, e.g., software upgrades, configuration updates, and autoscaling.
Even for the same cloud system, different operators
are implemented by commercial vendors and open-source
communities to support different practices and environments.

Kato tests operation correctness by performing end-to-end (e2e) testing of cloud-native operators together with the managed systems. 
To do so, Kato continuously generates new operations and
check if the operator can correctly reconciles the system from each current state to the desired state.

The minimum requirement to use Kato is to provide a way to deploy the operator to be tested.
To run Kato in whitebox mode, it additionally requires the operators' source code information.
We list detailed porting steps [here](docs/port.md).

Kato generates syntactically valid desired state declarations(CR) by parsing the CRD of each operator, 
  which contains constraints like type, min/max values(for numeric types), length (for string type), regular-expression patterns, etc.
Kato generates values which satisfy predicates, in the form of property dependencies. 
In blackbox mode, Kato infers the dependencies through naming conventions. 
In whitebox mode, Kato infers the dependencies using control-flow analysis on the source code.

## Prerequisites
- [Golang](https://go.dev/doc/install)
- Python dependencies
    - `pip3 install -r requirements.txt`
- [k8s Kind cluster](https://kind.sigs.k8s.io/)  
    - `go install sigs.k8s.io/kind@v0.20.0`
- kubectl
    - [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- helm
    - [Install Helm](https://helm.sh/docs/intro/install/)

## Getting started

Users need to port the operator before testing it with Kato.
We list the detailed porting steps [here](https://github.com/xlab-uiuc/kato/blob/main/docs/port.md).
We are actively working on simplifying the porting process.

## Demo
To show Kato's bug finding capability, we reproduce one of the previous bugs Kato found automatically.

To reproduce the bug, run the following command:
```sh
python3 -m kato.reproduce --reproduce-dir test/cassop-330/trial-demo --config data/cass-operator/config.json
```
The files in the `test/cassop-330/trial-demo` directory are the sequence of CRs required to trigger
  this bug.
They are just a small subset of CRs generated by Kato automatically.

Kato first spins up a local Kubernetes cluster using Kind and deploys the cass-operator.
It then deploys CassandraDatacenter using the initial CR and 
  generates a transition to insert a key-value pair to CassandraDatacenter's property
  `spec.additionalServiceConfig.seedService.additionalLabels`.
This transition triggerred the cass-operator to add the key-value pair to `metadata.labels` of 
  the corresponding SeedService resource.
For the next step, Kato deletes the key-value pair. 
Due to a bug in cass-operator, the deleted key-value pair
  is not removed from the SeedService resource in Kubernetes.
Kato automatically detects this bug based on the inconsistency between the CR and the system resources.