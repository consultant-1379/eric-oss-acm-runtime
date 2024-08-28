
# ACM Test Specification

## Contents

* [ACM Tests](#acm-tests)

    * [Introduction](#introduction)

    * [Integration Tests](#integration-tests)

    * [REST Tests](#rest-tests)


## [Introduction](#introduction)
This document contains the Test specification for the Automation Composition Management application.

## Function Tests

### [Integration Tests](#integration-tests)

ACM Integration tests can be performed involving the participants and ACM-R deployed together for a valid ACM use case.
The following test cases can be verified to make sure the ACM flow works as expected.

| **No** 	| **TestCase**                           	| **Test Description**                                                                                                                                                                                                                                                                                                                                                                                                                                                        	|
|--------	|----------------------------------------	|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| 1      	| CommissionAutomationCompositionTest    	| A Tosca service template is commissioned to the runtime that includes the definition of a composition involving one or more participants.<br>The definition should be accepted by ACM-R and returns a 201 response back.                                                                                                                                                                                                                                                    	|
| 2      	| PrimeACDefinitionsTest                 	| The ACM-R is issued with a Prime order using the composition id. The specified composition should be associated with suitable participants<br>and priming events are sent to the associated participants. ACM-R should return a 202 response back.<br><br>The composition can be fetched to verify the AC elements associated with participants.                                                                                                                            	|
| 3      	| InstantiateAutomationCompositionTest   	| Create an Automation Composition instance with the previously commissioned composition. Appropriate element properties are supplied for the<br>instance along with the startPhase value. ACM-R should return 201 response for successful instance creation.                                                                                                                                                                                                                 	|
| 4      	| DeployAutomationCompositionTest        	| Trigger a deploy order to the ACM-R to deploy the created instance using the instance id. This should return a 202 response.<br>This should send an update event to the participants with the AC element list for the participants to perform the defined deploy action.<br>Verify the intended operations of the participants are performed successfully. The overall state of the ACM instance should be updated to <br>'Deployed' once the operations are all completed. 	|
| 5      	| UndeployAutomationCompositionTest      	| Trigger an undeploy order to the ACM-R to uninstantiate the AC instance using the instance id. This should return a 202 response.<br>This should send an undeploy order to the participants and the participants responds as per the undeploy implementation.<br>Verify the intended operations of the participants are performed successfully. The overall state of the ACM instance should be updated to <br>'Undeployed'.                                                	|
| 6      	| UninstantiateAutomationCompositionTest 	| Delete the AC instance from the participants and the ACM-R using the uninstantiate Rest Api. This should return a 200 response.<br>This should send a DELETE event to the participants to remove the instance information and also deletes the instance from the runtime database.                                                                                                                                                                                          	|
| 7      	| DePrimeACDefinitionsTest               	| Trigger a deprime order to the ACM-R to de-associate the AC definitions and participants using the compositionId.<br>Fetching the compositions should not have participants associated with the elements after successful depriming.<br>This returns a 202 on a successful acceptance of depriming request.                                                                                                                                                                 	|
| 8      	| DeleteACDefinitionTest                 	| Invoke the delete API of ACM-R to delete the AC definitions using the compositionId. This deletes the AC definition that was commissioned.<br>Returns a 200 response on a successful deletion.                                                                                                                                                                                                                                                                              	|


### [REST Tests](#rest-tests)

These tests are added to ensure all the ACM endpoints are fully tested.

| **No** 	| **TestCase**                 	| **Test Description**                                                                                                    	|
|--------	|------------------------------	|-------------------------------------------------------------------------------------------------------------------------	|
| 1      	| GetAcmRuntimeHealthCheckTest 	| Test the ACM runtime health check status using the ACM runtime Api via REST                                             	|
| 2      	| GetAllParticipantsTest       	| Test fetching all the registered participants information using the ACM runtime Api via REST                            	|
| 3      	| CreateAcDefinitionTest       	| Test creating the AC definitions with a Tosca based service template using the ACM runtime Api via REST                 	|
| 4      	| GetAllCompositionsTest       	| Test fetching all the AC definitions from the database using the ACM runtime Api via REST                               	|
| 5      	| GetCompositionByIdTest       	| Test fetching a specific AC definition from the database using the 'compositionId' via REST                             	|
| 6      	| PrimeAcDefinitionTest        	| Test the priming of AC definitions to the participants using the ACM runtime Api via REST                               	|
| 7      	| DePrimeAcDefinitionsTest     	| Test depriming the AC definitions from the participants on the applicable ACM states using the ACM runtime Api via REST 	|
| 8      	| CreateAcInstanceTest         	| Test creating an AC instance on the runtime database using the ACM runtime Api via REST                                 	|
| 9      	| UpdateAcInstanceTest         	| Test updating an AC instance using the ACM runtime Api via REST                                                         	|
| 10     	| GetAllInstanceTest           	| Test fetching all the AC instances using the ACM runtime Api via REST                                                   	|
| 11     	| DeployAcInstanceTest         	| Test deployment of AC instance using the ACM runtime Api via REST                                                       	|
| 12     	| GetInstanceById              	| Test fetching of specific AC instance using the instance id via ACM runtime REST Api                                    	|
| 13     	| UndeployAcInstance           	| Test undeployment of AC instance on the applicable ACM states using the ACM runtime REST Api                            	|
| 14     	| DeleteAcInstanceTest         	| Test deleting the AC instances on the 'undeployed' state using the ACM runtime REST Api                                 	|
| 15     	| DeleteAcDefinitionTest       	| Test deleting the AC definitions from the runtime database using the ACM runtime REST Api                               	|
