#!/usr/bin/env bash
#
# The Alluxio Open Foundation licenses this work under the Apache License, version 2.0
# (the "License"). You may not use this work except in compliance with the License, which is
# available at www.apache.org/licenses/LICENSE-2.0
#
# This software is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied, as more fully set forth in the License.
#
# See the NOTICE file distributed with this work for information regarding copyright ownership.
#

#
# This script is run from inside the Docker container
#
set -e

# Set things up so that the current user has a real name and can authenticate.
myuid=$(id -u)
mygid=$(id -g)
echo "$myuid:x:$myuid:$mygid:anonymous uid:/home/jenkins:/bin/false" >> /etc/passwd

if [ -z ${ALLUXIO_BUILD_FORKCOUNT} ]
then
  ALLUXIO_BUILD_FORKCOUNT=4
fi

if [ -n "${ALLUXIO_GIT_CLEAN}" ]
then
  git clean -fdx
fi
mvn -Duser.home=/home/jenkins -T 4C clean install -Pdeveloper -Dmaven.javadoc.skip -Dsurefire.forkCount=${ALLUXIO_BUILD_FORKCOUNT} $@

if [ -n "${ALLUXIO_SONAR_ARGS}" ]
then
  mvn $(echo "${ALLUXIO_SONAR_ARGS}") sonar:sonar
fi
