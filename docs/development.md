For example, to run Kato to test the cass-operator, just run
```sh
python3 -m kato --config data/cass-operator/config.json --num-workers 4 --workdir testrun-cass
```

Kato will first generate a test plan using the operator's CRD and the semantic information. The test plan is serialized at `testrun-cass/testplan.json`. Note that Kato does not run the tests according to the order in the `testplan.json`, the tests are run in a random order at runtime.

Kato then constructs the number of Kubernetes clusters according to the `--num-workers` argument,
  and start to run tests.
Tests are run in parallel in separate Kubernetes clusters.
Under the `testrun-cass` directory, Kato creates directories `trial-XX-YYYY`. `XX` corresponds to the worker id, i.e. `XX` ranges from `0` to `3` if there are 4 workers.
`YYYY` starts from `0000`, and Kato increments `YYYY` every time it has to restart the cluster. This means every step inside the same `trial-xx-yyyy` directory run in the same instance of Kubernetes cluster.

Inside each `trial-XX-YYYY` directory, Kato writes `mutated-Z.yaml` files.
These files are the CRs Kato submitted to Kubernetes to run the state transitions.
Concretely, Kato first applies `mutated-0.yaml`, and wait for the system to converge,
  and then applies `mutated-1.yaml`, and so on.
After each step, Kato collects the system state and store it as `system-state-Z.json`.
The command line result and operator log are also collected and stored as `cli-output-Z.log` and `operator-Z.log`.
For quick debugging purposes, Kato serializes the delta of each step and its previous step to `delta-Z.log`. It contains the delta in the input and the delta in the system state. 
But `delta-Z.log` is not essential, it can be computed from `mutated-Z.yaml` and `system-state-Z.log`.

Kato reports the runtime oracle result and writes them to `generation-Z-runtime.json`.
Note that Kato writes such files even if the oracle does not report an alarm.
The file stores the result of different oracles in Kato.

We provide a post-processing script to gather all the alarms into a csv file for alarm inspection.
After all tests finish, run
```sh
python3 -m kato.checker.checker --config data/cass-operator/config.json --num-workers 8 --testrun-dir testrun-cass
```
to post-process all the results.
We run this post-process step because previously we wanted to test the false alarm
  rate under different feature gates.
This post-processing step writes `post-result-Z-{FEATURE}.json` files.
Since now the feature gate has become irrelavent,
  the `post-result-Z-dependency_analysis.json` is the only relevant one.

Since Kato writes oracle result files no matter if there is an alarm or not,
  it is not very efficient to go through all the files and inspect all the alarms.
So we provide a script to collect all the alarms into an xlsx file:
```sh
python3 scripts/feature_results_to_csv.py --testrun-dir testrun-cass
```
It generates the `result.xlsx` file under the `testrun-cass` which contains
  all the oracle results.
You can easily inspect the alarms by importing it into Google Sheet or Excel
  and filter by `alarm==True`.