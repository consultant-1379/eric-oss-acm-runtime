FROM python:3

ARG CSIT_DIR=${CSIT_DIR}

ENV ROBOT_WORKSPACE /opt/robotworkspace

RUN python3 -m pip install --upgrade pip

RUN python3 -m pip install --upgrade --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" 'robotframework-onap==0.5.1.*' --pre

RUN python3 -m pip freeze

RUN mkdir -p ${ROBOT_WORKSPACE}

COPY ${CSIT_DIR} ${ROBOT_WORKSPACE}

WORKDIR ${ROBOT_WORKSPACE}

RUN chmod +x run-test.sh

CMD ["./run-test.sh"]