# [The ACM Automation Composition Participant Protocol](#the-acm-automation-composition-participant-protocol)

The ACM Automation Composition protocol is an asynchronous protocol that is used by the ACM runtime to coordinate lifecycle management of Automation Composition instances. The protocol supports the functions described in the sections below.

## [Protocol Dialogues](#protocol-dialogues)

The protocol supports the dialogues described below.

### [Participant Registration and De-Registration](#participant-registration-and-de-registration)

Participant Registration is performed by a Participant when it starts up. It registers its ID and the ACM Element Types it supports with the ACM runtime. In a scenario where Participant has been restarted, ACM runtime have to provide all Primed ACM Definition and Deployed ACM instances of the Participant sending a Restart message.

![RegisterParticipant.png](RegisterParticipant.png)

Participant Deregistration is performed by a Participant when it shuts down. It deregisters its ID and type with the ACM runtime.

![DeregisterParticipant.png](DeregisterParticipant.png)

### [Automation Composition Priming and De-Priming](#automation-composition-priming-and-de-priming)

The Priming operation sends Automation Composition Types and common property values to participants for each Automation Composition Element Type in the Automation Composition Type. The ParticipantPrime message type is sent to trigger priming and depriming in participants.

![PrimeAcTypeOnPpnts.png](PrimeAcTypeOnPpnts.png)

A participant should respond for each Automation Composition Element Type, thus causing the full Automation Composition Type to become primed. Note that if more than one participant can support an Automation Composition Element Type the ACM Runtime uses the participant in the first response it receives for that Automation Composition Element Type.

![PrimeAcTypeMultiplePpnts.png](PrimeAcTypeMultiplePpnts.png)

The ACM Runtime updates the priming information in the database.

![PrimeInfoUpdatedInDb.png](PrimeInfoUpdatedInDb.png)

The Depriming operation removes Automation Composition Types and common property values on participants for each Automation Composition Element Type in the Automation Composition Type.

![DeprimeOnParticipants.png](DeprimeOnParticipants.png)

A participant should respond for each Automation Composition Element Type, thus causing the full Automation Composition Type to become deprimed.

![DeprimeElements.png](DeprimeElements.png)

The ACM Runtime updates the priming information in the database.

![UpdateDeprimeInDb.png](UpdateDeprimeInDb.png)

### [Automation Composition Update](#automation-composition-update)

