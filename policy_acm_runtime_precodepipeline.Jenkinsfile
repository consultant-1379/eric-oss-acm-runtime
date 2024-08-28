#!/usr/bin/env groovy

def defaultBobImage = 'armdocker.rnd.ericsson.se/proj-adp-cicd-drop/bob.2.0:1.7.0-55'
def bob = new BobCommand()
    .bobImage(defaultBobImage)
    .envVars([
        HOME:'${HOME}',
        ISO_VERSION:'${ISO_VERSION}',
        RELEASE:'${RELEASE}',
        SONAR_HOST_URL:'${SONAR_HOST_URL}',
        SONAR_AUTH_TOKEN:'${SONAR_AUTH_TOKEN}',
        GERRIT_CHANGE_NUMBER:'${GERRIT_CHANGE_NUMBER}',
        KUBECONFIG:'${KUBECONFIG}',
        K8S_NAMESPACE: '${K8S_NAMESPACE}',
        USER:'${USER}',
        SELI_ARTIFACTORY_REPO_USER:'${CREDENTIALS_SELI_ARTIFACTORY_USR}',
        SELI_ARTIFACTORY_REPO_PASS:'${CREDENTIALS_SELI_ARTIFACTORY_PSW}',
        SERO_ARTIFACTORY_REPO_USER:'${CREDENTIALS_SERO_ARTIFACTORY_USR}',
        SERO_ARTIFACTORY_REPO_PASS:'${CREDENTIALS_SERO_ARTIFACTORY_PSW}',
        SCAS_TOKEN: '${CREDENTIALS_SCAS_TOKEN}',
        XRAY_USER:'${CREDENTIALS_XRAY_SELI_ARTIFACTORY_USR}',
        XRAY_APIKEY:'${CREDENTIALS_XRAY_SELI_ARTIFACTORY_PSW}',
        VHUB_API_TOKEN:'${VHUB_API_TOKEN}',
        MAVEN_CLI_OPTS: '${MAVEN_CLI_OPTS}',
        OPEN_API_SPEC_DIRECTORY: '${OPEN_API_SPEC_DIRECTORY}',
        GERRIT_EST_TECH_USER:'${CREDENTIALS_GERRIT_EST_TECH_USR}',
        GERRIT_EST_TECH_PASS:'${CREDENTIALS_GERRIT_EST_TECH_PSW}',
        MVN_BUILDER_TAG:'${MVN_BUILDER_TAG}',
        ERICSSON_ARM_USERNAME:'${CREDENTIALS_SELI_ARTIFACTORY_USR}',
        ERICSSON_ARM_PASSWORD:'${CREDENTIALS_SELI_ARTIFACTORY_PSW}',
        HELM_CHART_NAME:'${HELM_CHART_NAME}',
        VERSION_TAG:'${VERSION_TAG}',
        GLOBAL_PULLSECRET: '${GLOBAL_PULLSECRET}',
        DATASTORE_POSTGRES_VERSION: '${DATASTORE_POSTGRES_VERSION}',
        ADP_BASE_VERSION: '${ADP_BASE_VERSION}',
        RELEASE_CANDIDATE: '${RELEASE_CANDIDATE}',
        RELEASE_DEPENDENCIES_FILE: '${RELEASE_DEPENDENCIES_FILE}',
        PREP_DEPENDENCIES_FILE: '${PREP_DEPENDENCIES_FILE}',
        DOCKERFILE_PATH:'${DOCKERFILE_PATH}',
        ACM_IMAGE:'${ACM_IMAGE}',
        FOSSA_API_KEY: '${CREDENTIALS_FOSSA_API_KEY}',
        DEP_REG_PROD_ID: '${DEP_REG_PROD_ID}',
        DEP_REG_VER_ID: '${DEP_REG_VER_ID}',
        DEP_REG_DRY_RUN: '${DEP_REG_DRY_RUN}',
        ADP_BOB_SCAS_NAME_MAP: '${ADP_BOB_SCAS_NAME_MAP}',
        OVERRIDE_SCAS_NAME_MAP: '${OVERRIDE_SCAS_NAME_MAP}',
        PROJECT_SCAS_NAME_MAP: '${PROJECT_SCAS_NAME_MAP}',
        FOSSA_REPORT_COMMON: '${FOSSA_REPORT_COMMON}',
        FOSSA_REPORT_MODELS: '${FOSSA_REPORT_MODELS}',
        FOSSA_REPORT_RUNTIME_ACM: '${FOSSA_REPORT_RUNTIME_ACM}',
        MANUAL_LICENSE_AGREEMENT: '${MANUAL_LICENSE_AGREEMENT}',
        BAZAAR_TOKEN: '${CREDENTIALS_BAZAAR}',
        ADP_PORSZOP_TAL_API_KEY:'${SZOP_ADP_PORTAL_API_KEY}',
        BASE_IMAGE_REG_PATH: '${BASE_IMAGE_REG_PATH}',
        ROBOT_TEST_IMAGE_NAME:'${ROBOT_TEST_IMAGE_NAME}',
        DOCKER_IMAGE_TAG: '${DOCKER_IMAGE_TAG}',
        POLICY_RUNTIME_ACM_TEST_CASE: '${POLICY_RUNTIME_ACM_TEST_CASE}',
        TEST_CHART_NAME: '${TEST_CHART_NAME}'
        ])
    .needDockerSocket(true)
    .toString()

@Library('oss-common-pipeline-lib@dVersion-2.0.0-hybrid') _ // Shared library from the OSS/com.ericsson.oss.ci/oss-common-ci-utils
def LOCKABLE_RESOURCE_LABEL = "kaas"

