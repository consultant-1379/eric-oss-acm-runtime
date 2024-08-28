# ACM States

## Contents

*   [ACM States](#acm-states)

    *   [Participant State](#participant-state)

    *   [Automation Composition Type State](#automation-composition-type-state)

    *   [Automation Composition Element Type State](#automation-composition-element-type-state)

    *   [Automation Composition Instance State](#automation-composition-instance-state)

    *   [Automation Composition Element Instance State](#automation-composition-element-instance-state)

Automation Composition Management manages a number of states of various types to manage the lifecycle of compositions. Those states are described here. Please also see the ACM System Level Dialogues page to see the system dialogues that change states and how states interrelate in detail. Please also see ITU Recommendation X.731, which is reflected in the states of AC Element Instances.

## [Participant State](#participant-state)


Participant states are NOT managed by ACM but the state of a participant is recorded and supervised by ACM.

![ParticipantStates.png](ParticipantStates.png)

## [Automation Composition Type State](#automation-composition-type-state)

The states that an Automation Composition Type can have are shown in the diagram below.

![AcTypeStates.png](AcTypeStates.png)

## [Automation Composition Element Type State](#automation-composition-element-type-state)

The states that an Automation Composition Element Type can have on ACM Runtime are shown in the diagram below.

![AcElementTypeStatesOnRuntime.png](AcElementTypeStatesOnRuntime.png)

The states that an Automation Composition Element Type can have on a Participant are shown in the diagram below.

![AcElementTypeStatesOnPpnt.png](AcElementTypeStatesOnPpnt.png)

The states diagram below, shows the fail and timeout scenario. In that diagram the state is presented using this combination [ Composition Element Type State : Composition Type State : StateChangeResult ].
![AcElementTypeStatesOnPpnt.png](CombinedCompositionState.png)

## [Automation Composition Instance State](#automation-composition-instance-state)

The states that an Automation Composition Instance can have are shown in the diagram below.

![AcInstanceStates.png](AcInstanceStates.png)

## [Automation Composition Element Instance State](#automation-composition-element-instance-state)

The states that an Automation Composition Element Instance can have on ACM Runtime are shown in the diagram below.

![AcElementInstanceStatesOnRuntime.png](AcElementInstanceStatesOnRuntime.png)

The states that an Automation Composition Element Instance can have on a Participant are shown in the diagram below.

![AcElementInstanceStatesOnPpnt.png](AcElementInstanceStatesOnPpnt.png)

## [Automation Composition State with fail and timeout](#automation-composition-state-with-fail-and-timeout)

The states that an Automation Composition Element Instance can have for each flow, are shown in the diagrams below. For each diagram the state is presented using this combination [ Instance Element State : Instance State : StateChangeResult ].

![DeployFailTimeout.png](DeployFailTimeout.png)

![UpdateFailTimeout.png](UpdateFailTimeout.png)

![MigrateFailTimeout.png](MigrateFailTimeout.png)

![DeleteFailTimeout.png](DeleteFailTimeout.png)
