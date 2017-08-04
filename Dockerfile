# See: https://surfingthe.cloud/the-docker-mind-shift/
# This should be alpine, but splunk doesn't have a musl binary, only glibc
# SPLUNK: please release a musl binary?
FROM openjdk:8-jre

ARG SPLUNK_VERSION=6.6.2
ARG SPLUNK_BUILD=4b804538c686
ARG SPLUNK_FILE=splunkforwarder-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz

ENV PATH="${PATH}:/splunk/bin"
ENV SPLUNK_HOME="/splunk"
ENV SPLUNK_SERVER=splunk
ENV POLL_INTERVAL="60"
ENV AGENT_CONFIG='{"poll-interval":60,"docker-logs":"/var/lib/docker/containers","local-logs":"/log"}'

WORKDIR /agent
COPY agent/requirements.txt /agent/

RUN apt-get update &&\
    apt-get -y upgrade &&\
    apt-get -y install python3 python3-pip curl procps &&\
    mkdir -p /log /splunk &&\
    curl -Lo $SPLUNK_FILE "https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=${SPLUNK_VERSION}&product=universalforwarder&filename=${SPLUNK_FILE}&wget=true"  &&\
    tar -C $SPLUNK_HOME --strip-components=1 -xzf $SPLUNK_FILE  &&\
    rm $SPLUNK_FILE &&\
    # this comes in via external volume
    rm -rf $SPLUNK_HOME/var &&\
    $SPLUNK_HOME/bin/splunk start --accept-license --answer-yes --no-prompt &&\
    $SPLUNK_HOME/bin/splunk stop &&\
    pip3 install -r requirements.txt &&\
    apt-get purge -y --auto-remove curl wget &&\
    rm -rf ~/.cache &&\
    rm -rf /var/lib/apt/lists/*

COPY agent /agent/
COPY config/* /splunk/etc/system/local/

# pass in --build-arg=BUILD_VERSION=xxx to bypass cache and do pkg updates
ARG BUILD_VERSION
RUN echo $BUILD_VERSION &&\
    apt-get update &&\
    apt-get upgrade &&\
    rm -rf ~/.cache &&\
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/agent/splunk-docker"]