def ACM_REPO="armdocker.rnd.ericsson.se/proj-est-policy"
def ACM_HELM_CHART='eric-oss-acm-runtime'
def ACM_IMAGES=['eric-oss-acm-runtime', 'eric-oss-acm-runtime-readiness' , 'eric-oss-acm-runtime-envsubst', 'eric-oss-acm-runtime-crunchypostgres','eric-oss-acm-runtime-db-migrator']
def DOCKERFILE_PATHS_HADOLINT=['./helperContainers/envsubst-customization/dockerfile-customization/Dockerfile', './helperContainers/readiness-customization/dockerfile-customization/Dockerfile', './helperContainers/crunchypostgres-customization/dockerfile-customization/Dockerfile','./docker/policy-db-migrator/src/main/docker/Dockerfile','./clamp/packages/policy-clamp-docker/src/main/docker/A1pmsParticipant.Dockerfile','./clamp/packages/policy-clamp-docker/src/main/docker/AcmRuntime.Dockerfile','./clamp/packages/policy-clamp-docker/src/main/docker/ElementParticipant.Dockerfile','./clamp/packages/policy-clamp-docker/src/main/docker/HttpParticipant.Dockerfile', './clamp/packages/policy-clamp-docker/src/main/docker/KserveParticipant.Dockerfile','./clamp/packages/policy-clamp-docker/src/main/docker/KubernetesParticipant.Dockerfile', './clamp/packages/policy-clamp-docker/src/main/docker/PolicyParticipant.Dockerfile']
def CSIT_HELM_CHART="eric-oss-csit-test"
def DIRECTORIES=["clamp", "uds-customizations", "policy-parent", "policy-common", "policy-models",  "readiness", "envsubst", "."]

