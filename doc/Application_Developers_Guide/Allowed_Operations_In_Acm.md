# Allowed Operations In ACM

## Contents
- [Allowed operations in ACM](#allowed-operations-in-acm)
    - [CRUD Automation Composition Definition](#crud-automation-composition-definition)
    - [Change status of Automation Composition Definition](#change-status-of-automation-composition-definition)
    - [CRUD Automation Composition Instance](#crud-automation-composition-instance)
    - [Change status of Automation Composition Instance](#change-status-of-automation-composition-instance)

## CRUD Automation Composition Definition

| Action | state        | Description              |
|--------|--------------|--------------------------|
| Create |              | Create new AC Definition |
| Update | COMMISSIONED | Update the AC Definition |
| Delete | COMMISSIONED | Delete the AC Definition |

## Change status of Automation Composition Definition

| Action  | state        | stChResult | Description                                                                      |
|---------|--------------|------------|----------------------------------------------------------------------------------|
| Prime   | COMMISSIONED |            | Start Priming transition                                                         |
|         | PRIMING      | FAILED     | Start Priming transition after PRIMING is failed                                 |
|         | PRIMING      | TIMEOUT    | Start Priming transition after PRIMING got timeout                               |
|         | DEPRIMING    | FAILED     | Start Priming transition after DEPRIMING is failed                               |
|         | DEPRIMING    | TIMEOUT    | Start Priming transition after DEPRIMING got timeout                             |
| Deprime | PRIMED       | NO_ERROR   | Start Depriming the AC Definition. No instances connected to this AC Definition. |
|         | DEPRIMING    | FAILED     | Start Depriming after DEPRIMING is failed                                        |
|         | DEPRIMING    | TIMEOUT    | Start Depriming after DEPRIMING got timeout                                      |
|         | PRIMING      | FAILED     | Start Depriming after PRIMING is failed                                          |
|         | PRIMING      | TIMEOUT    | Start Depriming after PRIMING got timeout                                        |

*Note*: “stChResult” = stateChangeResult.

## CRUD Automation Composition Instance

AC Definition is PRIMED with NO_ERROR.

| Action  | deployState | lockState | stChResult | Description                                                                          |
|---------|-------------|-----------|------------|--------------------------------------------------------------------------------------|
| Create  |             |           |            | Create a new AC instance                                                             |
| Update  | UNDEPLOYED  |           |            | Update the AC Instance                                                               |
|         | DEPLOYED    | LOCKED    |            | Update the AC Instance and send update to participants                               |
|         | UPDATING    | LOCKED    | FAILED     | Start Updating transition and send update to participants after UPDATING is failed   |
|         | UPDATING    | LOCKED    | TIMEOUT    | Start Updating transition and send update to participants after UPDATING got timeout |
| Migrate | DEPLOYED    | LOCKED    |            | Start Migrating transition and send migrate to participants                          |
| Delete  | UNDEPLOYED  |           |            | Start Deleting transition and send delete to participants                            |
|         | DELETING    | NONE      | FAILED     | Start Deleting transition and send delete to participants after DELETING is failed   |
|         | DELETING    | NONE      | TIMEOUT    | Start Deleting transition and send delete to participants after DELETING got timeout |

## Change status of Automation Composition Instance

| Action   | deployState | lockState | stChResult | Description                                                                                  |
|----------|-------------|-----------|------------|----------------------------------------------------------------------------------------------|
| Deploy   | UNDEPLOYED  |           |            | Start Deploying transition and send deploy to participants                                   |
|          | DEPLOYING   | NONE      | FAILED     | Start Deploying transition and send deploy to participants after DEPLOYING is failed         |
|          | DEPLOYING   | NONE      | TIMEOUT    | Start Deploying transition and send deploy to participants after DEPLOYING got timeout       |
|          | UNDEPLOYING | NONE      | FAILED     | Start Deploying transition and send deploy to participants after UNDEPLOYING is failed       |
|          | UNDEPLOYING | NONE      | TIMEOUT    | Start Deploying transition and send deploy to participants after UNDEPLOYING got timeout     |
| Undeploy | DEPLOYED    | LOCKED    |            | Start Undeploying transition and send undeploy to participants                               |
|          | DEPLOYING   | NONE      | FAILED     | Start Undeploying transition and send undeploy to participants after DEPLOYING is failed     |
|          | UNDEPLOYING | NONE      | FAILED     | Start Undeploying transition and send undeploy to participants after UNDEPLOYING is failed   |
|          | UNDEPLOYING | NONE      | TIMEOUT    | Start Undeploying transition and send undeploy to participants after UNDEPLOYING got timeout |
|          | UPDATING    | LOCKED    | FAILED     | Start Undeploying transition and send update to participants after UPDATING is failed        |
|          | UPDATING    | LOCKED    | TIMEOUT    | Start Undeploying transition and send update to participants after UPDATING got timeout      |
|          | MIGRATING   | LOCKED    | FAILED     | Start Undeploying transition and send update to participants after MIGRATING is failed       |
|          | MIGRATING   | LOCKED    | TIMEOUT    | Start Undeploying transition and send update to participants after MIGRATING got timeout     |
| Lock     | DEPLOYED    | UNLOCKED  |            | Start Locking transition and send lock to participants                                       |
|          | DEPLOYED    | UNLOCKING | FAILED     | Start Locking transition and send lock to participants after UNLOCKING is failed             |
|          | DEPLOYED    | UNLOCKING | TIMEOUT    | Start Locking transition and send lock to participants after UNLOCKING got timeout           |
|          | DEPLOYED    | LOCKING   | FAILED     | Start Locking transition and send lock to participants after LOCKING is failed               |
|          | DEPLOYED    | LOCKING   | TIMEOUT    | Start Locking transition and send lock to participants after LOCKING got timeout             |
| Unlock   | DEPLOYED    | LOCKED    |            | Start Unlocking transition and send unlock to participants                                   |
|          | DEPLOYED    | UNLOCKING | FAILED     | Start Unlocking transition and send unlock to participants after UNLOCKING is failed         |
|          | DEPLOYED    | UNLOCKING | TIMEOUT    | Start Unlocking transition and send unlock to participants after UNLOCKING got timeout       |
|          | DEPLOYED    | LOCKING   | FAILED     | Start Unlocking transition and send unlock to participants after LOCKING is failed           |
|          | DEPLOYED    | LOCKING   | TIMEOUT    | Start Unlocking transition and send unlock to participants after LOCKING got timeout         |
