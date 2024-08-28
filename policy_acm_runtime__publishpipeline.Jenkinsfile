#!/usr/bin/env groovy

def defaultBobImage = 'armdocker.rnd.ericsson.se/proj-adp-cicd-drop/bob.2.0:1.7.0-55'
def bob = new BobCommand()
    .bobImage(defaultBobImage)
    .envVars([
        HOME:'${HOME}',
        ISO_VERSION:'${ISO_VERSION}',
        RELEASE:'${RELEASE}',
        RELEASE_PHASE_2: '${RELEASE_PHASE_2}',
        RELEASE_PUBLISH:'${RELEASE_PUBLISH}',
        INT_RELEASE:'${INT_RELEASE}',
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
        GITCA_USERNAME: '${CREDENTIALS_GITCA_USR}',
        GITCA_PASSWORD: '${CREDENTIALS_GITCA_PSW}',
        ACA_USERNAME: '${CREDENTIALS_ACA_USR}',
        ACA_PASSWORD: '${CREDENTIALS_ACA_PSW}',
        XRAY_USER:'${CREDENTIALS_XRAY_SELI_ARTIFACTORY_USR}',
        XRAY_APIKEY:'${CREDENTIALS_XRAY_SELI_ARTIFACTORY_PSW}',
        VHUB_API_TOKEN:'${VHUB_API_TOKEN}',
        MAVEN_CLI_OPTS: '${MAVEN_CLI_OPTS}',
        OPEN_API_SPEC_DIRECTORY: '${OPEN_API_SPEC_DIRECTORY}',
        GERRIT_EST_TECH_USER:'${CREDENTIALS_GERRIT_EST_TECH_USR}',
        GERRIT_EST_TECH_PASS:'${CREDENTIALS_GERRIT_EST_TECH_PSW}',
        GERRIT_REVIEW_PASS_USER: '${CREDENTIALS_GERRIT_REVIEW_USR}',
        GERRIT_REVIEW_PASS_PASS: '${CREDENTIALS_GERRIT_REVIEW_PSW}',
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
        PREP_DEPENDENCIES_FILE = '${PREP_DEPENDENCIES_FILE}',
        ACM_RELEASE_SOURCE_COMMITHASH: '${ACM_RELEASE_SOURCE_COMMITHASH}',
        DOCKERFILE_PATH:'${DOCKERFILE_PATH}',
        ACM_IMAGE:'${ACM_IMAGE}',
        FOSSA_API_KEY: '${CREDENTIALS_FOSSA_API_KEY}',
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
        TEST_CHART_NAME: '${TEST_CHART_NAME}',
        MUNIN_TOKEN: '${CREDENTIALS_MUNIN_TOKEN}'
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
        RELEASE = "false" // If release is false, run publish stages, if true run release stages
        RELEASE_PHASE_2 = "false" // Used to disable/enable second phase of release (GitCA, ACA, Release)
        RELEASE_PUBLISH = "false" // Variable checked before publish of release. When set to true will release and trigger App Staging
        INT_RELEASE = "true"// Used for int-drop
        TEAM_NAME = "${teamName}"
        KUBECONFIG = "${WORKSPACE}/.kube/config"
        CREDENTIALS_XRAY_SELI_ARTIFACTORY = credentials('XRAY_SELI_ARTIFACTORY')
        CREDENTIALS_SELI_ARTIFACTORY = credentials('SELI_ARTIFACTORY')
        CREDENTIALS_SERO_ARTIFACTORY = credentials('SERO_ARTIFACTORY')
        CREDENTIALS_GERRIT_EST_TECH = credentials('EST_GERRIT_TOKEN')
        CREDENTIALS_GERRIT_REVIEW = credentials('GERRIT_PASSWORD')
        CREDENTIALS_MUNIN_TOKEN = credentials('munin_token')
        CREDENTIALS_SCAS_TOKEN = credentials('SCAS_token')
        CREDENTIALS_GITCA = credentials('GERRIT_PASSWORD')
        CREDENTIALS_ACA = credentials('GERRIT_PASSWORD')
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
        PREVIOUS_VERSION = "6.3.0"
        ADP_BASE_VERSION = "6.13.0-10"
        // Just for release stages. Is the intended drop version of the helm chart and images to release.
        RELEASE_CANDIDATE = "3.3.0-12"
        RELEASE_DEPENDENCIES_FILE = "fossa/releases/3.3.0/dependencies-acmr-7-1-2.yaml"
        PREP_DEPENDENCIES_FILE = "fossa/releases/3.4.0/dependencies.yaml"
        // Just used for release. Is the intended commitid of the customization source to release.
        ACM_RELEASE_SOURCE_COMMITHASH = "746d47bf47f92559177b8903135af6cc1613c383"
        BASE_IMAGE_REG_PATH = "armdocker.rnd.ericsson.se/proj-est-policy"
        CREDENTIALS_FOSSA_API_KEY = credentials('FOSSA_API_token')
        CREDENTIALS_BAZAAR = credentials('BAZAAR_token')
        FOSSA_ENABLED = 'true'
        DEBUG = 'true'
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
        EiffelRequestBodyStart = '''{"msgParams":{"meta":{"id":"bf15498e-8cff-11ed-8edf-8b01ba368d14","type":"EiffelActivityTriggeredEvent","time":12345678,"tags":[],"source":{"domainId":"est","host":"fem1s11-eiffel216.eiffel.gic.ericsson.se:","name":"central.jenkins","uri":"https://central.jenkins.est.tech/"}}},"eventParams":{"data":{"name":"AegisUpdatePatchset","customData":[{"key":"MESSAGE","value":"''' + "${BUILD_URL}" + '''"},{"key":"STATUS","value":"STARTING"},{"key":"PATCHSET","value":"''' + "${GERRIT_REFSPEC}" + '''"}]},"links":[]}}'''
        EiffelRequestBodySuccess = '''{"msgParams":{"meta":{"id":"bf15498e-8cff-11ed-8edf-8b01ba368d14","type":"EiffelActivityTriggeredEvent","time":12345678,"tags":[],"source":{"domainId":"est","host":"fem1s11-eiffel216.eiffel.gic.ericsson.se:","name":"central.jenkins","uri":"https://central.jenkins.est.tech/"}}},"eventParams":{"data":{"name":"AegisUpdatePatchset","customData":[{"key":"MESSAGE","value":"''' + "${BUILD_URL}" + '''"},{"key":"STATUS","value":"FINISHED_SUCCESS"},{"key":"PATCHSET","value":"''' + "${GERRIT_REFSPEC}" + '''"}]},"links":[]}}'''
        EiffelRequestBodyFailure = '''{"msgParams":{"meta":{"id":"bf15498e-8cff-11ed-8edf-8b01ba368d14","type":"EiffelActivityTriggeredEvent","time":12345678,"tags":[],"source":{"domainId":"est","host":"fem1s11-eiffel216.eiffel.gic.ericsson.se:","name":"central.jenkins","uri":"https://central.jenkins.est.tech/"}}},"eventParams":{"data":{"name":"AegisUpdatePatchset","customData":[{"key":"MESSAGE","value":"''' + "${BUILD_URL}" + '''"},{"key":"STATUS","value":"FINISHED_FAILED"},{"key":"PATCHSET","value":"''' + "${GERRIT_REFSPEC}" + '''"}]},"links":[]}}'''
        MAILRECEPTIANTS = "andrew.fenner@est.tech"
        POLICY_PARENT_ACA_ID = "57145352-5c17-4f0c-a948-98b7f2e1fe00"
        POLICY_COMMON_ACA_ID = "46487f7d-a60d-4728-954b-63ae0b4fc562"
        POLICY_MODELS_ACA_ID = "2f6e53da-838d-4044-9bba-da9956c9b715"
        POLICY_CLAMP_ACA_ID = "648d443f-4daf-4cce-bc4e-29f960de25df"
        READINESS_ACA_ID = "a3176018-21dd-4500-9eda-d49def583699" // v6.0.3
    }

    // Stage names (with descriptions) taken from ADP Microservice CI Pipeline Step Naming Guideline: https://confluence.lmera.ericsson.se/pages/viewpage.action?pageId=122564754
    stages {
        stage('Clone All Repos') {
            steps {
                script{
                  httpRequest url: "http://20.223.249.41/publish/generateAndPublish?msgType=EiffelActivityTriggeredEvent&mp=eiffelsemantics&tag=est", requestBody: EiffelRequestBodyStart , contentType: 'APPLICATION_JSON' , httpMode: 'POST', consoleLogResponseBody: true , acceptType: 'APPLICATION_JSON'
                }
                sh "mkdir -p policy-parent policy-common policy-models clamp uds-customizations readiness envsubst aca-release-downloads"

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
            when {
                expression { env.RELEASE == "false" }
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
            }
            steps {
                echo "User = ${USER}"
                customizeImage(file:'readiness',path:'policy-acm-customizations/helperContainers/readiness-customization/dockerfile-customization')
                customizeImage(file:'envsubst',path:'policy-acm-customizations/helperContainers/envsubst-customization/dockerfile-customization')
                sh "${bob} translator:translate-dockerfile-publish"
                sh "${bob} translator_db_migrator"
            }
        }

        stage('Clean') {
            steps {
                echo 'Inject settings.xml into workspace:'
                configFileProvider([configFile(fileId: "${env.SETTINGS_CONFIG_FILE_NAME}", targetLocation: "${env.WORKSPACE}")]) {}
                archiveArtifacts allowEmptyArchive: true, artifacts: 'ruleset2.0.yaml, policy_acm_runtime__publishpipeline.Jenkinsfile'
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh "${bob} clean"
                }
            }
        }

        stage('Init') {
            when {
                expression { env.RELEASE == "false" }
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
            }
            steps {
                sh "${bob} init-drop"
                initPostSteps()
            }
        }

        stage('Lint') {
            when {
                expression { env.RELEASE == "false" }
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
            }
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
            when {
                expression { env.RELEASE == "false" }
                // expression { env.RELEASE == "never" } // uncomment to "skip"
            }
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
            when {
                expression { env.RELEASE == "false" }
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
            }
            steps {
                script {
                    sh "mkdir -p build/va-reports/VA-reports"
                    for (image in ACM_IMAGES) {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            withEnv(["ACM_IMAGE=${image}", "VERSION_TAG=${POLICY_TAG}"]) {
                            sh "${bob} generate-VA-report-V2:upload"
                            }
                        }
                    }
                }
                archiveArtifacts allowEmptyArchive: true, artifacts: 'build/va-reports/VA-reports/**/*.*'
            }
        }

        stage('Build') {
            when {
                expression { env.RELEASE == "false" }
//                 expression { env.RELEASE == "never" } // uncomment to "skip"

            }
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
            when {
                 expression { env.RELEASE == "false" }
//                  expression { env.RELEASE == "never" } // uncomment to "skip"

            }
            environment {
              POLICY_TAG = sh(script: "echo \${POLICY_TAG}" , returnStdout: true).trim()
            }
            steps {
                withEnv(["VERSION_TAG=${POLICY_TAG}"]) {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh "${bob} Build-csit-robot-test-image"
                    }
                }
            }
        }

        stage('Parallel Streams'){
            parallel{

                stage('Generate') {
                    when {
                        expression { env.RELEASE == "false" }
//                      expression { env.RELEASE == "never" } // uncomment to "skip"
                    }
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
                            when {
                                expression { env.RELEASE == "false" }
//                              expression { env.RELEASE == "never" } // uncomment to "skip"
                            }
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
                                expression { env.RELEASE == "false" && env.SQ_ENABLED == "true" }
//                              expression { env.RELEASE == "never" } // uncomment to "skip"
                            }
                            steps {
                                withSonarQubeEnv("${env.SQ_SERVER}") {
                                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    sh "${bob} sonar-enterprise-release"
                                    }
                                }
                            }
                        }
                        stage('SonarQube Quality Gate') {
                            when {
                                expression { env.RELEASE == "false" && env.SQ_ENABLED == "true" }
//                              expression { env.RELEASE == "never" } // uncomment to "skip"
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
                            when {
                                expression { env.RELEASE == "false" }
//                              expression { env.RELEASE == "never" } // uncomment to "skip"
                            }
                            steps {
                                script {
                                    withEnv(["VERSION_TAG=${POLICY_TAG}"]) {
                                    script {
                                        ci_pipeline_scripts.retryMechanism("${bob} image", 3)
                                    }
                                    for (image in ACM_IMAGES) {
                                        withEnv(["ACM_IMAGE=${image}", "VERSION_TAG=${POLICY_TAG}"]) {
                                        echo "image:${ACM_IMAGE} "
                                        sh "${bob} image-dr-check"
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
                            when {
                                expression { env.RELEASE == "false" }
//                              expression { env.RELEASE == "never" } // uncomment to "skip"
                            }
                            steps {
                                script {
                                    for (image in ACM_IMAGES) {
                                        withEnv(["ACM_IMAGE=${image}","VERSION_TAG=${POLICY_TAG}"]) {
                                        echo "pushing image:${ACM_IMAGE} "
                                        sh "${bob} package-image"
                                        }
                                    }
                                    withEnv(["VERSION_TAG=${POLICY_TAG}"]) {
                                    sh "${bob} package"
                                    sh "${bob} check-if-exists"
                                    sh "${bob} package-jars"
                                    }
                                }
                            }
                            post {
                                cleanup {
                                    script {
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

                stage('FOSSA'){
                    when {
                        expression { env.RELEASE == "false" && env.FOSSA_ENABLED == "true" }
//                      expression { env.RELEASE == "never" } // uncomment to "skip"
                    }
                    steps {
                        sh "${bob} fossa-analyze && ${bob} fossa-scan-status-check && ${bob} fetch-fossa-report-attribution"
                        archiveArtifacts '*fossa-report*.json'
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            // Convert fossa json reports to yaml
                            sh "${bob} dependency-update"
                            // Merge Policy-Common, Models and Clamp fossa reports together
                            sh "${bob} dependency-merge"
                            modifyFOSSReport()

                            withCredentials([string(credentialsId: 'SCAS_token', variable: 'SCAS_TOKEN')]) {
                                sh "${bob} scan-scas"
                            }
                            archiveArtifacts 'dependencies.yaml'
                        }
                        sh "mkdir -p diff-reports"
                        sh "${bob} create-foss-report-diff"
                        archiveArtifacts 'diff-reports/**'
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            sh "${bob} dependency-validate"
                        }
                    }
                }

            }
        }

        stage('K8S Resource Lock') {
            when {
                expression { env.RELEASE == "false" }
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
            }
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

        stage('Publish') {
            when {
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
                expression { env.RELEASE == "false" }
            }
            steps {
                script {
                    withEnv(["VERSION_TAG=${POLICY_TAG}","HELM_CHART_NAME=${ACM_HELM_CHART}"]) {
                           sh "${bob} publish:package-helm-public"
                           sh "${bob} publish:publish-helm"
                    }
                    for (image in ACM_IMAGES) {
                       withEnv(["ACM_IMAGE=${image}", "VERSION_TAG=${POLICY_TAG}"]) {
                           sh "${bob} publish-image"
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

        stage('Upload Marketplace Documentation') {
            when {
                expression { env.RELEASE == "false" }
//                expression { env.RELEASE == "never" } // uncomment to "skip"
            }
            steps {
                withCredentials([string(credentialsId: 'SZOP_ADP_PORTAL_API_KEY',variable: 'SZOP_ADP_PORTAL_API_KEY')]) {
                    sh "${bob} marketplace-upload-release"
                }
            }
        }

        stage ('Release Phase 1') {
            when {
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
                expression { env.RELEASE == "true" }
            }
            steps {
                withCredentials([string(credentialsId: 'munin_token', variable: 'MUNIN_TOKEN')]) {
                    // Mimer
                    sh "${bob} init-release"
                    archiveArtifacts 'artifact.properties'
                    sh "${bob} mimer-search-foss"
                    sh "${bob} munin-update-version"
                    // Trade Compliance, Encryptions and FOSS approval in Mimer before phase 2
                }
            }
        }

        stage ('Release Phase 2') {
            when {
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
                expression { env.RELEASE == "true" && env.RELEASE_PHASE_2 == "true" }
            }
            steps {
                withCredentials([string(credentialsId: 'munin_token', variable: 'MUNIN_TOKEN')]) {
                    //GitCA
                    sh "${bob} munin-connect-ca-artifact"
                    //ACA
                    sh "${bob} fetch-drop-helm-chart"
                    sh "${bob} upload-and-register-artifacts-in-aca"
                    sh "${bob} download-artifact-from-aca" // Uncomment to test downloading release artifact (helm-chart) from ACA
                    archiveArtifacts "aca-release-downloads/**"
                    //Release
                    sh "${bob} munin-release-version"
                    sh "${bob} unpack-helmchart"
                    sh "${bob} publish-released-helmchart-to-drop-repo"
                }
            }
        }

        stage ('Release Publish') {
            when {
//                 expression { env.RELEASE == "never" } // uncomment to "skip"
                expression { env.RELEASE == "true"}
            }
            steps {
                script{
                    if (GERRIT_REFSPEC == "refs/heads/master" && env.RELEASE_PUBLISH == "true") {
                        sh "echo 'Publishing Release. Triggering App Staging!'"
                        sh "exit 0"
                    }
                    else {
                        sh "echo 'Release not yet published. Must be executed from master and RELEASE_PUBLISH enabled. App Staging not triggered'"
                        sh "exit 1"
                    }
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
        failure{
            script{
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

def kubesec(bob){
    script {
        if (env.KUBESEC_ENABLED == "true") {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                sh "${bob} kubesec-scan"
                archiveArtifacts 'build/va-reports/kubesec-reports/*'
            }
        }
    }
}

def kubeaudit(bob){
    script {
        if (env.KUBEAUDIT_ENABLED == "true") {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            sh "${bob} kube-audit"
            archiveArtifacts "build/va-reports/kube-audit-report/**/*"
            }
        }
    }
}

def hadolint(bob,DOCKERFILE_PATHS_HADOLINT_VAR){
    script {
        if (env.HADOLINT_ENABLED == "true") {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            for (int i = 0; i < DOCKERFILE_PATHS_HADOLINT_VAR.size(); i++) {
                DOCKERFILE_PATH="${DOCKERFILE_PATHS_HADOLINT_VAR[i]}"
                withEnv(["DOCKERFILE_PATH=${DOCKERFILE_PATH}"]) {
                    sh "${bob} hadolint-scan"
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    echo "Evaluating Hadolint Scan Resultcodes..."
                    PATHNAME =  sh(script: "echo ${DOCKERFILE_PATHS_HADOLINT_VAR[i]} | sed 's#/#_#g'" , returnStdout: true).trim()
                    sh "cp build/va-reports/hadolint-scan/hadolint_Dockerfile_report.json  build/va-reports/hadolint-scan/hadolint_Dockerfile_report-${PATHNAME}.json"
                    sh "${bob} evaluate-design-rule-check-resultcodes"
                    }
                    }
                }
            archiveArtifacts "build/va-reports/hadolint-scan/**.*"
            }
        }
    }
}

def cloneReadiness(){
    //Cloning OOM readiness
    withCredentials([usernamePassword(credentialsId: 'GERRIT_PASSWORD', usernameVariable: 'GERRIT_REVIEW_PASS_USER', passwordVariable: 'GERRIT_REVIEW_PASS_PASS')]) {
        sh 'wget -O file https://lib.sw.ericsson.net/lib/artifacts/${READINESS_ACA_ID}/file --user ${GERRIT_REVIEW_PASS_USER} --password ${GERRIT_REVIEW_PASS_PASS}'
        sh 'tar -xvf file --strip-components 1 -C readiness > readiness.log'
        }
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

def cloneACMCustomizations(){
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

def cloneUDSRepo(){
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

def cloneClampRepo(){
    //Cloning policy clamp repo
    withCredentials([usernamePassword(credentialsId: 'GERRIT_PASSWORD', usernameVariable: 'GERRIT_REVIEW_PASS_USER', passwordVariable: 'GERRIT_REVIEW_PASS_PASS')]) {
        sh 'wget -O file https://lib.sw.ericsson.net/lib/artifacts/${POLICY_CLAMP_ACA_ID}/file --user ${GERRIT_REVIEW_PASS_USER} --password ${GERRIT_REVIEW_PASS_PASS}'
        sh 'tar -xvf file --strip-components 1 -C clamp > policyclamp.log'
    }
}

def cloneModelsRepo(){
    //Cloning policy models repo
    withCredentials([usernamePassword(credentialsId: 'GERRIT_PASSWORD', usernameVariable: 'GERRIT_REVIEW_PASS_USER', passwordVariable: 'GERRIT_REVIEW_PASS_PASS')]) {
        sh 'wget -O file https://lib.sw.ericsson.net/lib/artifacts/${POLICY_MODELS_ACA_ID}/file --user ${GERRIT_REVIEW_PASS_USER} --password ${GERRIT_REVIEW_PASS_PASS}'
        sh 'tar -xvf file --strip-components 1 -C policy-models > policymodels.log'
    }
}

def cloneCommonRepo(){
    //Cloning policy common repo
    withCredentials([usernamePassword(credentialsId: 'GERRIT_PASSWORD', usernameVariable: 'GERRIT_REVIEW_PASS_USER', passwordVariable: 'GERRIT_REVIEW_PASS_PASS')]) {
        sh 'wget -O file https://lib.sw.ericsson.net/lib/artifacts/${POLICY_COMMON_ACA_ID}/file --user ${GERRIT_REVIEW_PASS_USER} --password ${GERRIT_REVIEW_PASS_PASS}'
        sh 'tar -xvf file --strip-components 1 -C policy-common > policycommon.log'
    }
}

def cloneParentRepo(){
    //Cloning policy parent repo
    withCredentials([usernamePassword(credentialsId: 'GERRIT_PASSWORD', usernameVariable: 'GERRIT_REVIEW_PASS_USER', passwordVariable: 'GERRIT_REVIEW_PASS_PASS')]) {
        sh 'wget -O file https://lib.sw.ericsson.net/lib/artifacts/${POLICY_PARENT_ACA_ID}/file --user ${GERRIT_REVIEW_PASS_USER} --password ${GERRIT_REVIEW_PASS_PASS}'
        sh 'tar -xvf file --strip-components 1 -C policy-parent > policyparent.log'
    }
}

def initPostSteps(){
    archiveArtifacts 'artifact.properties'
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
        cp -R ./uds-customizations//settings-odysseus.xml .
        cp ./uds-customizations/settings-odysseus.xml ~/.m2/settings.xml
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
        cp ./policy-acm-customizations/fossa .

        echo "  - helm-chart-test: eric-oss-policy-acm-test" >> common-properties.yaml
        echo "  - helm-chart-name: eric-oss-acm-runtime" >> common-properties.yaml
        echo "  - helm-chart-name-crd: eric-oss-acm-runtime-crd" >> common-properties.yaml
    '''
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

    def CHART_DOWNLOAD_LINK = "https://arm.seli.gic.ericsson.se/artifactory/proj-est-onap-drop-helm-local/${CHART_NAME}/${CHART_NAME}-${VERSION}.tgz"
    def DOCKER_IMAGE_DOWNLOAD_LINK = "https://armdocker.rnd.ericsson.se/artifactory/docker-v2-global-local/proj-est-poc/onap/${CHART_NAME}/${VERSION}/"
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
