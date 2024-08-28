
# [ACM System Level Dialogues](#acm-system-level-dialogues)

Priming The CLAMP Automation Composition Runtime Lifecycle Management uses the following system-level dialogues. These dialogues enable the CLAMP runtime capabilities described in Section 2 of TOSCA Defined Automation Compositions: Architecture and Design. Design Time dialogues will be described in future releases of the system.

## Contents

*   [ACM System Level Dialogues](#acm-system-level-dialogues)

    *   [1 Dialogues on Participants](#1-dialogues-on-participants)

        *   [1.1 Register a Participant](#11-register-a-participant)

        *   [1.2 Deregister a Participant](#12-deregister-a-participant)

        *   [1.3 Supervise Participants](#13-supervise-participants)

        *   [1.4 Get Participant Information](#14-get-participant-information)

        *   [1.5 Order Full Participant Report](#15-order-full-participant-report)

    *   [2 Dialogues on Automation Composition Types](#2-dialogues-on-automation-composition-types)

        *   [2.1 Commission or Update an Automation Composition Type](#21-commission-or-update-an-automation-composition-type)

        *   [2.2 Commission an Automation Composition Type using SDC](#22-commission-an-automation-composition-type-using-sdc)

        *   [2.3 Decommission an Automation Composition Type](#23-decommission-an-automation-composition-type)

        *   [2.4 Prime an Automation Composition Type on Participants](#24-prime-an-automation-composition-type-on-participants)

        *   [2.5 Deprime an Automation Composition Type on Participants](#25-deprime-an-automation-composition-type-on-participants)

        *   [2.6 Get Automation Composition Types](#26-get-automation-composition-types)

    *   [3. Instantiation Dialogues](#3-instantiation-dialogues)

        *   [3.1 Create an Automation Composition Instance](#31-create-an-automation-composition-instance)

        *   [3.2 Delete an Automation Composition Instance](#32-delete-an-automation-composition-instance)

        *   [3.3 Deploy Automation Composition Instance](#33-deploy-automation-composition-instance)
        
        *   [3.4 Update Automation Composition Instance](#34-update-automation-composition-instance)
        
        *   [3.5 Migrate Automation Composition Instance](#35-migrate-automation-composition-instance) 

        *   [3.6 Undeploy Automation Composition Instance](#36-undeploy-automation-composition-instance)

        *   [3.7 Read Automation Composition Instances](#37-read-automation-composition-instances)

        *   [3.8 Unlock Automation Composition Instance](#38-unlock-automation-composition-instance)

        *   [3.9 Lock Automation Composition Instance](#39-lock-automation-composition-instance)

        *   [3.10 Update Operational State on Automation Composition Instance](#310-update-operational-state-on-automation-composition-instance)

        *   [3.11 Update Usage State on Automation Composition Instance](#311-update-usage-state-on-automation-composition-instance)
        
        *   [3.12 Failure Handling in ACM](#312-failure-handling-in-acm)
        
        *   [3.13 OFF_LINE handling in ACM](#313-off_line-handling-in-acm)


## [1 Dialogues on Participants](#dialogues-on-participants)

### [1.1 Register a Participant](#register-a-participant)

Participant Registration is performed by a Participant when it starts up. It registers its ID and the ACM Element Types it supports with the ACM runtime.

![RegisterParticipant.png](RegisterParticipant.png)

### [1.2 Deregister a Participant](#deregister-a-participant)

Participant Deregistration is performed by a Participant when it shuts down. It deregisters its ID and type with the ACM runtime. The participant should already have cleared down all its ACM Element instances and set their states to “Not In Service”.

![DeregisterParticipant.png](DeregisterParticipant.png)

### [1.3 Supervise Participants](#supervise-participants)

Participant Supervision is performed periodically between participants and the ACM runtime server to ensure that registered participants are available over time. Participants send a heartbeat message to the ACM runtime at a configured interval. The heartbeat message contains updated status information for each AC Element Instance that has changed status since the last Heartbeat message sent by the participant.

![SuperviseParticipantsStatusUpdate.png](SuperviseParticipantsStatusUpdate.png)

The ACM runtime regularly checks the heartbeat reports from participants and takes action if participants time out. If a heartbeat message is not received for a participant in the Timeout Interval, the participant is marked as timed out and its ACM element instances are informed.

![SuperviseParticipantsTimeout.png](SuperviseParticipantsTimeout.png)

### [1.4 Get Participant Information](#get-participant-information)

The information on participants is available over a REST endpoint.

![GetParticipantInformation.png](GetParticipantInformation.png)

### [1.5 Order Full Participant Report](#order-full-participant-report)

![FullParticipantReport.png](FullParticipantReport.png)

## [2 Dialogues on Automation Composition Types](#dialogues-on-automation-composition-types)

Commissioning dialogues are used to commission and decommission Automation Composition Types and to set the values of Common Parameters. The values of common parameters are included in the TOSCA YAML file that defines the full Automation Composition Type.

### [2.1 Commission or Update an Automation Composition Type](#commission-or-update-an-automation-composition-type)

Create on a POST and update on a PUT.

![CommissionUpdateAcType.png](CommissionUpdateAcType.png)

### [2.2 Commission an Automation Composition Type using SDC](#commission-an-automation-composition-type-using-sdc)

![CommissionAcTypeSDC.png](CommissionAcTypeSDC.png)

### [2.3 Decommission an Automation Composition Type](#decommission-an-automation-composition-type)

![DecommissionAcType.png](DecommissionAcType.png)

### [2.4 Prime an Automation Composition Type on Participants](#prime-an-automation-composition-type-on-participants)

The Priming operation sends Automation Composition Types and common property values to participants for each Automation Composition Element Type in the Automation Composition Type.

![PrimeAcTypeOnPpnts.png](PrimeAcTypeOnPpnts.png)

A participant should respond for each Automation Composition Element Type, thus causing the full Automation Composition Type to become primed. Note that if more than one participant can support an Automation Composition Element Type the ACM Runtime uses the participant in the first response it receives for that Automation Composition Element Type.

![PrimeAcTypeMultiplePpnts.png](PrimeAcTypeMultiplePpnts.png)

The ACM Runtime updates the priming information in the database.

![PrimeInfoUpdatedInDb.png](PrimeInfoUpdatedInDb.png)

### [2.5 Deprime an Automation Composition Type on Participants](#deprime-an-automation-composition-type-on-participants)

The Depriming operation removes Automation Composition Types and common property values on participants for each Automation Composition Element Type in the Automation Composition Type.

![DeprimeOnParticipants.png](DeprimeOnParticipants.png)

A participant should respond for each Automation Composition Element Type, thus causing the full Automation Composition Type to become deprimed.

![DeprimeElements.png](DeprimeElements.png)

The ACM Runtime updates the priming information in the database.

![UpdateDeprimeInDb.png](UpdateDeprimeInDb.png)

### [2.6 Get Automation Composition Types](#get-automation-composition-types)

This dialogue allows an Automation Composition Type to be read.

![GetAcTypes.png](GetAcTypes.png)

## [3. Instantiation Dialogues](#instantiation-dialogues)


Instantiation dialogues are used to create, set parameters on, instantiate, update, and remove Automation Composition instances.

### [3.1 Create an Automation Composition Instance](#create-an-automation-composition-instance)

![CreateAcInstance.png](CreateAcInstance.png)

Note that this dialogue creates the Automation Composition Instance in the ACM database. The instance is sent to the participants using the process described in the dialogue in Section 3.3.

### [3.2 Delete an Automation Composition Instance](#delete-an-automation-composition-instance)

The user requests the AC Instance to be deleted using a REST endpoint. The ACM Runtime orders the AC Instance to be deleted.

![DeleteAcInstance1.png](DeleteAcInstance1.png)

Each participant deletes its AC Element Instances from the AC Instance

![DeleteAcInstance2.png](DeleteAcInstance2.png)

The ACM Runtime receives and stores the responses, when all instances element are deleted, it deletes the instance.

![DeleteAcInstance3.png](DeleteAcInstance3.png)

### [3.3 Deploy Automation Composition Instance](#deploy-automation-composition-instance)

The user requests the AC Instance to be deployed using a REST endpoint. The ACM Runtime orders the AC Instance to be deployed to Participants.

![DeployAcInstance.png](DeployAcInstance.png)

Each participant deploys its AC Element Instances from the AC Instance.

![DeployAcInstanceElements.png](DeployAcInstanceElements.png)

The ACM Runtime receives and stores the responses.

![DeployResponseStored.png](DeployResponseStored.png)

### [3.4 Update Automation Composition Instance](#update-automation-composition-instance)

The user requests the AC Instance to be updated using a REST endpoint. The ACM Runtime orders the AC Instance to be updated.

![UpdateAcInstance1.png](UpdateAcInstance1.png)

Each participant updates its AC Element from the AC Instance

![UpdateAcInstance2.png](UpdateAcInstance2.png)

The ACM Runtime receives and stores the responses.

![UpdateAcInstance3.png](UpdateAcInstance3.png)

### [3.5 Migrate Automation Composition Instance](#migrate-automation-composition-instance)

The user requests the AC Instance to be migrated using a REST endpoint. The ACM Runtime orders the AC Instance to be migrated.

![MigrateAcInstance1.png](MigrateAcInstance1.png)

Each participant migrated its AC Element from the AC Instance

![MigrateAcInstance2.png](MigrateAcInstance2.png)

The ACM Runtime receives and stores the responses.

![MigrateAcInstance3.png](MigrateAcInstance3.png)



### [3.6 Undeploy Automation Composition Instance](#undeploy-automation-composition-instance)

The user requests the AC Instance to be undeployed using a REST endpoint. The ACM Runtime orders the AC Instance to be undeployed.

![UndeployInstance.png](UndeployInstance.png)

Each participant undeploys its AC Element Instances from the AC Instance

![UndeployInstanceElements.png](UndeployInstanceElements.png)

The ACM Runtime receives and stores the responses.

![UndeployResponseStored.png](UndeployResponseStored.png)

### [3.7 Read Automation Composition Instances](#read-automation-composition-instances)

![ReadAcInstances.png](ReadAcInstances.png)

### [3.8 Unlock Automation Composition Instance](#unlock-automation-composition-instance)

The user requests the AC Instance to be unlocked using a REST endpoint. The ACM Runtime orders the AC Instance to be unlocked on Participants.

![OrderInstanceUnlock.png](OrderInstanceUnlock.png)

Each participant unlocks its AC Element Instances from the AC Instance.

![UnlockInstanceElements.png](UnlockInstanceElements.png)

The ACM Runtime receives and stores the responses.

![UnlockResponseStored.png](UnlockResponseStored.png)

### [3.9 Lock Automation Composition Instance](#lock-automation-composition-instance)

The user requests the AC Instance to be locked using a REST endpoint. The ACM Runtime orders the AC Instance to be locked on Participants.

![LockAcInstance.png](LockAcInstance.png)

Each participant locks its AC Element Instances from the AC Instance.

![LockAcInstanceElements.png](LockAcInstanceElements.png)

The ACM Runtime receives and stores the responses.

![LockResponseStored.png](LockResponseStored.png)

### [3.10 Update Operational State on Automation Composition Instance](#update-operational-state-on-automation-composition-instance)

![UpdateOperationalState.png](UpdateOperationalState.png)

### [3.11 Update Usage State on Automation Composition Instance](#update-usage-state-on-automation-composition-instance)

![UpdateUsageState.png](UpdateUsageState.png)

### [3.12 Failure Handling in ACM](#failure-handling-in-acm)

After any ACM operation is completed, one of the following result messages will be updated in the ACM. These result values are updated along with the overall state of the ACM instance.

- NO_ERROR
- TIMEOUT 
- FAILED

The enum result values ‘NO_ERROR’ and ‘FAILED’ have to be set by the participants while reporting the CompositionState back to the runtime.

If the operation succeeds, the participant is required to update the result value with ‘NO_ERROR’ while reporting the composition state.

![FailureHandling1.png](FailureHandling1.png)

The result value should be updated as ‘FAILED’ by the participants when any failures occurred. Also in case of failures, the overall state of the composition/instance remains in any of the transitioning states (DEPLOYING, UNDEPLOYING, PRIMING, DEPRIMING, UPDATING, MIGRATING) with the appropriate result values updated by the participant.

![FailureHandling2.png](FailureHandling2.png)

Runtime marks the operation result with the value ‘TIMEOUT’ when the participant fails to report the message back during an ACM operation, the operation result is then marked as ‘TIMEOUT’ by the ACM-R after the configured waiting limit is reached.

![FailureHandling3.png](FailureHandling3.png)

The following parameter is set in the application properties for the runtime to configure the ‘TIMEOUT’ value in milliseconds.

```yaml
runtime:
  participantParameters:
    maxStatusWaitMs: 100000  --> Denotes the maximum wait time by the runtime to receive the periodic status update from the participants
```

An ACM operation has to be completed and updated with any of the above specified result values in order to allow the user to trigger subsequent requests. The user cannot trigger any state change events before the operation gets completed. When an operation is marked ‘TIMEOUT’, the following scenarios are applicable.

- The participant might complete the operation to mark the result with ‘NO_ERROR’ or ‘FAILED’ 
- The user can trigger another state change event to the ACM.

The following flow shown and example of deployment that get stuck, and the user decide to undeploy.

![FailureHandling4.png](FailureHandling4.png)

### [3.13 OFF_LINE handling in ACM](#offline-handling-in-acm)

Runtime marks the participant state with the value ‘OFF_LINE’ when the participant fails to report the periodic heartbeat, the participant state is then marked as ‘OFF_LINE’ by the ACM-R after the configured waiting limit is reached. That scenario might happen when participant is shutdown, in that scenario all on going operations with that participant are marked ‘TIMEOUT’ due the missing messages back.

![OfflineHandling.png](OfflineHandling.png)

When a participant state is marked ‘OFF_LINE’, it might come back ONLINE and the user can trigger state change events to the ACM.
