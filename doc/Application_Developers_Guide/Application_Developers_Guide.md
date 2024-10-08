# [ACM User Guide](#acm-user-guide)

## Contents
* [ACM User Guide](#acm-user-guide)
  * [Contents](#contents)
* [Defining a composition](#defining-a-composition)
* [HowTo: My First Automation Composition](#howto--my-first-automation-composition)
  * [Data Types](#data-types)
    * [onap.datatypes.ToscaConceptIdentifier:](#onapdatatypestoscaconceptidentifier)
    * [onap.datatypes.clamp.acm.httpAutomationCompositionElement.RestRequest:](#onapdatatypesclampacmhttpautomationcompositionelementrestrequest)
    * [onap.datatypes.clamp.acm.httpAutomationCompositionElement.ConfigurationEntity:](#onapdatatypesclampacmhttpautomationcompositionelementconfigurationentity)
  * [Node Types](#node-types)
    * [org.onap.policy.clamp.acm.Participant:](#orgonappolicyclampacmparticipant)
    * [org.onap.policy.clamp.acm.AutomationCompositionElement:](#orgonappolicyclampacmautomationcompositionelement)
    * [org.onap.policy.clamp.acm.K8SMicroserviceAutomationCompositionElement:](#orgonappolicyclampacmk8smicroserviceautomationcompositionelement)
    * [org.onap.policy.clamp.acm.HttpAutomationCompositionElement:](#orgonappolicyclampacmhttpautomationcompositionelement)
    * [org.onap.policy.clamp.acm.AutomationComposition:](#orgonappolicyclampacmautomationcomposition)
  * [Node Templates](#node-templates)
    * [org.onap.k8s.acm.K8SAutomationCompositionParticipant:](#orgonapk8sacmk8sautomationcompositionparticipant)
    * [onap.policy.clamp.ac.element.K8S\_AutomationCompositionElement:](#onappolicyclampacelementk8s_automationcompositionelement)
    * [org.onap.policy.clamp.acm.HttpParticipant:](#orgonappolicyclampacmhttpparticipant)
    * [onap.policy.clamp.ac.element.Http\_AutomationCompositionElement:](#onappolicyclampacelementhttp_automationcompositionelement)
    * [onap.policy.clamp.ac.element.AutomationCompositionDefinition:](#onappolicyclampacelementautomationcompositiondefinition)
  * [ACM workflow](#acm-workflow)
    * [Prerequisites:](#prerequisites)
    * [Commissioning the AC definition](#commissioning-the-ac-definition)
    * [Prime AC definitions](#prime-ac-definitions)
    * [Instantiate AutomationComposition](#instantiate-automationcomposition)
    * [Update AC Instance Properties](#update-ac-instance-properties)
    * [Deploy AC instance](#deploy-ac-instance)
    * [Update AC Instance Properties After Deployment](#update-ac-instance-properties-after-deployment)
    * [Migrate AC Instance](#migrate-ac-instance)
    * [UnDeploy AutomationComposition](#undeploy-automationcomposition)
    * [Uninstantiate AC instance](#uninstantiate-ac-instance)
    * [Deprime Ac defintions](#deprime-ac-defintions)
    * [Delete AC defintion](#delete-ac-defintion)
  * [Participant Simulator](#participant-simulator)
    * [Mock a participant using docker-compose](#mock-a-participant-using-docker-compose)
    * [Set delay and success/fail](#set-delay-and-successfail)
    * [Update and send composition outProperites](#update-and-send-composition-outproperites)
    * [Read all AC Definition elements information](#read-all-ac-definition-elements-information)
    * [Log of all information for each operation](#log-of-all-information-for-each-operation)
    * [Set Specific AcElementListenerV Version](#set-specific-acelementlistenerv-version)
<!-- TOC -->

This guide helps the user to define their own composition definitions and explains the procedure to execute them via the Clamp Automation Composition Management Framework. This guide briefly talks about the commissioning, instantiation and deployment steps once the composition definitions are created.

# [Defining a composition](#defining-a-composition)


A composition can be created in yaml/json format as per the TOSCA standard. Please refer to the below section to understand the Tosca fundamental concepts and how an Automation Composition definition can be realised in the TOSCA.

*   [Defining Automation Compositions in TOSCA for CLAMP](https://adp.ericsson.se/marketplace/automation-composition-mgmt-runtime/documentation/development/additional-documents/defining-automation-compositions#defining-automation-compositions)
    *   [1 Standard TOSCA Service Template Concepts for Automation Compositions](https://adp.ericsson.se/marketplace/automation-composition-mgmt-runtime/documentation/development/additional-documents/defining-automation-compositions#1-standard-tosca-service-template-concepts-for-automation-compositions)
    *   [2 Common and Instance Specific Properties](https://adp.ericsson.se/marketplace/automation-composition-mgmt-runtime/documentation/development/additional-documents/defining-automation-compositions#2-common-and-instance-specific-properties)
    *   [3 Writing a Automation Composition Type Definition](https://adp.ericsson.se/marketplace/automation-composition-mgmt-runtime/documentation/development/additional-documents/defining-automation-compositions#3-writing-a-automation-composition-type-definition)
    *   [4 Creating Custom Automation Composition Elements](https://adp.ericsson.se/marketplace/automation-composition-mgmt-runtime/documentation/development/additional-documents/defining-automation-compositions#4-creating-custom-automation-composition-elements)

# [HowTo: My First Automation Composition](#howto-my-first-automation-composition)
An example scenario is considered where we have a microservice that can be installed with a helm chart in kubernetes and configured via REST api to perform some operation.This functionality can be realised as a composition in Tosca standard. The various sections of the composition definition includes:

## [Data Types](#data-types)

The user can define their own data types to be used in the composition definition. In this use case, we are defining three data types as follows.

### onap.datatypes.ToscaConceptIdentifier:

This is a composite data type that holds two key value pairs in it. This type is used as an identifier for automation element types and participant types.This holds two string properties “name” and “version” and hence this data type can be used for creating the other composition element ids.

### onap.datatypes.clamp.acm.httpAutomationCompositionElement.RestRequest:

The rest api request for configuring the microservice can use the RestRequest datatype for defining the request in TOSCA. This holds the string properties “httpMethod”, “path”, “body” and an integer property “expectedResponse” for defining the rest request.

---
**Note**

That the “restRequestId” property which is of type “onap.datatypes.ToscaConceptIdentifier” that was defined in the previous step.

---

### onap.datatypes.clamp.acm.httpAutomationCompositionElement.ConfigurationEntity:

This data type holds a list of rest requests in case a microservice requires more than one rest request for configuration. This holds the “configurationEntityId” which is of type “onap.datatypes.ToscaConceptIdentifier” and “restSequence” property to hold the list of “onap.datatypes.clamp.acm.httpAutomationCompositionElement.RestRequest”

```yaml
data_types:
  onap.datatypes.ToscaConceptIdentifier:
    derived_from: tosca.datatypes.Root
    properties:
      name:
        type: string
        required: true
      version:
        type: string
        required: true

  onap.datatypes.clamp.acm.httpAutomationCompositionElement.RestRequest:
    version: 1.0.0
    derived_from: tosca.datatypes.Root
    properties:
      restRequestId:
        type: onap.datatypes.ToscaConceptIdentifier
        required: true
        description: The name and version of a REST request to be sent to a REST endpoint
      httpMethod:
        type: string
        required: true
        constraints:
          - valid_values:
              - POST
              - PUT
              - GET
              - DELETE
        description: The REST method to use
      path:
        type: string
        required: true
        description: The path of the REST request relative to the base URL
      body:
        type: string
        required: false
        description: The body of the REST request for PUT and POST requests
      expectedResponse:
        type: integer
        required: true
        constraints: []
        description: THe expected HTTP status code for the REST request
  onap.datatypes.clamp.acm.httpAutomationCompositionElement.ConfigurationEntity:
    version: 1.0.0
    derived_from: tosca.datatypes.Root
    properties:
      configurationEntityId:
        type: onap.datatypes.ToscaConceptIdentifier
        required: true
        description:
          The name and version of a Configuration Entity to be handled
          by the HTTP Automation Composition Element
      restSequence:
        type: list
        entry_schema:
          type: onap.datatypes.clamp.acm.httpAutomationCompositionElement.RestRequest
          type_version: 1.0.0
        description: A sequence of REST commands to send to the REST endpoint
```

## [Node Types](#node-types)

A Node Type is a reusable entity that defines the type of one or more Node Templates. An Interface Type is a reusable entity that describes a set of operations that can be used to interact with or manage a node or relationship in a TOSCA topology. The actual acm elements will be created under the Node templates deriving from these node types. We are going to define the following element types for ACM:

### org.onap.policy.clamp.acm.Participant:

This is a participant element type to define various participants in ACM. It holds the string property “provider”.

### org.onap.policy.clamp.acm.AutomationCompositionElement:

This node type defines the primitive Automation composition element type that includes various common properties for all the ACM elements. Here we are defining various timeout properties and startPhase parameter that are common for all the AC elements.

---
**Note**

This node type value should not be changed as the ACM framework identifies the AC elements based on this type.**

---

### org.onap.policy.clamp.acm.K8SMicroserviceAutomationCompositionElement:

This node type is used to define AC elements that are associated with kubernetes operations. It is further derived from the “org.onap.policy.clamp.acm.AutomationCompositionElement” type and hence supports its common properties and also includes additional properties related to helm charts. We are going to create kubernetes AC elements of this type, under the Node templates.

### org.onap.policy.clamp.acm.HttpAutomationCompositionElement:

Node type for AC elements associated with REST operations. It is derived from the “org.onap.policy.clamp.acm.AutomationCompositionElement” type and hence supports its common properties and also supports additional properties for REST operation. We are going to create a REST AC element of this type, under the Node templates.

### org.onap.policy.clamp.acm.AutomationComposition:

Primitive node type for defining Automation composition definitions that comprises one or more AC elements in it. The AC definition of this type will be created under the Node templates.

---
**Note**

This node type value should not be changed as the ACM framework identifies the AC definitions based on this type.

---

```yaml
node_types:
  org.onap.policy.clamp.acm.Participant:
    version: 1.0.1
    derived_from: tosca.nodetypes.Root
    properties:
      provider:
        type: string
        required: false
  org.onap.policy.clamp.acm.AutomationCompositionElement:
    version: 1.0.1
    derived_from: tosca.nodetypes.Root
    properties:
      provider:
        type: string
        required: false
        metadata:
          common: true
        description: Specifies the organization that provides the automation composition element
      startPhase:
        type: integer
        required: false
        constraints:
          - greater_or_equal: 0
        metadata:
          common: true
        description:
          A value indicating the start phase in which this automation composition element will be started, the
          first start phase is zero. Automation Composition Elements are started in their start_phase order and stopped
          in reverse start phase order. Automation Composition Elements with the same start phase are started and
          stopped simultaneously
      uninitializedToPassiveTimeout:
        type: integer
        required: false
        constraints:
          - greater_or_equal: 0
        default: 60
        metadata:
          common: true
        description: The maximum time in seconds to wait for a state chage from uninitialized to passive
      passiveToRunningTimeout:
        type: integer
        required: false
        constraints:
          - greater_or_equal: 0
        default: 60
        metadata:
          common: true
        description: The maximum time in seconds to wait for a state chage from passive to running
      runningToPassiveTimeout:
        type: integer
        required: false
        constraints:
          - greater_or_equal: 0
        default: 60
        metadata:
          common: true
        description: The maximum time in seconds to wait for a state chage from running to passive
      passiveToUninitializedTimeout:
        type: integer
        required: false
        constraints:
          - greater_or_equal: 0
        default: 60
        metadata:
          common: true
        description: The maximum time in seconds to wait for a state chage from passive to uninitialized
  org.onap.policy.clamp.acm.AutomationComposition:
    version: 1.0.1
    derived_from: tosca.nodetypes.Root
    properties:
      provider:
        type: string
        required: false
        metadata:
          common: true
        description: Specifies the organization that provides the automation composition element
      elements:
        type: list
        required: true
        metadata:
          common: true
        entry_schema:
          type: onap.datatypes.ToscaConceptIdentifier
        description: Specifies a list of automation composition element definitions that make up this automation composition definition
  org.onap.policy.clamp.acm.K8SMicroserviceAutomationCompositionElement:
    version: 1.0.0
    derived_from: org.onap.policy.clamp.acm.AutomationCompositionElement
    properties:
      chart:
        type: dictionary
        required: true
        description: This consumes the helm chart information in key value pairs.
  org.onap.policy.clamp.acm.HttpAutomationCompositionElement:
    version: 1.0.0
    derived_from: org.onap.policy.clamp.acm.AutomationCompositionElement
    properties:
      baseUrl:
        type: string
        required: true
        description: The base URL to be prepended to each path, identifies the host for the REST endpoints.
      httpHeaders:
        type: map
        required: false
        entry_schema:
          type: string
        description: HTTP headers to send on REST requests
      configurationEntities:
        type: map
        required: true
        entry_schema:
          type: org.onap.datatypes.policy.clamp.acm.httpAutomationCompositionElement.ConfigurationEntity
          type_version: 1.0.0
        description: The connfiguration entities the Automation Composition Element is managing and their associated REST requests
```

## [Node Templates](#node-templates)

A Node Template specifies the occurrence of a manageable software component as part of an application’s topology model which is defined in a TOSCA Service Template. We create the actual participants and AC elements involved in this use case under the node templates. There are no element properties supplied at this point since it will be provided by the user during the instantiation.

### org.onap.k8s.acm.K8SAutomationCompositionParticipant:

A kubernetes participant element that processes the kubernetes AC elements in the composition. This element is of node type “org.onap.policy.clamp.acm.Participant”

### onap.policy.clamp.ac.element.K8S\_AutomationCompositionElement:

An AC element for kubernetes helm chart installation of the microservice derived from the node type “org.onap.policy.clamp.acm.K8SMicroserviceAutomationCompositionElement”. The common element properties are provided with values as part of commissioning the definition.

### org.onap.policy.clamp.acm.HttpParticipant:

A http participant element that processes the REST AC elements in the composition. This element is of type “org.onap.policy.clamp.acm.Participant”

### onap.policy.clamp.ac.element.Http\_AutomationCompositionElement:

An AC element for REST operation in the microservice derived from the node type “org.onap.policy.clamp.acm.HttpAutomationCompositionElement”. The common element properties startPhase and timeout are provided with values as part of commissioning the definition.

### onap.policy.clamp.ac.element.AutomationCompositionDefinition:

The actual Automation Composition definition that comprises the list of AC elements mapped to it. This element is of node type “org.onap.policy.clamp.acm.AutomationComposition”

```yaml
topology_template:
  node_templates:
    org.onap.k8s.acm.K8SAutomationCompositionParticipant:
      version: 2.3.4
      type: org.onap.policy.clamp.acm.Participant
      type_version: 1.0.1
      description: Participant for K8S
      properties:
        provider: ONAP
    onap.policy.clamp.ac.element.K8S_AutomationCompositionElement:
      # Helm chart parameters for the microservice
      version: 1.2.3
      type: org.onap.policy.clamp.acm.K8SMicroserviceAutomationCompositionElement
      type_version: 1.0.0
      description: Automation composition element for the K8S microservice for AC Element Starter
      properties:
        provider: ONAP
        startPhase: 0
        uninitializedToPassiveTimeout: 300
        podStatusCheckInterval: 30
    org.onap.policy.clamp.acm.HttpParticipant:
      version: 2.3.4
      type: org.onap.policy.clamp.acm.Participant
      type_version: 1.0.1
      description: Participant for Http requests
      properties:
        provider: ONAP
    onap.policy.clamp.ac.element.Http_AutomationCompositionElement:
      # Http config for AC Element microservice.
      version: 1.2.3
      type: org.onap.policy.clamp.acm.HttpAutomationCompositionElement
      type_version: 1.0.0
      description: Automation composition element for the http requests of AC Element Starter microservice
      properties:
        provider: ONAP
        uninitializedToPassiveTimeout: 300
        startPhase: 1

    onap.policy.clamp.ac.element.AutomationCompositionDefinition:
      version: 1.2.3
      type: org.onap.policy.clamp.acm.AutomationComposition
      type_version: 1.0.1
      description: Automation composition for Demo
      properties:
        provider: ONAP
        elements:
          - name: onap.policy.clamp.ac.element.K8S_AutomationCompositionElement
            version: 1.2.3
          - name: onap.policy.clamp.ac.element.Http_AutomationCompositionElement
            version: 1.2.3
```

Completed tosca template ([click here](acm-tosca.yaml))

Once the Tosca template definition is created, the ACM workflow can be executed to create and deploy the compositions. Please refer the following section for running ACM workflow.

## [ACM workflow](#acm-workflow)

ACM framework exposes REST interfaces for creating and deploying the user defined compositions. In this section, the TOSCA template created in the previous step can be commissioned, and then AC instances can be created and deployed for the same.

This section assumes that the user has read about the ACM APIs and Protocols documentation and understands the ACM operations on a high level before proceeding with the workflow.

### Prerequisites:

*   ACM components including acm-runtime, required participants (http and kubernetes in this case) and Dmaap/kafka clients are deployed in docker or kubernetes environment.

*   Kubernetes and Helm are installed.

*   Chartmuseum server is installed to host the acelement microservice helm chart. ([Procedure to install chartmuseum](https://wiki.onap.org/display/DW/Microk8s+and+helm+setup+in+Ubuntu).)

*   The helm chart for ACM test microservice is available in the policy/clamp repository that can be cloned locally and uploaded to the chartmuseum using helm push.([AC element helm chart](https://github.com/onap/policy-clamp/tree/master/examples/src/main/resources/clamp/acm/acelement-helm).)


Please refer the [ACM swagger document](https://raw.githubusercontent.com/onap/policy-clamp/master/runtime-acm/src/main/resources/openapi/openapi.yaml). for REST API information for all the ACM operations. This section guides through the various steps involved in executing the ACM workflow for deploying the test microservice element.

### [Commissioning the AC definition](#commissioning-the-ac-definition)

Commissioning refers to storing the composition definition on the ACM database. The created tosca template is posted as a request payload.

Invoke a POST request
```
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions'
```

This returns a 202 response on the successful creation of the composition definition.

---
**Note**

The rest response returns the compositionId on a successful creation that requires to be used in the subsequent requests.**

---

### [Prime AC definitions](#prime-ac-definitions)

Priming associates the AC elements with suitable participants and sends the corresponding AC element information to the participants.

Invoke a PUT request
```text
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}'
```

Request payload
```json
{
  "primeOrder": "PRIME"
}
```
This returns a 202 response on a successful priming.

### [Instantiate AutomationComposition](#instantiate-automationcomposition)

Instantiation refers to creating an AC instance on the database by initialising the element properties for each element in the composition. These values requires to be provided by the user as per their use case requirement. In this case, we are passing the helm chart information of the test microservice for the Ac element “onap.policy.clamp.ac.element.K8S\_AutomationCompositionElement” which will be processed and installed by the kubernetes participant on a deployment request.

Similarly, the REST request data that are to be executed on the microservice will be passed on for the http AC element “onap.policy.clamp.ac.element.Http\_AutomationCompositionElement” which will be executed by the http participant. Please refer to the properties of the elements in the json payload.

---
**Note:**

In this scenario, the kubernetes element requires to be invoked first to install the helm chart and then the http element needs to be invoked to configure the microservice. This is achieved by using the “startPhase” property on the AC element properties. The elements with the startPhase value defined are executed on a sequence starting from the least value to the higher value. Each element in the request payload is assigned with a uniques UUID which will be automatically generated by the GUI in the upcoming releases.

---

Invoke a POST request
```text
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}/instances'
```

The compositionId retrieved from the previous step should be updated in the request body. This returns a 201 response on a successful instantiation. This also returns the instanceId in the response that can be used in the subsequent requests.

Request payload

```json
{
  "name": "DemoInstance0",
  "version": "1.0.1",
  "compositionId": "COMPOSITIONIDPLACEHOLDER",
  "description": "Demo automation composition instance 0",
  "elements": {
    "709c62b3-8918-41b9-a747-d21eb79c6c21": {
      "id": "709c62b3-8918-41b9-a747-d21eb79c6c21",
      "definition": {
        "name": "onap.policy.clamp.ac.element.K8S_AutomationCompositionElement",
        "version": "1.2.3"
      },
      "description": "Starter Automation Composition Element for the Demo",
      "properties": {
        "chart": {
          "chartId": {
            "name": "acelement",
            "version": "0.1.0"
          },
          "namespace": "default",
          "releaseName": "acm-starter",
          "podName": "acm-starter",
          "repository": {
            "repoName": "policy-chartmuseum",
            "address": "http://policy-chartmuseum:8080"
          },
          "overrideParams": {
            "acelement.elementId.name": "onap.policy.clamp.ac.starter",
            "service.nodeport": 30800
          }
        }
      }
    }
    "709c62b3-8918-41b9-a747-d21eb79c6c24": {
      "id": "709c62b3-8918-41b9-a747-d21eb79c6c24",
      "definition": {
        "name": "onap.policy.clamp.ac.element.Http_AutomationCompositionElement",
        "version": "1.2.3"
      },
      "description": "Starter Automation Composition Element for the Demo",
      "properties": {
        "baseUrl": "http://acm-starter-ac-element-impl:8084",
        "httpHeaders": {
          "Content-Type": "application/json",
          "Authorization": "Basic YWNtVXNlcjp6YiFYenRHMzQ="
        },
        "configurationEntities": [
          {
            "configurationEntityId": {
              "name": "onap.policy.clamp.ac.starter",
              "version": "1.0.0"
            },
            "restSequence": [
              {
                "restRequestId": {
                  "name": "request1",
                  "version": "1.0.1"
                },
                "httpMethod": "POST",
                "path": "/onap/policy/clamp/acelement/v2/activate",
                "body": "{ \"receiverId\": { \"name\": \"onap.policy.clamp.ac.startertobridge\", \"version\": \"1.0.0\" }, \"timerMs\": 20000, \"elementType\": \"STARTER\", \"topicParameterGroup\": { \"server\": \"message-router:3904\", \"listenerTopic\": \"POLICY_UPDATE_MSG\", \"publisherTopic\": \"AC_ELEMENT_MSG\", \"fetchTimeout\": 15000, \"topicCommInfrastructure\": \"dmaap\" } }",
                "expectedResponse": 201
              }
            ]
          }
        ]
      }
    }

  }
}
```

### [Update AC Instance Properties](#update-ac-instance-properties)

Before the AC instance is deployed, the user is allowed to update the instance property values if needed. The runtime updates these new values in the database.

```text
Invoke a POST request
'http://policy_runtime_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}/instances'
```
Request Payload

Example payload to update the base url of the http request

```json
{
  "name": "DemoInstance0",
  "version": "1.0.1",
  "compositionId": "COMPOSITIONIDPLACEHOLDER",
  "instanceId": "INSTANCEIDPLACEHOLDER",
  "description": "Demo automation composition instance 0",
  "elements": {
    "709c62b3-8918-41b9-a747-d21eb79c6c21": {
      "id": "709c62b3-8918-41b9-a747-d21eb79c6c21",
      "properties": {
        "baseUrl": "http://acm-starter-ac-element-impl_updated:8084"
      }
    }
  }
}
```


### [Deploy AC instance](#deploy-ac-instance)

Once the AC instance is created, the user can deploy the instance which in turn activates the corresponding participants to execute the intended operations. In this case, the kubernetes participant will be installing the test microservice helm chart on the kubernetes cluster and the http participant will be executing the REST requests on the microservice endpoints.

Invoke a PUT request
```text
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}'
```

This returns a 202 response on a successful deploy order request. The elements will be in “DEPLOYING” state until the completion and then the state of the elements are updated to “DEPLOYED” The current status of the deployment can be fetched through the following endpoint.

Invoke a GET request
```text
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}'
```

Request payload
```json
{
  "deployOrder": "DEPLOY"
}
```

---
**Note:**

The user can further implement the admin states ‘LOCK’ and ‘UNLOCK’ on the participants to further cascade the deployment operations. If these states are implemented, then a subsequent request to LOCK and UNLOCK requires to be triggered following the deployment.

---

Once all the AC elements are deployed, there should be a test microservice pod running on the kubernetes cluster which is configured to send events on the kafka by the http participant. This can be verified on the test microservice application logs. The AC instances can also be undeployed and deleted by the user.

### [Update AC Instance Properties After Deployment](#update-ac-instance-properties-after-deployment)

After the AC instance is deployed, the user can still update the instance property values if needed. In this case, the runtime updates these new values in the database and also sends an update event to the participants. The participants has to implement the update method to perform the required operation.

```text
Invoke a POST request
'http://policy_runtime_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}/instances'
```

---
**Note**
Please refer the request payload section for updating the instance properties before deployment.

---

### [Migrate AC Instance](#migrate-ac-instance)

After the AC instance is deployed, the user can migrate it to other composition definition. The target composition have to be primed and have to contain the same element definitions present in the source composition. The user can update the instance property values if needed.

```text
Invoke a POST request
'http://policy_runtime_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}/instances'
```

Request Payload

Example payload to migrate and update the base url of the http request

```json
{
  "name": "DemoInstance0",
  "version": "1.0.1",
  "compositionId": "COMPOSITIONIDPLACEHOLDER",
  "instanceId": "INSTANCEIDPLACEHOLDER",
  "compositionTargetId": "COMPOSITIONIDTARGET",
  "description": "Demo automation composition instance 0",
  "elements": {
    "709c62b3-8918-41b9-a747-d21eb79c6c21": {
      "id": "709c62b3-8918-41b9-a747-d21eb79c6c21",
      "properties": {
        "baseUrl": "http://acm-starter-ac-element-impl_updated:8084"
      }
    }
  }
}

```

### [UnDeploy AutomationComposition](#undeploy-automationcomposition)

The AC instances can be undeployed from the system by the participants.

Invoke a PUT request
```text
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}'
```

This returns a 202 response on successful deploy order request.

Request payload

```json
{
  "deployOrder": "UNDEPLOY"
}
```

### [Uninstantiate AC instance](#uninstantiate-ac-instance)

This deletes the AC instance from the database including all the element properties that are initialised.

Invoke a DELETE request
```text
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}'
```

This returns 200 on successful deletion of the instance.

### [Deprime Ac defintions](#deprime-ac-defintions)

Once the AC instance is deleted, it can be deprimed from the participants to be safely deleted from the database.

Invoke a PUT request
```text
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}'

```
This returns a 202 response on a successful operation.

Request payload

```json
{
  "primeOrder": "DEPRIME"
}
```

### [Delete AC defintion](#delete-ac-defintion)

The AC definitions can be deleted if there are no instances are running and it is not primed to the participants.

Invoke a DELETE request 
``` text
'http://policy\_runtime\_ip:port/onap/policy/clamp/acm/v2/compositions/${compositionId}'
```

This return a 200 response on a successful deletion operation.

## [Participant Simulator](#participant-simulator)

Participant simulator do not execute any particular functionality, and can be used to mock one or more participants in debug tests. It should be used to test ACM-runtime and Participant Intermediary in specific scenario that could be difficult to replay in real environment.

Functionality covered:

1. Set participantId and supportedElementType by properties file or by parameter environment. 
2. Set a delay for each operation at runtime by Rest-Api. 
3. Set success or fail for each operation at runtime by Rest-Api. 
4. Update composition outProperties and send to ACM-runtime by Rest-Api. 
5. Read all AC Definition inProperties/outProperties information by Rest-Api. 
6. Update useState, operationalState and outProperties and send to ACM-runtime by Rest-Api. 
7. Read all AC instance elements information by Rest-Api. 
8. Log of all information for each operation. 
9. Set the ‘AcElementListenerV’ version by properties file.

### [Mock a participant using docker-compose](#mock-a-participant-using-docker-compose)

The follow example show a docker-compose configuration to mock http Participant, where ‘onap/policy-clamp-ac-sim-ppnt’ is the Participant simulator image:

```yaml
http-participant:
  image: onap/policy-clamp-ac-sim-ppnt
  environment:
    - participantId=101c62b3-8918-41b9-a747-d21eb79c6c01
    - supportedElementTypeName=org.onap.policy.clamp.acm.HttpAutomationCompositionElement
    - SERVER_SSL_ENABLED=false
    - useHttps=false
    - SERVER_PORT=8084
  ports:
    - "8084:8084"
```

### [Set delay and success/fail](#set-delay-success-fail)
Parameters like delay and success/fail could be set any time using the following endpoint:

```text
Invoke a PUT request 'http://participant_sim_ip:port/onap/policy/clamp/acm/simparticipant/v2/parameters'
```

The Json below is an example of configuration:

```json
{
  "deploySuccess": true,
  "undeploySuccess": true,
  "lockSuccess": true,
  "unlockSuccess": true,
  "deleteSuccess": true,
  "updateSuccess": true,
  "migrateSuccess": true,
  "primeSuccess": true,
  "deprimeSuccess": true,
  "deployTimerMs": 1000,
  "undeployTimerMs": 1000,
  "migrateTimerMs": 100,
  "lockTimerMs": 100,
  "unlockTimerMs": 100,
  "updateTimerMs": 100,
  "deleteTimerMs": 100,
  "primeTimerMs": 100,
  "deprimeTimerMs": 100
}
```

### [Update and send composition outProperites](#update-and-send-composition-outproperties)
Data like useState operationalState and outProperites could be updated any time using the following endpoint:

```text
Invoke a PUT request 'http://participant_sim_ip:port/onap/policy/clamp/acm/simparticipant/v2/compositiondatas'
```

The Json below is an example of update, where {{compositionId}} is the UUID of the AC Definition and (“onap.policy.clamp.ac.element.Http_BridgeAutomationCompositionElement”, “1.2.3”) is the ToscaConceptIdentifier of the AC Definition element:

```json
{
      "outProperties": {
          "list": [
              {"id": 10 },
              {"id": 20 }
          ]
      },
      "compositionId": "{{compositionId}}",
      "compositionDefinitionElementId": {
          "name": "onap.policy.clamp.ac.element.Http_BridgeAutomationCompositionElement",
          "version": "1.2.3"
      }
}
```

### [Read all AC Definition elements information](#read-all-ac-definition-elements-information)
All AC instance elements information like deployState, lockState, useState, operationalState, inProperties and outProperties could be read using the following endpoint:

```text
Invoke a GET request 'http://participant_sim_ip:port/onap/policy/clamp/acm/simparticipant/v2/instances'
```

### [Log of all information for each operation](#log-all-information-for-each-operation)
All information for each operation are logged, so the developer can monitoring what data are passed through the calls. Example of log during deploy.

26-02-2024 09:55:38.547 [pool-4-thread-4] DEBUG o.o.p.c.a.p.s.m.h.AutomationCompositionElementHandler.deploy - deploy call compositionElement: CompositionElementDto[ compositionId=6502ba5e-1939-42b0-8bd2-bf89f0d51be6, elementDefinitionId=onap.policy.clamp.ac.element.Http_StarterAutomationCompositionElement 1.2.3, inProperties={ … }, outProperties={} ], instanceElement: InstanceElementDto[ instanceId=022b3dee-a878-4b32-8544-de86e67e7335, elementId=2d614898-4945-41c7-9127-947b401aa753, toscaServiceTemplateFragment=ToscaServiceTemplate( … ), inProperties={ … }, outProperties={} ]

### [Set Specific AcElementListenerV Version](#set-specific-acelementlistenerv-version)
Set ‘element.handler’ property in properties file in order to test a specific AcElementListenerV version. Default value of ‘element.handler’ is the most recent version.

| Property Value     | Abstract Class      |
|--------------------|---------------------|
| AcElementHandlerV1 | AcElementListenerV1 |
| AcElementHandlerV2 | AcElementListenerV2 |

Example:

```yaml
element:
  handler: AcElementHandlerV1
```
