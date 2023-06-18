# Kato: Kubernetes-based Automatic Testing for Operators
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

## Usage
To run the test:  
```
python3 -m kato \
  --config CONFIG, -c CONFIG
                        Operator port config path
  --num-workers NUM_WORKERS
                        Number of concurrent workers to run Kato with
  --workdir WORK_DIR
                        The directory where Kato writes results
```

## Example
For example, to run Kato to test the cass-operator, just run
```sh
python3 -m kato --config data/cass-operator/config.json --num-workers 4 --workdir testrun-cass
```

Kato starts testing cass-operator using 4 workers concurrently.

After all tests finish, run
```sh
python3 checker.py --config data/cass-operator/config.json --num-workers 8 --testrun-dir testrun-cass
python3 scripts/feature_results_to_csv.py --testrun-dir testrun-cass
```
to post-process all the results.
It generates the `result.xlsx` file under the `testrun-cass` which contains
  all the oracle results.
You can easily inspect the alarms by importing it into Google Sheet or Excel
  and filter by `alarm==True`.