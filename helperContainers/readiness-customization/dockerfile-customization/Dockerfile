ARG COMMON_BASE_VERSION=${COMMON_BASE_VERSION}
ARG COMMON_BASE=armdocker.rnd.ericsson.se/proj-ldc/common_base_os/sles
ARG REPO_PATH=https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles

FROM $COMMON_BASE:$COMMON_BASE_VERSION

ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_VERSION
ARG UID=1000

ARG COMMON_BASE_VERSION
ARG COMMON_BASE
ARG REPO_PATH

LABEL com.ericsson.product-revision="R1 A01 "
LABEL com.ericsson.product-number="CXU 101 1935"
LABEL author="Team Kraken"
LABEL org.opencontainers.image.title="Base"
LABEL org.opencontainers.image.vendor="Ericsson"
LABEL org.opencontainers.image.created=${IMAGE_CREATED}
LABEL org.opencontainers.image.revision=${IMAGE_REVISION}
LABEL org.opencontainers.image.version=${IMAGE_VERSION}

# Add Artifactory Repositories as specificed by the variables - default is ADP arm
RUN zypper ar -C -G -f $REPO_PATH/$COMMON_BASE_VERSION/ LDC-CBO-SLES

RUN zypper in -l -y python311 python311-pip shadow

RUN ln -s /usr/bin/python3.11 /usr/bin/python3

ENV CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
ENV TOKEN="/var/run/secrets/kubernetes.io/serviceaccount/token"

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY ready.py .

ENTRYPOINT ["/app/ready.py"]

RUN echo "$UID:x:$UID:$UID" >> /etc/group && \
    echo "$UID:x:$UID:0:An Identity for :/nonexistent:/bin/false" >>/etc/passwd && \
    echo "$UID:!::0:::::" >> /etc/shadow
    
USER $UID
CMD [""]