pipeline {
    agent {
        node {
            label NODE_LABEL
        }
    }

    options {
        timestamps()
        timeout(time: 90, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '50', artifactNumToKeepStr: '50'))
    }

    environment {
        TEAM_NAME = "${teamName}"
        KUBECONFIG = "${WORKSPACE}/.kube/config"
        CREDENTIALS_XRAY_SELI_ARTIFACTORY = credentials('XRAY_SELI_ARTIFACTORY')
        CREDENTIALS_SELI_ARTIFACTORY = credentials('SELI_ARTIFACTORY')
        CREDENTIALS_SERO_ARTIFACTORY = credentials('SERO_ARTIFACTORY')
        CREDENTIALS_GERRIT_EST_TECH = credentials('EST_GERRIT_TOKEN')
        CREDENTIALS_SCAS_TOKEN = credentials('SCAS_token')
        MAVEN_CLI_OPTS = "-Duser.home=${env.HOME} -B -U -s ${env.WORKSPACE}/settings-odysseus.xml"
        OPEN_API_SPEC_DIRECTORY = "src/main/resources/v1"
        VHUB_API_TOKEN = credentials('vhub-api-key-id')
        HADOLINT_ENABLED = "true"
        KUBEAUDIT_ENABLED = "true"
        KUBESEC_ENABLED = "true"
        MVN_BUILDER_TAG = "python3-latest"
        POLICY_TAG = "${POLICY_TAG}"
        GLOBAL_PULLSECRET = "--set global.pullSecret=armdocker"
        DATASTORE_POSTGRES_VERSION = "7.5.0+50"
        HELM_CHART_NAME = "${ACM_HELM_CHART}"
        VERSION_TAG = "3.4.0"
        ADP_BASE_VERSION = "6.13.0-10"
        // RELEASE_CANDIDATE - For the License Generation Step. Is the intended version of RPM CBOS based images to scan for licenses.
        RELEASE_CANDIDATE = "3.3.0-12"
        RELEASE_DEPENDENCIES_FILE = "fossa/releases/3.3.0/dependencies-acmr-7-1-2.yaml"
        // WARNING!!! This file is used to make generic FOSS requests to SCAS. Ensure that you have prepared the PREP_DEPENDENCIES_FILE before running. For more info see TEAM KRAKEN RELEASE GUIDE
        PREP_DEPENDENCIES_FILE = "fossa/releases/3.4.0/dependencies.yaml"
        BASE_IMAGE_REG_PATH = "armdocker.rnd.ericsson.se/proj-est-policy"
        CREDENTIALS_FOSSA_API_KEY = credentials('FOSSA_API_token')
        CREDENTIALS_BAZAAR = credentials('BAZAAR_token')
        DEP_REG_PROD_ID = "6357" // EIC Product
        DEP_REG_VER_ID = "6268"
        DEP_REG_DRY_RUN = 'false' // Enable dry run for dependency register stage
        FOSSA_ENABLED = 'true'
        ADP_BOB_SCAS_NAME_MAP = "/usr/share/foss/resources/bazaar_name_map.csv"
        OVERRIDE_SCAS_NAME_MAP = "override_scas_name_map.csv"
        PROJECT_SCAS_NAME_MAP = "policy_acm_scas_name_map.csv"
        FOSSA_REPORT_COMMON = "fossa/releases/3.3.0/fossa-report-common.json"
        FOSSA_REPORT_MODELS = "fossa/releases/3.3.0/fossa-report-models.json"
        FOSSA_REPORT_RUNTIME_ACM = "fossa/releases/3.3.0/fossa-report-acm.json"
        MANUAL_LICENSE_AGREEMENT = "fossa/releases/3.3.0/manual-license-agreement.json"
        SQ_ENABLED = "true"
        ROBOT_TEST_IMAGE_NAME = 'policy-acm-csit-image'
        POLICY_RUNTIME_ACM_TEST_CASE = 'Healthcheck'
        TEST_CHART_NAME = "${CSIT_HELM_CHART}"
        ERICSSON_ARM_USERNAME = "${CREDENTIALS_SELI_ARTIFACTORY_USR}"
        ERICSSON_ARM_PASSWORD = "${CREDENTIALS_SELI_ARTIFACTORY_PSW}"
        PREVIOUS_VERSION = "3.4.0"
        EiffelRequestBodyStart = '''{"msgParams":{"meta":{"id":"bf15498e-8cff-11ed-8edf-8b01ba368d14","type":"EiffelActivityTriggeredEvent","time":12345678,"tags":[],"source":{"domainId":"est","host":"fem1s11-eiffel216.eiffel.gic.ericsson.se:","name":"central.jenkins","uri":"https://central.jenkins.est.tech/"}}},"eventParams":{"data":{"name":"AegisUpdatePatchset","customData":[{"key":"MESSAGE","value":"''' + "${BUILD_URL}" + '''"},{"key":"STATUS","value":"STARTING"},{"key":"PATCHSET","value":"''' + "${GERRIT_REFSPEC}" + '''"}]},"links":[]}}'''
        EiffelRequestBodySuccess = '''{"msgParams":{"meta":{"id":"bf15498e-8cff-11ed-8edf-8b01ba368d14","type":"EiffelActivityTriggeredEvent","time":12345678,"tags":[],"source":{"domainId":"est","host":"fem1s11-eiffel216.eiffel.gic.ericsson.se:","name":"central.jenkins","uri":"https://central.jenkins.est.tech/"}}},"eventParams":{"data":{"name":"AegisUpdatePatchset","customData":[{"key":"MESSAGE","value":"''' + "${BUILD_URL}" + '''"},{"key":"STATUS","value":"FINISHED_SUCCESS"},{"key":"PATCHSET","value":"''' + "${GERRIT_REFSPEC}" + '''"}]},"links":[]}}'''
        EiffelRequestBodyFailure = '''{"msgParams":{"meta":{"id":"bf15498e-8cff-11ed-8edf-8b01ba368d14","type":"EiffelActivityTriggeredEvent","time":12345678,"tags":[],"source":{"domainId":"est","host":"fem1s11-eiffel216.eiffel.gic.ericsson.se:","name":"central.jenkins","uri":"https://central.jenkins.est.tech/"}}},"eventParams":{"data":{"name":"AegisUpdatePatchset","customData":[{"key":"MESSAGE","value":"''' + "${BUILD_URL}" + '''"},{"key":"STATUS","value":"FINISHED_FAILED"},{"key":"PATCHSET","value":"''' + "${GERRIT_REFSPEC}" + '''"}]},"links":[]}}'''
        MAILRECEPTIANTS = "andrew.fenner@est.tech"
    }

    // Stage names (with descriptions) taken from ADP Microservice CI Pipeline Step Naming Guideline: https://confluence.lmera.ericsson.se/pages/viewpage.action?pageId=122564754
    stages {

        stage('Clone All Repos') {
            steps {
                script{
                  httpRequest url: "http://20.223.249.41/publish/generateAndPublish?msgType=EiffelActivityTriggeredEvent&mp=eiffelsemantics&tag=est", requestBody: EiffelRequestBodyStart , contentType: 'APPLICATION_JSON' , httpMode: 'POST', consoleLogResponseBody: true , acceptType: 'APPLICATION_JSON'
                }
                sh "mkdir -p policy-parent policy-common policy-models clamp uds-customizations readiness envsubst"

                cloneParentRepo()
                cloneCommonRepo()
                cloneModelsRepo()
                cloneClampRepo()
                cloneUDSRepo()
                cloneACMCustomizations()
                cloneReadiness()
                cloneDBMigrator()
                copyCustomizations()
            }
        }

        stage('Customize Images') {
            steps {
                echo "User = ${USER}"
                customizeImage(file:'readiness',path:'policy-acm-customizations/helperContainers/readiness-customization/dockerfile-customization')
                customizeImage(file:'envsubst',path:'policy-acm-customizations/helperContainers/envsubst-customization/dockerfile-customization')
                sh "${bob} translator:translate-dockerfile-precode"
                sh "${bob} translator_db_migrator"
            }
        }

        stage('Clean') {
            steps {
                echo 'Inject settings.xml into workspace:'
                configFileProvider([configFile(fileId: "${env.SETTINGS_CONFIG_FILE_NAME}", targetLocation: "${env.WORKSPACE}")]) {}
                archiveArtifacts allowEmptyArchive: true, artifacts: 'ruleset2.0.yaml, policy_acm_runtime_precodepipeline.Jenkinsfile'
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh "${bob} clean"
                }
            }
        }

        stage('Init') {
            steps {
                sh "${bob} init-precodereview"
                initPostSteps()
            }
        }

        stage('Lint') {
            steps {
                parallel(
                    "lint markdown": {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh "echo policytag ${POLICY_TAG}"
                        sh "${bob} lint:markdownlint lint:vale"
                        }
                    },
                    "lint helm": {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh "${bob} lint:helmdependencyupdate"
                        sh "${bob} lint:helm"
                        }
                    },
                    "lint helm design rule checker": {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh "${bob} lint:helm-chart-check"
                         }
                    },
                    "SDK Validation": {
                        sh "${bob} validate-sdk"
                   }
                )
            }
            post {
                always {
                   archiveArtifacts allowEmptyArchive: true, artifacts: '**/*bth-linter-output.html, **/design-rule-check-report.*'
                }
            }
        }

        stage('Vulnerability Analysis') {
            steps {
                parallel(
                    "Hadolint": {
                        hadolint(bob,DOCKERFILE_PATHS_HADOLINT)
                    },
                    "Kubeaudit": {
                        kubeaudit(bob)
                    },
                    "Kubsec": {
                        kubesec(bob)
                    }
                )
            }
        }

        stage('Generate Vulnerability report V2.0'){
            steps {
                script {
                    sh "mkdir -p build/va-reports/VA-reports"
                    for (image in ACM_IMAGES) {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        withEnv(["ACM_IMAGE=${image}", "VERSION_TAG=${POLICY_TAG}"]) {
                        sh "${bob} generate-VA-report-V2:no-upload"
                        sh'''
                            echo "image:${ACM_IMAGE}"
                            sed -i 's#build/va-reports/VA-reports/{image}-{version}-Vulnerability_Report_2.0.md#build/va-reports/VA-reports/'"${ACM_IMAGE}"'-'"${VERSION_TAG}"'-Vulnerability_Report_2.0.md#g' config/va_html_config.yaml
                        '''
                        sh "${bob} generate-VA-report-V2:va-report-to-html"
                        sh '''
                            sed -i 's#build/va-reports/VA-reports/'"${ACM_IMAGE}"'-'"${VERSION_TAG}"'-Vulnerability_Report_2.0.md#build/va-reports/VA-reports/{image}-{version}-Vulnerability_Report_2.0.md#g' config/va_html_config.yaml
                        '''
                        }
                        }
                    }
                }
                archiveArtifacts allowEmptyArchive: true, artifacts: 'build/va-reports/VA-reports/**/*.*'
            }
        }

        stage('Generate csv & compare'){
            steps{
                script{
                    sh "mkdir -p va_summary"
                    for (image in ACM_IMAGES) {
                        withEnv(["ACM_IMAGE=${image}"]) {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            sh "cp  -R build/va-reports/VA-reports/${ACM_IMAGE}-**.md va_summary"
                        }
                        }
                    }
                    for (image in ACM_IMAGES) {
                        withEnv(["ACM_IMAGE=${image}"]) {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh'''
                        chmod 777 va_summary
                        mkdir -p va_summary/${ACM_IMAGE}
                        mv va_summary/${ACM_IMAGE}-${VERSION_TAG}-*.md va_summary/${ACM_IMAGE}/Vulnerability_Report_2.0.md

                        chmod 777 va_summary/${ACM_IMAGE}
                        cd va_summary/${ACM_IMAGE}
                        echo "version-tag: ${VERSION_TAG} "
                        docker pull armdocker.rnd.ericsson.se/proj-axis_test/va-summary:latest
                        docker run --init --rm -v$(pwd):/va_summary armdocker.rnd.ericsson.se/proj-axis_test/va-summary:latest ./va_report.py ${VERSION_TAG}  --user ${ERICSSON_ARM_USERNAME} --token ${ERICSSON_ARM_PASSWORD} --url https://arm.seli.gic.ericsson.se/artifactory/proj-est-poc-generic-local -d ${ACM_IMAGE}
                        docker run --init --rm -v$(pwd):/va_summary armdocker.rnd.ericsson.se/proj-axis_test/va-summary:latest ./va_diff.py ${PREVIOUS_VERSION}  ${VERSION_TAG}  --user ${ERICSSON_ARM_USERNAME} --token ${ERICSSON_ARM_PASSWORD} --url https://arm.seli.gic.ericsson.se/artifactory/proj-est-poc-generic-local -d ${ACM_IMAGE}

                        '''
                        }
                        archiveArtifacts artifacts:'va_summary/${ACM_IMAGE}/totals.csv', allowEmptyArchive: true
                        archiveArtifacts artifacts: 'va_summary/${ACM_IMAGE}/added.csv', allowEmptyArchive: true
                        archiveArtifacts artifacts: 'va_summary/${ACM_IMAGE}/removed.csv', allowEmptyArchive: true
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
                withEnv(["VERSION_TAG=${POLICY_TAG}"]) {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                echo "policytag ${POLICY_TAG}"
                echo "versiontag ${VERSION_TAG}"
                //Build readiness
                sh "${bob} build-readiness"
                //Build envsubst
                sh "${bob} build-envsubst"
                //Build crunchypostgres
                sh "${bob} build-crunchypostgres"
                //Build db-migrator
                sh "${bob} build-db-migrator"
                //Build parent components
                sh "${bob} build-all-parent"
                //Build runtime acm
                script {
                    ci_pipeline_scripts.retryMechanism("${bob} build", 3)
                }
                }
                }
            }
        }

        stage('Build CSIT test') {
            environment {
              POLICY_TAG = sh(script: "echo \${POLICY_TAG}" , returnStdout: true).trim()
            }
            steps {
                withEnv(["VERSION_TAG=${POLICY_TAG}"]) {
                sh "${bob} Build-csit-robot-test-image"
                }
            }
        }

        stage('Parallel Streams'){
            parallel{
                stage('Generate') {
                    steps {
                        sh "${bob} generate-docs"
                        archiveArtifacts "doc/**/*.*"
                        publishHTML (target: [
                            allowMissing: false,
                            alwaysLinkToLastBuild: false,
                            keepAll: true,
                            reportDir: 'doc',
                            reportFiles: 'CTA_api.html',
                            reportName: 'REST API Documentation'
                        ])
                    }
                }

                stage('Sonar Stream'){
                    stages{
                        stage('Test') {
                            steps {
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                script {
                                    ci_pipeline_scripts.retryMechanism("${bob} test", 3)
                                }
                            }
                        }
                        post {
                            always {
                                archiveArtifacts allowEmptyArchive: true, artifacts: 'build/va-reports/jacoco-reports/**'
                            }
                        }
                        }
                        stage('SonarQube Analysis') {
                            when {
                                expression { env.SQ_ENABLED == "true" }
                            }
                            steps {
                                withSonarQubeEnv("${env.SQ_SERVER}") {
                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    sh "${bob} sonar-enterprise-pcr"
                                }
                                }
                            }
                        }
                        stage('SonarQube Quality Gate') {
                            when {
                                expression { env.SQ_ENABLED == "true" }
                            }
                        steps {
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            timeout(time: 5, unit: 'MINUTES') {
                                waitUntil {
                                    withSonarQubeEnv("${env.SQ_SERVER}") {
                                    script {
                                        return getQualityGate()
                                    }
                                    }
                                }
                            }
                            }
                        }
                        }

                    }
                }
                stage('Image Stream'){
                    stages{
                        stage('Image') {
                            steps {
                                script {
                                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    withEnv(["VERSION_TAG=${POLICY_TAG}"]) {
                                    script {
                                        ci_pipeline_scripts.retryMechanism("${bob} image", 3)
                                    }
                                    }
                                    for (image in ACM_IMAGES) {
                                        withEnv(["ACM_IMAGE=${image}", "VERSION_TAG=${POLICY_TAG}"]) {
                                        echo "image:${ACM_IMAGE} "
                                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                            sh "${bob} image-dr-check"
                                        }
                                        }
                                    }
                                    }
                                }
                            }
                            post {
                                always {
                                    archiveArtifacts allowEmptyArchive: true, artifacts: '**/image-design-rule-check-report*'
                                }
                            }
                        }
                        stage('Package') {
                            steps {
                                script {
                                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    for (image in ACM_IMAGES) {
                                        withEnv(["ACM_IMAGE=${image}","VERSION_TAG=${POLICY_TAG}"]) {
                                            echo "pushing image:${ACM_IMAGE} "
                                            sh "${bob} package-image"
                                        }
                                    }
                                    withEnv(["VERSION_TAG=${POLICY_TAG}"]) {
                                        sh "${bob} package"
                                        sh "${bob} package-jars"
                                    }
                                    }
                                }
                            }
                            post {
                                cleanup {
                                    script {
                                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                            for (image in ACM_IMAGES) {
                                                withEnv(["ACM_IMAGE=${image}","VERSION_TAG=${POLICY_TAG}"]) {
                                                sh "${bob} delete-images:delete-internal-image"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
                stage('FOSSA'){
                    when {
                        expression { env.FOSSA_ENABLED == "true" }
                    }
                    steps {
                        sh "cp ./uds-customizations/settings-odysseus.xml ~/.m2/settings.xml"
                        // Generate FOSS Reports for Policy-Common, Models & Clamp
                        // Readiness, Envsubst and Crunchypostgres not included as no targets to analyse
                        // Policy Parent commented out as fossa-scan fails to detect dependencies, further investigation is needed
                        sh "${bob} fossa-analyze && ${bob} fossa-scan-status-check && ${bob} fetch-fossa-report-attribution"
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            // Convert fossa json reports to yaml
                            sh "${bob} dependency-update"
                            // Merge Policy-Common, Models and Clamp fossa reports together
                            sh "${bob} dependency-merge"
                            modifyFOSSReport()
                            withCredentials([string(credentialsId: 'SCAS_token', variable: 'SCAS_TOKEN')]) {
                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                sh "${bob} scan-scas"
                                }
                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    // Fix for "ValidationError: '<some unknown value>' is not one of ['linux']"
                                    sh "sed -i 's#component_platform: linux x86 (64 bit)#component_platform: linux#g' dependencies.yaml"
                                    sh "sed -i 's#component_platform: solaris, linux, windows#component_platform: linux#g' dependencies.yaml"
                                    sh "${bob} dependency-enrich"
                                }
                                }
                        }
                        sh "mkdir -p diff-reports"
                        sh "${bob} create-foss-report-diff"
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            // WARNING!!! This will make generic FOSS requests to SCAS. Ensure that you have prepared the PREP_DEPENDENCIES_FILE before running. For more info see TEAM KRAKEN RELEASE GUIDE
                            sh "${bob} update-prep-deps-file"
                            sh "${bob} dependency-validate"
                        }
                        archiveArtifacts allowEmptyArchive: true, artifacts: "*fossa-report*.json, dependencies*.yaml, diff-reports/**, ${PREP_DEPENDENCIES_FILE}"
                    }
                }

            }
        }

        stage('K8S Resource Lock') {
            options {
                lock(label: LOCKABLE_RESOURCE_LABEL, variable: 'RESOURCE_NAME', quantity: 1)
            }
            environment {
                K8S_CLUSTER_ID = sh(script: "echo \${RESOURCE_NAME} | cut -d'_' -f1", returnStdout: true).trim()
                K8S_NAMESPACE = sh(script: "echo \${RESOURCE_NAME} | cut -d',' -f1 | cut -d'_' -f2", returnStdout: true).trim()
            }
            stages {
                stage('Helm Install') {
                    steps {
                        echo "Inject kubernetes config file (${env.K8S_CLUSTER_ID}) based on the Lockable Resource name: ${env.RESOURCE_NAME}"
                        configFileProvider([configFile(fileId: "${env.K8S_CLUSTER_ID}", targetLocation: "${env.KUBECONFIG}")]) {}
                        echo "The namespace (${env.K8S_NAMESPACE}) is reserved and locked based on the Lockable Resource name: ${env.RESOURCE_NAME}"
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh "${bob} create-namespace"

                        withEnv(["VERSION_TAG=${POLICY_TAG}","HELM_CHART_NAME=${ACM_HELM_CHART}"]) {
                            sh "${bob} helm-dry-run"
                        }
                        script{
                            withEnv(["VERSION_TAG=${POLICY_TAG}","HELM_CHART_NAME=${ACM_HELM_CHART}"]) {
                                if (env.HELM_UPGRADE == "true") {
                                    echo "HELM_UPGRADE is set to true:"
                                    sh "${bob} helm-install-dependencies"
                                    sh "${bob} helm-upgrade"
                                } else {
                                    echo "HELM_UPGRADE is NOT set to true:"
                                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    sh "${bob} helm-install-dependencies"
                                    sh "${bob} helm-install"
                                    sleep(60)
                                    }
                                }
                            }
                        }
                        withEnv(["VERSION_TAG=${POLICY_TAG}"]) {
                            sh "${bob} healthcheck"
                        }
                        }

                    }
                    post {
                        always {
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            sh "${bob} check-pods"
                            sh "${bob} kaas-info || true"
                            archiveArtifacts allowEmptyArchive: true, artifacts: 'build/kaas-info.log'
                            }
                        }
                        unsuccessful {

                            sh "${bob} collect-k8s-logs || true"
                            archiveArtifacts allowEmptyArchive: true, artifacts: "k8s-logs/*"
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            sh "${bob} delete-namespace"
                            }
                        }
                    }
                }

                stage('K8S Test') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh "${bob} helm-test"
                        }
                    }
                }

                stage('Run CSIT test') {
                    environment {
                    POLICY_TAG = sh(script: "echo \${POLICY_TAG}" , returnStdout: true).trim()
                    }
                    steps {
                        withEnv(["VERSION_TAG=${POLICY_TAG}", "HELM_CHART_NAME=${CSIT_HELM_CHART}"]) {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh "${bob} run-csit-robot-test"
                        }
                        }
                    }
                }
            }
        }

        stage('Upload Marketplace Documentation') {
            steps {
                withCredentials([string(credentialsId: 'SZOP_ADP_PORTAL_API_KEY',variable: 'SZOP_ADP_PORTAL_API_KEY')]) {
                     sh "${bob} marketplace-upload-dev"
                }
            }
        }

        stage('Generate License Agreement'){
            when {
                expression {env.FOSSA_ENABLED == 'true' }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                  sh "${bob} license-agreement-generate"
                  archiveArtifacts '*license-agreement*.json'
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                  sh "${bob} license-agreement-validate-fragments"
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                  sh "${bob} license-agreement-merge-fragments"
                  archiveArtifacts 'license.agreement.json'
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                  sh "${bob} release-license-agreement-validate"
                }
                // I don't think we should need this for microservice,
                //   but including in case asked for markdown version
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                  sh "${bob} release-license-agreement-generate-markdown"
                  archiveArtifacts 'license.agreement.md'
                }
            }
        }
    }
    post {
        success {
            script {
                sh "${bob} helm-chart-check-report-warnings"
                addHelmDRWarningIcon()
                modifyBuildDescription()
                if (GERRIT_REFSPEC != "refs/heads/master") {
                      httpRequest url: "http://20.223.249.41/publish/generateAndPublish?msgType=EiffelActivityTriggeredEvent&mp=eiffelsemantics&tag=est", requestBody: EiffelRequestBodySuccess , contentType: 'APPLICATION_JSON' , httpMode: 'POST', consoleLogResponseBody: true , acceptType: 'APPLICATION_JSON'
                }
                else {
                      FULLTEXT = ""
                      for (directory in DIRECTORIES){
                          FULLTEXT = FULLTEXT + getLogInfo(directory)
                      }
                      mail body: "<b>Build Triggered by Opensource delivery</b><br>Project: ${JOB_NAME} <br>Build Node: ${NODE_NAME} <br> URL of build: ${BUILD_URL} <br> ${FULLTEXT}", charset: 'UTF-8', mimeType: 'text/html', subject: "SUCCESS CI: Project name -> ${JOB_NAME}", to: MAILRECEPTIANTS;
                }
            }
        }
        failure {
            script {
                      if (GERRIT_REFSPEC != "refs/heads/master") {
                        def response =  httpRequest url: "http://20.223.249.41/publish/generateAndPublish?msgType=EiffelActivityTriggeredEvent&mp=eiffelsemantics&tag=est", requestBody: EiffelRequestBodyFailure , contentType: 'APPLICATION_JSON' , httpMode: 'POST', consoleLogResponseBody: true , acceptType: 'APPLICATION_JSON'
                      }
                      else {
                            FULLTEXT = ""
                            for (directory in DIRECTORIES){
                                FULLTEXT = FULLTEXT + getLogInfo(directory)
                            }
                            mail body: "<b>Build Triggered by Opensource delivery</b><br>Project: ${JOB_NAME} <br>Build Node: ${NODE_NAME} <br> URL of build: ${BUILD_URL} <br> ${FULLTEXT}", charset: 'UTF-8', mimeType: 'text/html', subject: "FAILURE CI: Project name -> ${JOB_NAME}", to: MAILRECEPTIANTS;
                      }
            }
        }
    }
}