Automation Composition Update handles creation, change, and deletion of Automation Compositions on participants. Change of Automation Compositions uses a semantic versioning approach and follows the semantics described on the page [5.1 Management of Automation Composition Instance Configurations](https://adp.ericsson.se/marketplace/automation-composition-mgmt-runtime/documentation/development/dpi/service-user-guide#51-management-of-automation-composition-instance-configurations).

![acm-update.png](acm-update.png)

The handling of an _ACMUpdate_ message in each participant is as shown below.

![acm-update-msg.png](acm-update-msg.png)

### [Automation Composition State Change](#automation-composition-state-change)

This dialogue is used to change the state of Automation Compositions and their Automation Composition Elements. The CLAMP Runtime sends an Automation Composition State Change message on the Automation Composition to all participants. Participants that have Automation Composition Elements in that Automation Composition attempt an update on the state of the Automation Composition elements they have for that Automation Composition, and report the result back.

The _startPhase_ in the [Definition of TOSCA fundamental Automation Composition Types](https://github.com/onap/policy-clamp/blob/master/common/src/main/resources/tosca/AutomationCompositionTOSCAServiceTemplateTypes.yaml) is particularly important in Automation Composition state changes because sometimes the user wishes to control the order in which the state changes in Automation Composition Elements in an Automation Composition. In-state changes from _UNDEPLOYED → DEPLOYED_, Automation Composition elements are started in increasing order of their startPhase. In-state changes from _DEPLOYED → UNDEPLOYED_, Automation Composition elements are started in decreasing order of their _startPhase_.

The ACM runtime controls the state change process described in the diagram below. The ACM runtime sends an Automation Composition state change message on the messaging system (e.g. Kafka) to all participants in a particular start phase so, in each state change multiple Automation Composition State Change messages are sent, one for each start phase in the Automation Composition. If more than one Automation Composition Element has the same start phase, those Automation Composition Elements receive the same Automation Composition State Change message from Kafka and start in parallel.

The Participant reads each State Change Message it sees on Kafka. If the start phase on the Automation Composition State Change message matches the Start Phase of the Automation Composition Element, the participant processes the state change message. Otherwise, the participant ignores the message.

![acm-state-change.png](acm-state-change.png)

The flow of the DEPLOY/UNDEPLOY state change messages are shown below. But the same flow is true for LOCK/UNLOCK and DELETE

---

**Note:**

More details of the state machine are available on [ACM States](https://adp.ericsson.se/marketplace/automation-composition-mgmt-runtime/documentation/development/additional-documents/acm-states#acm-states)

---
![acm-state-change-msg.png](acm-state-change-msg.png)

### [Automation Composition Monitoring and Reporting](#automation-composition-monitoring-and-reporting)

This dialogue is used as a heartbeat mechanism for participants, to monitor the status of Automation Composition Elements, and to gather statistics on Automation Compositions. The _ParticipantStatus_ message is sent periodically by each participant. The reporting interval for sending the message is configurable.

![acm-monitoring.png](acm-monitoring.png)

## [Messages](#messages)
--------------------------------------------------

The CLAMP Automation Composition Participant Protocol uses the following messages. The descriptions below give an overview of each message. For the precise definition of the messages, see the [CLAMP code at Github](https://github.com/onap/policy-clamp/tree/master/models/src/main/java/org/onap/policy/clamp/models/acm/messages/kafka/participant) . All messages are carried on Kafka.

[ACM Messages](#id1)

| Message                          | Source      | Target      | Purpose                                                                                     | Important Fields                 | Field Descriptions                                                                                                               |
|----------------------------------|-------------|-------------|---------------------------------------------------------------------------------------------|----------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| ParticipantRegister              | Participant | ACM Runtime | Participant registers with the ACM runtime                                                  | participantId                    | The ID of this participant – in UUID format                                                                                      |
|                                  |             |             |                                                                                             | participantSupportedElementTypes | A list of element types that this participant supports                                                                           |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_REGISTER                                                                         |
| ParticipantRegisterAck           | ACM Runtime | Participant | Acknowledgment of Participant Registration                                                  | participantId                    | The ID of this participant – in UUID format                                                                                      |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_REGISTER_ACK                                                                     |
| ParticipantDeregister            | Participant | ACM Runtime | Participant deregisters with the ACM runtime                                                | participantId                    | The ID of this participant – in UUID format                                                                                      |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_DEREGISTER                                                                       |
| ParticipantDeregisterAck         | ACM Runtime | Participant | Acknowledgment of Participant Deegistration                                                 | participantId                    | The ID of this participant – in UUID format                                                                                      |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_DEREGISTER_ACK                                                                   |
| ParticipantPrime                 | ACM Runtime | Participant | Trigger priming/depriming in the participant                                                | participantId                    | The ID of this participant – in UUID format                                                                                      |
|                                  |             |             |                                                                                             | compositionId                    | The id of the AC Definition related to this message                                                                              |
|                                  |             |             |                                                                                             | participantDefinitionUpdates     | Contains AC element definition values for a particular participant                                                               |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_PRIME                                                                            |
| ParticipantPrimeAck              | Participant | ACM Runtime | Message to confirm participant has been primed/deprimed                                     | participantId                    | The ID of this participant – in UUID format                                                                                      |
|                                  |             |             |                                                                                             | compositionId                    | The id of the AC Definition related to this message                                                                              |
|                                  |             |             |                                                                                             | stateChangeResult                | NO_ERROR/FAILED                                                                                                                  |
|                                  |             |             |                                                                                             | message                          | A message indicating the result                                                                                                  |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_PRIME_ACK                                                                        |
| ParticipantStatusReq             | ACM Runtime | Participant | Message sent to reques a status update from the participant                                 | participantId                    | The ID of the participant to request update from – in UUID format                                                                |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_STATUS_REQ                                                                       |
| ParticipantStatus                | Participant | ACM Runtime | Status update message                                                                       | state                            | Enum indicating the current state of the participant                                                                             |
|                                  |             |             |                                                                                             | participantDefinitionUpdates     | A list of ParticipantDefinition updates, returned in response to ParticipantStatusReq only                                       |
|                                  |             |             |                                                                                             | automationCompositionInfoList    | List of AutomationCompositionInfo types with AutomationCompositionId and its state                                               |
|                                  |             |             |                                                                                             | participantSupportedElementTypes | Ac element types that this participant is capable for deployinh/supporting                                                       |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_STATUS                                                                           |
| AutomationCompositionDeploy      | ACM Runtime | Participant | Message to request change state of composition to DEPLOY                                    | participantUpdatesList           | A list of ParticipantUpdates instances which carries details of an updated participant.                                          |
|                                  |             |             |                                                                                             | compositionId                    | The id of the AC Definition related to this message                                                                              |
|                                  |             |             |                                                                                             | automationCompositionId          | The id of the automation composition related to this message                                                                     |
|                                  |             |             |                                                                                             | startPhase                       | Integer indicating the start up order of the elements                                                                            |
|                                  |             |             |                                                                                             | participantId                    | UUID indicating the participant the message is intended for                                                                      |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message AUTOMATION_COMPOSITION_DEPLOY                                                                |
| AutomationCompositionDeployAck   | Participant | ACM Runtime | Message to acknowledge that deploy or state change message has been received by participant | automationCompositionResultMap   | A map with AutomationCompositionElementID as its key, and a pair of result and message as value per AutomationCompositionElement |
|                                  |             |             |                                                                                             | compositionId                    | The id of the AC Definition related to this message                                                                              |
|                                  |             |             |                                                                                             | automationCompositionId          | The id of the automation composition related to this message                                                                     |
|                                  |             |             |                                                                                             | message                          | A message indicating the result                                                                                                  |
|                                  |             |             |                                                                                             | stateChangeResult                | NO_ERROR/FAILED                                                                                                                  |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message AUTOMATION_COMPOSITION_DEPLOY_ACK                                                            |
| AutomationCompositionStateChange | ACM Runtime | Participant | Message to request change state of composition to states other than DEPLOY                  | deployOrderedState               | Enum indicating the deployment state being requested                                                                             |
|                                  |             |             |                                                                                             | lockOrderedState                 | Enum indicating the lock state being requested                                                                                   |
|                                  |             |             |                                                                                             | compositionId                    | The id of the AC Definition related to this message                                                                              |
|                                  |             |             |                                                                                             | automationCompositionId          | The id of the automation composition related to this message                                                                     |
|                                  |             |             |                                                                                             | startPhase                       | Integer indicating the start up order of the elements                                                                            |
|                                  |             |             |                                                                                             | participantId                    | UUID indicating the participant the message is intended for                                                                      |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message AUTOMATION_COMPOSITION_STATECHANGE_ACK                                                       |
| PropertiesUpdate                 | ACM Runtime | Participant | Message to request update                                                                   | participantUpdatesList           | A list of ParticipantUpdates instances which carries details of an updated participant.                                          |
|                                  |             |             |                                                                                             | compositionId                    | The id of the AC Definition related to this message                                                                              |
|                                  |             |             |                                                                                             | automationCompositionId          | The id of the automation composition related to this message                                                                     |
|                                  |             |             |                                                                                             | participantId                    | UUID indicating the participant the message is intended for                                                                      |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_RESTART                                                                          |
| ParticipantRestart               | ACM Runtime | Participant | Message to request update                                                                   | participantId                    | The ID of this participant – in UUID format                                                                                      |
|                                  |             |             |                                                                                             | automationcompositionList        | A list of ParticipantRestartAc instances which carries details of an updated participant.                                        |
|                                  |             |             |                                                                                             | compositionId                    | The id of the AC Definition related to this message                                                                              |
|                                  |             |             |                                                                                             | participantDefinitionUpdates     | Contains AC element definition values for a particular participant                                                               |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PARTICIPANT_RESTART                                                                          |
| AutomationCompositionMigration   | ACM Runtime | Participant | Message to request update                                                                   | participantUpdatesList           | A list of ParticipantUpdates instances which carries details of an updated participant.                                          |
|                                  |             |             |                                                                                             | compositionId                    | The id of the AC Definition related to this message                                                                              |
|                                  |             |             |                                                                                             | compositionTargetId              | The id of the AC Definition target                                                                                               |
|                                  |             |             |                                                                                             | automationCompositionId          | The id of the automation composition related to this message                                                                     |
|                                  |             |             |                                                                                             | participantId                    | UUID indicating the participant the message is intended for                                                                      |
|                                  |             |             |                                                                                             | messageType                      | Enum indicating the type of message PROPERTIES_UPDATE                                                                            |
