#!/bin/sh
if [ -z "${PG_PASS}" ]
then
  echo "You need to set PG_PASS environment variable to run this script"
  exit 1
fi
if [ -z "${IDB_PASS}" ]
then
  echo "You need to set IDB_PASS environment variable to run this script"
  exit 1
fi
GHA2DB_LOCAL=1 GHA2DB_PROCESS_REPOS=1 ./get_repos
./kubernetes/reinit_all.sh || exit 1
./prometheus/reinit.sh || exit 2
./opentracing/reinit.sh || exit 3
./fluentd/reinit.sh || exit 4
./linkerd/reinit.sh || exit 5
./grpc/reinit.sh || exit 6
./coredns/reinit.sh || exit 7
./containerd/reinit.sh || exit 8
./rkt/reinit.sh || exit 9
./cni/reinit.sh || exit 10
./envoy/reinit.sh || exit 11
./jaeger/reinit.sh || exit 12
./notary/reinit.sh || exit 13
./tuf/reinit.sh || exit 14
./rook/reinit.sh || exit 15
./vitess/reinit.sh || exit 16
./all/reinit.sh || exit 17
./opencontainers/reinit.sh || exit 18
host=`hostname`
if [ $host = "cncftest.io" ]
then
  ./cncf/reinit.sh || exit 19
fi