def kubesec(bob) {
    script {
        if (env.KUBESEC_ENABLED == "true") {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                sh "${bob} kubesec-scan"
                archiveArtifacts 'build/va-reports/kubesec-reports/*'
            }
        }
    }
}

def kubeaudit(bob) {
    script {
        if (env.KUBEAUDIT_ENABLED == "true") {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            sh "${bob} kube-audit"
            archiveArtifacts "build/va-reports/kube-audit-report/**/*"
            }
        }
    }
}

def hadolint(bob,DOCKERFILE_PATHS_HADOLINT){
    script {
        if (env.HADOLINT_ENABLED == "true") {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            for (path in DOCKERFILE_PATHS_HADOLINT) {
                DOCKERFILE_PATH="${path}"
                withEnv(["DOCKERFILE_PATH=${DOCKERFILE_PATH}"]) {
                    sh "${bob} hadolint-scan"
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    echo "Evaluating Hadolint Scan Resultcodes..."
                    PATHNAME =  sh(script: "echo ${path} | sed 's#/#_#g'" , returnStdout: true).trim()
                    sh "cp build/va-reports/hadolint-scan/hadolint_Dockerfile_report.json  build/va-reports/hadolint-scan/hadolint_Dockerfile_report-${PATHNAME}.json"
                    sh "${bob} evaluate-design-rule-check-resultcodes"
                    }

                    }
                }

            }
            archiveArtifacts "build/va-reports/hadolint-scan/**.*"

        }
    }
}

