FROM ubuntu:latest
MAINTAINER docker@muzik.ca

ENV GITLAB_CI_MULTI_RUNNER_VERSION=10.0.2 \
    GITLAB_CI_MULTI_RUNNER_USER=gitlab_ci_multi_runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab_ci_multi_runner"
ENV GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data"

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      sudo wget git-core openssh-client curl libapparmor1 apt-transport-https ca-certificates software-properties-common \
 && wget -O /usr/local/bin/gitlab-ci-multi-runner \
      https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_CI_MULTI_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64  \
 && chmod 0755 /usr/local/bin/gitlab-ci-multi-runner \
 && adduser --disabled-login --gecos 'GitLab CI Runner' ${GITLAB_CI_MULTI_RUNNER_USER} \
 && sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ln -sf ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 &&  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) \
 stable" \
 && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install docker-ce && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"
ENTRYPOINT ["/sbin/entrypoint.sh"]
