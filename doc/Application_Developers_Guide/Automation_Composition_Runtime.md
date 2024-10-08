

# [The CLAMP Automation Composition Runtime](#the-clamp-automation-composition-runtime)

## Contents

*   [The CLAMP Automation Composition Runtime](#the-clamp-automation-composition-runtime)

    *   [Terminology](#terminology)

    *   [Design of Rest Api](#design-of-rest-api)

        *   [Check CLAMP Runtime and Participants](#check-clamp-runtime-and-participants)

        *   [Order an immediate Participant Report from all participants](#order-an-immediate-participant-report-from-all-participants)

        *   [Create of a Automation Composition Definition Type](#create-of-a-automation-composition-definition-type)

        *   [Update of a Automation Composition Definition Type](#update-of-a-automation-composition-definition-type)

        *   [Priming of a Automation Composition Definition Type](#priming-of-a-automation-composition-definition-type)

        *   [Create of a Automation Composition Instance](#create-of-a-automation-composition-instance)

        *   [Update of a Automation Composition Instance](#update-of-a-automation-composition-instance)
        
        *   [Migrate of an Automation Composition Instance](#migrate-of-a-automation-composition-instance)

        *   [Issues AC instance to change status](#issues-ac-instance-to-change-status)

        *   [Delete of a Automation Composition Instance](#delete-of-a-automation-composition-instance)

        *   [Depriming of a Automation Composition Definition Type](#depriming-of-a-automation-composition-definition-type)

        *   [Delete of a Automation Composition Definition Type](#delete-of-a-automation-composition-definition-type)

    *   [StartPhase](#startphase)

        *   [How to define StartPhase](#how-to-define-startphase)

        *   [How StartPhase works](#how-startphase-works)

    *   [Design of managing messages](#design-of-managing-messages)

        *   [PARTICIPANT\_REGISTER](#participant-register)

        *   [PARTICIPANT\_PRIME\_ACK](#participant-prime-ack)

        *   [PARTICIPANT\_STATUS](#participant-status)

        *   [AUTOMATION\_COMPOSITION\_DEPLOY\_ACK](#automation-composition-deploy-ack)

        *   [AUTOMATION\_COMPOSITION\_STATECHANGE\_ACK](#automation-composition-statechange-ack)

    *   [Design of monitoring execution in SupervisionScanner](#design-of-monitoring-execution-in-supervisionscanner)

    *   [Design of Exception handling](#design-of-exception-handling)

        *   [GlobalControllerExceptionHandler](#globalcontrollerexceptionhandler)

        *   [RuntimeErrorController](#runtimeerrorcontroller)

    *   [Handle version and “X-ONAP-RequestID”](#handle-version-and-x-onap-requestid)

    *   [Media Type Support](#media-type-support)

        *   [application/json](#application-json)

        *   [application/yaml](#application-yaml)

        *   [text/plain](#text-plain)


This article explains how CLAMP Automation Composition Runtime is implemented.

## [Terminology](#terminology)


*   Broadcast message: a message for all participants (participantId=null)

*   Message to a participant: a message only for a participant (participantId properly filled)

*   ThreadPoolExecutor: ThreadPoolExecutor executes the given task, into SupervisionAspect class is configured to execute tasks in ordered manner, one by one

*   Spring Scheduling: into SupervisionAspect class, the @Scheduled annotation invokes “schedule()” method every “runtime.participantParameters.heartBeatMs” milliseconds with a fixed delay

*   MessageIntercept: “@MessageIntercept” annotation is used into SupervisionHandler class to intercept “handleParticipantMessage” method calls using spring aspect oriented programming

*   GUI: swagger-ui, Postman or policy-gui

*   Message Broker: supported message Broker are DMaap and Strimzi-Kafka


## [Design of Rest Api](#design-of-rest-api)


### [Check CLAMP Runtime and Participants](#check-clamp-runtime-and-participants)

*   GUI calls GET “/onap/policy/clamp/acm/health” endpoint and receives the “UP” status as response

*   GUI calls GET “/onap/policy/clamp/acm/v2/participants” endpoint and receives all participants registered with supported Element Types as response


### [Order an immediate Participant Report from all participants](#order-an-immediate-participant-report-from-all-participants)

*   GUI calls PUT “/onap/policy/clamp/acm/v2/participants” endpoint

*   runtime-ACM receives the call by Rest-Api (CommissioningController)

*   It triggers the execution to send a broadcast PARTICIPANT\_STATUS\_REQ message


### [Create of a Automation Composition Definition Type](#create-of-a-automation-composition-definition-type)

*   GUI calls POST “/onap/policy/clamp/acm/v2/compositions” endpoint with a Automation Composition Type Definition (Tosca Service Template) as body

*   runtime-ACM receives the call by Rest-Api (CommissioningController)

*   It validates the Automation Composition Type Definition

*   It saves to DB the Tosca Service Template using AcDefinitionProvider with new compositionId and COMMISSIONED status

*   the Rest-Api call returns the compositionId generated and the list of Element Definition Type


### [Update of a Automation Composition Definition Type](#update-of-a-automation-composition-definition-type)

*   GUI calls POST “/onap/policy/clamp/acm/v2/compositions” endpoint with a Automation Composition Type Definition (Tosca Service Template) as body. It have to contain the compositionId

*   runtime-ACM receives the call by Rest-Api (CommissioningController)

*   It checks that Automation Composition Type Definition is in COMMISSIONED status

*   It validates the Automation Composition Type Definition

*   It updates to DB the Tosca Service Template using AcDefinitionProvider using the compositionId

*   the Rest-Api call returns the compositionId and the list of Element Definition Type


### [Priming of a Automation Composition Definition Type](#priming-of-a-automation-composition-definition-type)

*   GUI calls POST “/onap/policy/clamp/acm/v2/compositions/{compositionId}” endpoint with PRIME as primeOrder

*   runtime-ACM receives the call by Rest-Api (CommissioningController)

*   It checks that Automation Composition Type Definition is in COMMISSIONED status

*   It validates and update the AC Element Type Definition with supported Element Types by participants

*   It updates AC Definition to DB with PRIMING as status

*   It triggers the execution to send a broadcast PARTICIPANT\_PRIME message

*   the message is built by ParticipantPrimePublisher using Tosca Service Template data


### [Create of a Automation Composition Instance](#create-of-a-automation-composition-instance)

*   GUI calls POST “/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances” endpoint with a Automation Composition Instance as body. It have to contain the compositionId

*   runtime-ACM receives the call by Rest-Api (InstantiationController)

*   It validates the AC Instance and checks that the related composition has COMMISSIONED as status

*   It set the related participantId into the AC Element Instance using the participantId defined in AC Element Type Definition

*   It saves the Automation Composition to DB with UNDEPLOYED deployState and NONE lockState

*   the Rest-Api call returns the instanceId and the list of AC Element Instance


### [Update of a Automation Composition Instance](#update-of-a-automation-composition-instance)

*   GUI calls POST “/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances” endpoint with a Automation Composition Instance as body. It have to contain the compositionId and the instanceId

*   runtime-ACM receives the call by Rest-Api (InstantiationController)

*   It checks that AC Instance is in UNDEPLOYED deployState

*   It updates the Automation Composition to DB

*   the Rest-Api call returns the instanceId and the list of AC Element Instance

### [Migrate of an Automation Composition Instance](#migrate-of-an-automation-composition-instance)

- GUI has already a new composition definition primed 
- GUI calls POST “/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances” endpoint with a Automation Composition Instance as body. It have to contain the compositionId, the compositionTargetId and the instanceId 
- Runtime-ACM receives the call by Rest-Api (InstantiationController)
- It checks that AC Instance is in DEPLOYED deployState 
- It checks that compositionTargetId is related to a primed composition definition 
- It updates the Automation Composition to DB 
- The Rest-Api call returns the instanceId and the list of AC Element Instance 
- The runtime sends a migrate event to the participants which performs the migrate operation on the deployed instances.

### [Issues AC instance to change status](#issues-ac-instance-to-change-status)

case **deployOrder: DEPLOY**

*   GUI calls “/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}” endpoint with DEPLOY as deployOrder

*   runtime-ACM receives the call by Rest-Api (InstantiationController)

*   It validates the status order issued (related AC Instance has UNDEPLOYED as deployState)

*   It updates the AC Instance to DB with DEPLOYING deployState

*   It triggers the execution to send a broadcast AUTOMATION\_COMPOSITION\_DEPLOY message

*   the message is built by AutomationCompositionDeployPublisher using Tosca Service Template data and Instance data. (with startPhase = first startPhase)


case **lockOrder: UNLOCK**

*   GUI calls “/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}” endpoint with UNLOCK as lockOrder

*   runtime-ACM receives the call by Rest-Api (InstantiationController)

*   It validates the status order issued (related AC Instance has DEPLOYED as deployState and LOCK as lockOrder)

*   It updates the AC Instance to DB with LOCKING lockOrder

*   It triggers the execution to send a broadcast AUTOMATION\_COMPOSITION\_STATE\_CHANGE message

*   the message is built by AutomationCompositionStateChangePublisher using Instance data. (with startPhase = first startPhase)


case **lockOrder: LOCK**

*   GUI calls “/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}” endpoint with LOCK as lockOrder

*   runtime-ACM receives the call by Rest-Api (InstantiationController)

*   It validates the status order issued (related AC Instance has DEPLOYED as deployState and UNLOCK as lockOrder)

*   It updates the AC Instance to DB with UNLOCKING lockOrder

*   It triggers the execution to send a broadcast AUTOMATION\_COMPOSITION\_STATE\_CHANGE message

*   the message is built by AutomationCompositionStateChangePublisher using Instance data. (with startPhase = last StartPhase)


case **deployOrder: UNDEPLOY**

*   GUI calls “/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}” endpoint with UNDEPLOY as deployOrder

*   runtime-ACM receives the call by Rest-Api (InstantiationController)

*   It validates the status order issued (related AC Instance has DEPLOYED as deployState and LOCK as lockOrder)

*   It updates the AC Instance to DB with UNDEPLOYING deployState

*   It triggers the execution to send a broadcast AUTOMATION\_COMPOSITION\_STATE\_CHANGE message

*   the message is built by AutomationCompositionStateChangePublisher using Instance data. (with startPhase = last StartPhase)


### [Delete of a Automation Composition Instance](#delete-of-a-automation-composition-instance)

*   GUI calls DELETE “/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}” endpoint

*   runtime-ACM receives the call by Rest-Api (InstantiationController)

*   It checks that AC Instance is in UNDEPLOYED deployState

*   It deletes the AC Instance from DB


### [Depriming of a Automation Composition Definition Type](#depriming-of-a-automation-composition-definition-type)

*   GUI calls POST “/onap/policy/clamp/acm/v2/compositions/{compositionId}” endpoint with DEPRIME as primeOrder

*   runtime-ACM receives the call by Rest-Api (CommissioningController)

*   It checks that Automation Composition Type Definition is in PRIMED status

*   It updates AC Definition to DB with DEPRIMING as status

*   It triggers the execution to send a broadcast PARTICIPANT\_PRIME message

*   the message is built by ParticipantPrimePublisher using Tosca Service Template data


### [Delete of a Automation Composition Definition Type](#delete-of-a-automation-composition-definition-type)

*   GUI calls DELETE “/onap/policy/clamp/acm/v2/compositions/{compositionId}” endpoint

*   runtime-ACM receives the call by Rest-Api (CommissioningController)

*   It checks that AC Definition Type is in COMMISSIONED status

*   It deletes the Automation Composition Type from DB


## [StartPhase](#startphase)

The startPhase is particularly important in Automation Composition update and Automation Composition state changes because sometime the user wishes to control the order in which the state changes in Automation Composition Elements in a Automation Composition.

### [How to define StartPhase](#how-to-define-startphase)

StartPhase is defined as shown below in the Definition of TOSCA fundamental Automation Composition Types yaml file.

```yaml
startPhase:
  type: integer
  required: false
  constraints:
  - greater-or-equal: 0
  description: A value indicating the start phase in which this Automation Composition element will be started, the
               first start phase is zero. Automation Composition Elements are started in their start_phase order and stopped
               in reverse start phase order. Automation Composition Elements with the same start phase are started and
               stopped simultaneously
  metadata:
    common: true
```

The “common: true” value in the metadata of the startPhase property identifies that property as being a common property. This property will be set on the CLAMP GUI during Automation Composition commissioning. Example where it could be used:

```yaml
org.onap.domain.database.Http_PMSHMicroserviceAutomationCompositionElement:
  # Consul http config for PMSH.
  version: 1.2.3
  type: org.onap.policy.clamp.acm.HttpAutomationCompositionElement
  type_version: 1.0.1
  description: Automation Composition element for the http requests of PMSH microservice
  properties:
    provider: ONAP
    uninitializedToPassiveTimeout: 180
    startPhase: 1
```

### [How StartPhase works](#how-startphase-works)

In state changes from UNDEPLOYED → DEPLOYED or LOCKED → UNLOCKED, Automation Composition elements are started in increasing order of their startPhase.

Example of DEPLOY order with Http\_PMSHMicroserviceAutomationCompositionElement with startPhase to 1 and PMSH\_K8SMicroserviceAutomationCompositionElement with startPhase to 0

*   runtime-ACM sends a broadcast AUTOMATION\_COMPOSITION\_DEPLOY message to all participants with startPhase = 0

*   participant receives the AUTOMATION\_COMPOSITION\_DEPLOY message and runs to DEPLOYED state (only AC elements defined as startPhase = 0)

*   runtime-ACM receives AUTOMATION\_COMPOSITION\_DEPLOY\_ACK messages from participants and set the state (from the AC element of the message) to DEPLOYED

*   runtime-ACM calculates that all AC elements with startPhase = 0 are set to proper state and sends a broadcast AUTOMATION\_COMPOSITION\_DEPLOY message with startPhase = 1

*   participant receives the AUTOMATION\_COMPOSITION\_DEPLOY message and runs to DEPLOYED state (only AC elements defined as startPhase = 1)

*   runtime-ACM receives AUTOMATION\_COMPOSITION\_DEPLOY\_ACK messages from participants and set the state (from the AC element of the message) to DEPLOYED

*   runtime-ACM calculates that all AC elements are set to proper state and set AC to DEPLOYED


In that scenario the message AUTOMATION\_COMPOSITION\_DEPLOY has been sent two times.

## [Design of managing messages](#design-of-managing-messages)

### [PARTICIPANT_REGISTER](#participant-register)

*   A participant starts and send a PARTICIPANT\_REGISTER message with participantId and supported Element Types

*   runtime-ACM collects the message from Message Broker by ParticipantRegisterListener

*   if not present, it saves participant reference with status ON\_LINE to DB


### [PARTICIPANT_PRIME_ACK](#participant-prime-ack)

*   A participant sends PARTICIPANT\_PRIME\_ACK message in response to a PARTICIPANT\_PRIME message

*   ParticipantPrimeAckListener collects the message from Message Broker

*   It updates AC Definition to DB with PRIMED/DEPRIMED as status


### [PARTICIPANT_STATUS](#participant-status)

*   A participant sends a scheduled PARTICIPANT\_STATUS message with participantId and supported Element Types

*   runtime-ACM collects the message from Message Broker by ParticipantStatusListener

*   if not present, it saves participant reference with status ON\_LINE to DB

*   MessageIntercept intercepts that event and adds a task to handle PARTICIPANT\_STATUS in SupervisionScanner

*   SupervisionScanner clears and starts the monitoring for participantStatus


### [AUTOMATION_COMPOSITION_DEPLOY_ACK](#automation-composition-deploy-ack)

*   A participant sends AUTOMATION\_COMPOSITION\_DEPLOY\_ACK message in response to a AUTOMATION\_COMPOSITION\_DEPLOY message. It will send a AUTOMATION\_COMPOSITION\_DEPLOY\_ACK - for each AC elements moved to the DEPLOYED state

*   AutomationCompositionUpdateAckListener collects the message from Message Broker

*   It checks the status of all Automation Composition elements and checks if the Automation Composition is fully DEPLOYED

*   It updates the AC to DB

*   MessageIntercept intercepts that event and adds a task to handle a monitoring execution in SupervisionScanner


### [AUTOMATION_COMPOSITION_STATECHANGE_ACK](#automation-composition-statechange-ack)

*   A participant sends AUTOMATION\_COMPOSITION\_STATECHANGE\_ACK message in response to a AUTOMATION\_COMPOSITION\_STATECHANGE message. It will send a AUTOMATION\_COMPOSITION\_DEPLOY\_ACK - for each AC elements moved to the ordered state

*   AutomationCompositionStateChangeAckListener collects the message from Message Broker

*   It checks the status of all Automation Composition elements and checks if the transition process of the Automation Composition is terminated

*   It updates the AC to DB

*   MessageIntercept intercepts that event and adds a task to handle a monitoring execution in SupervisionScanner


## [Design of monitoring execution in SupervisionScanner](#design-of-monitoring-execution-in-supervisionscanner)

Monitoring is designed to process the follow operations:

*   to determine the next startPhase in a AUTOMATION_COMPOSITION_DEPLOY message

*   to update AC deployState: in a scenario that “AutomationComposition.deployState” is in a kind of transitional state (example DEPLOYING), if all - AC elements are moved properly to the specific state, the “AutomationComposition.deployState” will be updated to that and saved to DB

*   to update AC lockState: in a scenario that “AutomationComposition.lockState” is in a kind of transitional state (example LOCKING), if all - AC elements are moved properly to the specific state, the “AutomationComposition.lockState” will be updated to that and saved to DB

*   to retry AUTOMATION_COMPOSITION_DEPLOY/AUTOMATION_COMPOSITION_STATE_CHANGE messages. if there is a AC Element not in the proper state, it will retry a broadcast message


The solution Design of retry, timeout, and reporting for all Participant message dialogues are implemented into the monitoring execution.

*   Spring Scheduling inserts the task to monitor retry execution into ThreadPoolExecutor

*   ThreadPoolExecutor executes the task

*   a message will be retry if runtime-ACM do no receive Act message before MaxWaitMs milliseconds


## [Design of Exception handling](#design-of-exception-handling)

### [GlobalControllerExceptionHandler](#globalcontrollerexceptionhandler)

If error occurred during the Rest Api call, runtime-ACM responses with a proper status error code and a JSON message error. This class is implemented to intercept and handle AutomationCompositionException, PfModelException and PfModelRuntimeException if they are thrown during the Rest Ali calls. All of those classes must implement ErrorResponseInfo that contains message error and status response code. So the Exception is converted in JSON message.

### [RuntimeErrorController](#runtimeerrorcontroller)

If wrong end-point is called or an Exception not intercepted by GlobalControllerExceptionHandler, runtime-ACM responses with a proper status error code and a JSON message error. This class is implemented to redirect the standard Web error page to a JSON message error. Typically that happen when a wrong end-point is called, but also could be happen for not authorized call, or any other Exception not intercepted by GlobalControllerExceptionHandler.

## [Handle version and “X-ONAP-RequestID”](#handle-version-and-x-onap-requestid)

RequestResponseLoggingFilter class handles version and “X-ONAP-RequestID” during a Rest-Api call; it works as a filter, so intercepts the Rest-Api and adds to the header those information.

## [Media Type Support](#media-type-support)

runtime-ACM Rest Api supports **application/json**, **application/yaml** and **text/plain** Media Types. The configuration is implemented in CoderHttpMesageConverter.

### [application/json](#application-json)

JSON format is a standard for Rest Api. For the conversion from JSON to Object and vice-versa will be used **org.onap.policy.common.utils.coder.StandardCoder**.

### [application/yaml](#application-yaml)

YAML format is a standard for Automation Composition Type Definition. For the conversion from YAML to Object and vice-versa will be used **org.onap.policy.common.utils.coder.StandardYamlCoder**.

### [text/plain](#text-plain)

Text format is used by Prometheus. For the conversion from Object to String will be used **StringHttpMessageConverter**.