def initPostSteps() {
    sh '''#!/bin/bash
        POLICY_TAG=$(cat .bob/var.version)
        echo ${POLICY_TAG}
        echo "  - image-product-number: ${POLICY_TAG}" >> common-properties.yaml
        echo "${POLICY_TAG}" > VERSION_PREFIX
    '''
    script {
        POLICY_TAG=sh(returnStdout: true, script: 'cat VERSION_PREFIX').trim()
        echo "policytag ${POLICY_TAG}"
        authorName = sh(returnStdout: true, script: 'git show -s --pretty=%an')
        currentBuild.displayName = currentBuild.displayName + ' / ' + authorName
    }
}

def copyCustomizations() {
    sh '''#!/bin/bash -x
        mkdir -p charts sdk-docs marketplace/docs testautomation
        cp -R ./policy-acm-customizations/Bob-customizations/* .
        cp -R ./policy-acm-customizations/ruleset2.0.yaml .
        cp -R ./policy-acm-customizations/charts/eric-oss-acm-runtime charts
        cp -R ./policy-acm-customizations/base-docker .
        cp -R ./policy-acm-customizations/sdk-docs/* sdk-docs
        cp -R ./policy-acm-customizations/VERSION_PREFIX VERSION_PREFIX
        cp -R ./policy-acm-customizations/marketplace/* marketplace
        cp -R ./clamp/README.md marketplace/docs
        cp -R ./policy-acm-customizations/testautomation/eric-oss-policy-acm-test testautomation
        cp ./policy-acm-customizations/fossa/${PROJECT_SCAS_NAME_MAP} .
        cp -R ./uds-customizations//settings-odysseus.xml .
        cp -R ./policy-acm-customizations/fossa/foss-scripts/ .

        echo "  - helm-chart-test: eric-oss-policy-acm-test" >> common-properties.yaml
    '''
}

