lib:
	(cd kato/k8s_util/lib && make)
	(cd ssa && make)

clean:
	(cd kato/k8s_util/lib && make clean)
	(cd ssa && make)