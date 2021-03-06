PROJECT = delayerl

DEPS = cowboy
dep_cowboy_commit = 1.0.4

CT_OPTS += -cover ./test/cover.spec

include erlang.mk


tarball: rel
	GIT_COMMIT=$$(git log --pretty=format:'%H' -n 1); \
	IS_SNAPSHOT=$$(git status --porcelain | grep -q '' && echo "-SNAPSHOT" || echo ""); \
	cd _rel; \
	tar cvzf delayerl-$$GIT_COMMIT$$IS_SNAPSHOT.tar.gz delayerl_node	
container-build:
	docker run -v $$(readlink -f .):/delayerl-src -ti --rm caligin/debian-erlang:d7e17.4 /bin/bash -c "cd /delayerl-src && make -f Makefile.container"