def cloneReadiness() {
    //Cloning OOM readiness
    checkout([
        $class: 'GitSCM',
        branches: [[name: "6.0.3"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'readiness']],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://gerrit.est.tech/a/oss/onap/oom/readiness", credentialsId:'EST_GERRIT_TOKEN']],
    ])
}

def cloneDBMigrator() {
    //Cloning policy docker repo for policy-db-migrator
    checkout([
        $class: 'GitSCM',
        branches: [[name: "master"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'docker']],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://gerrit.est.tech/a/oss/onap/policy/docker", credentialsId:'EST_GERRIT_TOKEN']],
    ])
}

def cloneACMCustomizations() {
    //Cloning policy acm customization repo
    checkout([
        $class: 'GitSCM',
        branches: [[name: "FETCH_HEAD"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'policy-acm-customizations']],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://gerrit.est.tech/a/aegis/onap/policy-acm-runtime-customization", credentialsId:'EST_GERRIT_TOKEN', refspec:'${GERRIT_REFSPEC}']],
    ])
}

def cloneUDSRepo() {
    //Cloning uds customization repo
    checkout([
        $class: 'GitSCM',
        branches: [[name: "master"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'uds-customizations']],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://gerrit.est.tech/a/aegis/onap/uds-customization", credentialsId:'EST_GERRIT_TOKEN']],
    ])
}

def cloneClampRepo() {
    //Cloning policy clamp repo
    checkout([
        $class: 'GitSCM',
        branches: [[name: "master"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'clamp']],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://gerrit.est.tech/a/oss/onap/policy/clamp", credentialsId:'EST_GERRIT_TOKEN']],
    ])
}

def cloneModelsRepo() {
    //Cloning policy models repo
    checkout([
        $class: 'GitSCM',
        branches: [[name: "master"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'policy-models']],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://gerrit.est.tech/a/oss/onap/policy/models", credentialsId:'EST_GERRIT_TOKEN']],
    ])
}

def cloneCommonRepo() {
    //Cloning policy common repo
    checkout([
        $class: 'GitSCM',
        branches: [[name: "master"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'policy-common']],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://gerrit.est.tech/a/oss/onap/policy/common", credentialsId:'EST_GERRIT_TOKEN']],
    ])
}

def cloneParentRepo() {
    //Cloning policy parent repo
      checkout([
        $class: 'GitSCM',
        branches: [[name: "master"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'policy-parent']],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://gerrit.est.tech/a/oss/onap/policy/parent", credentialsId:'EST_GERRIT_TOKEN']],
    ])
}


def modifyFOSSReport() {
    // Workaround to fix dependencies with ID or Package name beginning with (https://)arm.epk.ericsson.se... 
    // as ADP tooling is unable to parse these e.g.,: 
      // from: "arm.epk.ericsson.se_artifactory_proj-ema-remote:org.onap.aaf.authz:aaf-auth-client+2.1.21"
      // to: "org.onap.aaf.authz:aaf-auth-client+2.1.21"
    sh "sed -i 's#ID: arm.epk.ericsson.se_artifactory_proj-ema-remote:#ID: #g' dependencies.yaml"
    sh "sed -i 's#Package: https://arm.epk.ericsson.se/artifactory/proj-ema-remote:#Package: #g' dependencies.yaml"
    sh """
        # Merge Policy ACM mapping file with hardcoded ADP Bob image mapping file
        # Workaround until override feature can be added to ADP Bob
        docker run armdocker.rnd.ericsson.se/proj-adp-cicd-drop/bob-adp-release-auto:latest cat ${ADP_BOB_SCAS_NAME_MAP} > ${OVERRIDE_SCAS_NAME_MAP}
        echo >> ${OVERRIDE_SCAS_NAME_MAP}
        cat ${PROJECT_SCAS_NAME_MAP} >> ${OVERRIDE_SCAS_NAME_MAP}
    """
}

def getLogInfo( directory ) {
    return sh(returnStdout: true,
    script: """
       cd $directory ;
       echo '<br>Changes for directory ' $directory '<br>';
       git log -1 ;
       echo '<br>' ;
    """
    )
}

def modifyBuildDescription() {
    def CHART_NAME = "eric-oss-acm-runtime"
    def DOCKER_IMAGE_NAME = "eric-oss-acm-runtime"
    def VERSION = readFile('.bob/var.version').trim()

    def CHART_DOWNLOAD_LINK = "https://arm.seli.gic.ericsson.se/artifactory/proj-est-onap-helm-local/${CHART_NAME}/${CHART_NAME}-${VERSION}.tgz"
    def DOCKER_IMAGE_DOWNLOAD_LINK = "https://arm.seli.gic.ericsson.se/artifactory/proj-est-policy-docker-global/proj-est-policy/${CHART_NAME}/${VERSION}/"
    currentBuild.description = "Helm Chart: <a href=${CHART_DOWNLOAD_LINK}>${CHART_NAME}-${VERSION}.tgz</a><br>Docker Image: <a href=${DOCKER_IMAGE_DOWNLOAD_LINK}>${DOCKER_IMAGE_NAME}-${VERSION}</a><br>Gerrit: <a href=${env.GERRIT_CHANGE_URL}>${env.GERRIT_CHANGE_URL}</a> <br>"
}
def addHelmDRWarningIcon() {
    def val = readFile '.bob/var.helm-chart-check-report-warnings'
    if (val.trim().equals("true")) {
        echo "WARNING: One or more Helm Design Rules have a WARNING state. Review the Archived Helm Design Rule Check Report: design-rule-check-report.html"
        manager.addWarningBadge("One or more Helm Design Rules have a WARNING state. Review the Archived Helm Design Rule Check Report: design-rule-check-report.html")
    } else {
        echo "No Helm Design Rules have a WARNING state"
    }
}
def customizeImage(Map map){
    def file="${map.file}"
    def path="${map.path}"

    sh '''
        # For each line in the CONFIGURATION_FILE
        while read -r LINE;
        do
        # Split on : and store the path of file to be replaced and the path of file to replace it with
        FILE_TO_REPLACE=$(echo "$LINE" | cut -d : -f 1)
        FILE_TO_REPLACE_WITH=$(echo "$LINE" | cut -d : -f 2)

        echo "----------------------------------------------------"
        echo "INFO: Replacing $FILE_TO_REPLACE with $FILE_TO_REPLACE_WITH"
        echo "----------------------------------------------------"
        cp -R policy-acm-customizations/"$FILE_TO_REPLACE_WITH" '''+file+'''/"$FILE_TO_REPLACE"
        done < "$WORKSPACE/'''+path+'''/replacements.file"
    '''

}
def getQualityGate() {
    echo "Wait for SonarQube Analysis is done and Quality Gate is pushed back:"
    try {
        timeout(time: 60, unit: 'SECONDS') {
            qualityGate = waitForQualityGate()
        }
    } catch(Exception e) {
        return false
    }
    echo 'If Analysis file exists, parse the Dashboard URL:'
    if (fileExists(file: 'clamp/target/sonar/report-task.txt')) {
        sh 'cat clamp/target/sonar/report-task.txt'
        def props = readProperties file: 'clamp/target/sonar/report-task.txt'
        env.DASHBOARD_URL = props['dashboardUrl']
    }
    if (qualityGate.status.replaceAll("\\s","") == 'IN_PROGRESS') {
        return false
    }
    if (!env.GERRIT_HOST) {
        env.GERRIT_HOST = "gerrit.ericsson.se"
    }
    if (qualityGate.status.replaceAll("\\s","") != 'OK') {
        env.SQ_MESSAGE="'"+"SonarQube Quality Gate Failed: ${DASHBOARD_URL}"+"'"
        if (env.GERRIT_CHANGE_NUMBER) {
            sh '''
                ssh -p 29418 ${GERRIT_HOST} gerrit review --label 'SQ-Quality-Gate=-1' --message ${SQ_MESSAGE} --project ${GERRIT_PROJECT} ${GERRIT_PATCHSET_REVISION}
            '''
        }
        manager.addWarningBadge("Pipeline aborted due to Quality Gate failure, see SonarQube Dashboard for more information.")
        error "Pipeline aborted due to quality gate failure!\n Report: ${env.DASHBOARD_URL}\n Pom might be incorrectly defined for code coverage: https://confluence-oss.seli.wh.rnd.internal.ericsson.com/pages/viewpage.action?pageId=309793813"
    } else {
        env.SQ_MESSAGE="'"+"SonarQube Quality Gate Passed: ${DASHBOARD_URL}"+"'"
        if (env.GERRIT_CHANGE_NUMBER) { // If Quality Gate Passed
            sh '''
                ssh -p 29418 ${GERRIT_HOST} gerrit review --label 'SQ-Quality-Gate=+1' --message ${SQ_MESSAGE} --project ${GERRIT_PROJECT} ${GERRIT_PATCHSET_REVISION}
            '''
        }
    }

    return true
}
// More about @Builder: http://mrhaki.blogspot.com/2014/05/groovy-goodness-use-builder-ast.html
import groovy.transform.builder.Builder
import groovy.transform.builder.SimpleStrategy
@Builder(builderStrategy = SimpleStrategy, prefix = '')
class BobCommand {
    def bobImage = 'bob.2.0:latest'
    def envVars = [:]
    def needDockerSocket = true
    String toString() {
        def env = envVars
                .collect({ entry -> "-e ${entry.key}=\"${entry.value}\"" })
                .join(' ')
        def cmd = """\
            |docker run
            |--init
            |--rm
            |--workdir \${PWD}
            |--user \$(id -u):\$(id -g)
            |-v \${PWD}:\${PWD}
            |-v /etc/group:/etc/group:ro
            |-v /etc/passwd:/etc/passwd:ro
            |-v /proj/mvn/:/proj/mvn
            |-v \${HOME}:\${HOME}
            |${needDockerSocket ? '-v /var/run/docker.sock:/var/run/docker.sock' : ''}
            |${env}
            |\$(for group in \$(id -G); do printf ' --group-add %s' "\$group"; done)
            |--group-add \$(stat -c '%g' /var/run/docker.sock)
            |${bobImage}
            |"""
        return cmd
                .stripMargin()           // remove indentation
                .replace('\n', ' ')      // join lines
                .replaceAll(/[ ]+/, ' ') // replace multiple spaces by one
    }
}
