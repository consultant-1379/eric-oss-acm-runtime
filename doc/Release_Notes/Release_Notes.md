# Release Notes

## [latest Q2 2024 3.3.0-12]

```text
Mapped to policy-clamp version 7.1.2 in open source
```
[policy-clamp 7.1.2](https://github.com/onap/policy-clamp/tree/7.1.2)

### Added
#### ACM Runtime

| Jira Description                                                    | IDUN Jira                                                                    | ONAP Jira                                                       |
|---------------------------------------------------------------------|------------------------------------------------------------------------------|-----------------------------------------------------------------|
| Allow properties to be updated recursively in the participant cache | [IDUN-116663](https://eteamproject.internal.ericsson.com/browse/IDUN-116663) | [POLICY-4918](https://jira.onap.org/browse/POLICY-4918)         |
| Allow update of composition element versions in migration           | [IDUN-116661](https://eteamproject.internal.ericsson.com/browse/IDUN-116661) | [POLICY-4915](https://jira.onap.org/browse/POLICY-4915)         |
| Allow config of maxWaitStatusMs through the helm chart              | [IDUN-119085](https://eteamproject.internal.ericsson.com/browse/IDUN-119085) | [PFACM-206](https://eteamproject.ericsson.net/browse/PFACM-206) |


#### Intermediary Module

| Jira Description                                                    | IDUN Jira                                                                    | ONAP Jira                                               |
|---------------------------------------------------------------------|------------------------------------------------------------------------------|---------------------------------------------------------|
| Allow properties to be updated recursively in the participant cache | [IDUN-116663](https://eteamproject.internal.ericsson.com/browse/IDUN-116663) | [POLICY-4918](https://jira.onap.org/browse/POLICY-4918) |
| Allow update of composition element versions in migration           | [IDUN-116661](https://eteamproject.internal.ericsson.com/browse/IDUN-116661) | [POLICY-4915](https://jira.onap.org/browse/POLICY-4915) |

#### Helm Chart
- Added global and chart level options to change maxWaitStatusMs timeout
- Added requested TLS changes by team photon for postgres communication to be strict TLS
- Maintenance and refactoring
- Design Rule Fixes

#### Security
- CBOS Updated to 6.13.0-10
- Tidy of dependencies to significantly decrease vulnerabilities


## [Q1 2024 3.2.2-8]

```text
Mapped to policy-clamp version 7.1.1 in open source
```
[policy-clamp 7.1.1](https://github.com/onap/policy-clamp/tree/7.1.1)

### Added
#### ACM Runtime

| Jira Description                                                             | IDUN Jira                                                                            | ONAP Jira                                               |
|------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|---------------------------------------------------------|
| Tracing for Kafka and Http calls added                                       | [IDUN-42096](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-42096)   | [POLICY-4875](https://jira.onap.org/browse/POLICY-4875) |
| Properties from cache no longer overwritten at redeploy                      | [IDUN-104369](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-104369) | [POLICY-4908](https://jira.onap.org/browse/POLICY-4908) |
| Old and new properties retained for comparison by participant implementation | [IDUN-104369](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-104369) | [POLICY-4908](https://jira.onap.org/browse/POLICY-4908) |


#### Intermediary Module

| Jira Description                                                             | IDUN Jira                                                                            | ONAP Jira                                               |
|------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|---------------------------------------------------------|
| Tracing for Kafka added                                                      | [IDUN-42096](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-42096)   | [POLICY-4875](https://jira.onap.org/browse/POLICY-4875) |
| Properties from cache no longer overwritten at redeploy                      | [IDUN-104369](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-104369) | [POLICY-4908](https://jira.onap.org/browse/POLICY-4908) |
| Old and new properties retained for comparison by participant implementation | [IDUN-104369](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-104369) | [POLICY-4908](https://jira.onap.org/browse/POLICY-4908) |
| Version-specific abstract classes added for back-compatibility               | [IDUN-104369](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-104369) | [POLICY-4952](https://jira.onap.org/browse/POLICY-4952) |

#### Helm Chart
- Tracing options added to values.yaml
- TLS configured for tracing
- Maintenance and refactoring
- Design Rule Fixes
- Removed db creation job
- Made ACM Operation soft timeout configurable in helm chart

#### Security
- CBOS Updated to 6.8.0-9
- DMAAP-related vulnerabilities all removed with large dependency removal

## [preQ1 2024 3.1.0-7]

```text
Mapped to policy-clamp version 7.1.0 in open source
```
[policy-clamp 7.1.0](https://github.com/onap/policy-clamp/tree/7.1.0)
### Added
#### ACM Runtime

| Jira Description                                                                                                                                                                        | IDUN Jira                                                                          | ONAP Jira                                               |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------|---------------------------------------------------------|
| Build number in semantic versioning now supported e.g. 2.10.5-23                                                                                                                        | [IDUN-19684](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19684) | [POLICY-4869](https://jira.onap.org/browse/POLICY-4869) |
| More descriptive error messages from rest calls where applicable. Where rest calls are async, more descriptive error message added to AC instance data in db (retrievable by rest call) | [IDUN-19684](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19684) | [POLICY-4870](https://jira.onap.org/browse/POLICY-4870) |

#### Intermediary Module
| Jira Description                                                                                                                                                                        | IDUN Jira                                                                          | ONAP Jira                                               |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------|---------------------------------------------------------|
| Build number in semantic versioning now supported e.g. 2.10.5-23                                                                                                                        | [IDUN-1968](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19684)  | [POLICY-4869](https://jira.onap.org/browse/POLICY-4869) |
| More descriptive error messages from rest calls where applicable. Where rest calls are async, more descriptive error message added to AC instance data in db (retrievable by rest call) | [IDUN-19684](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19684) | [POLICY-4870](https://jira.onap.org/browse/POLICY-4870) |

#### Helm Chart
- Security Context made configurable
- Made changes to external secret lookup

### Security
- Dependency version uplifts
- CBOS version 6.5.0-10

## [Q4 2023-12-01 3.0.0-7]

```text
Mapped to policy-clamp version 7.0.2 in open source
```
[policy-clamp 7.0.2](https://github.com/onap/policy-clamp/tree/7.0.2)
### Added
#### ACM Runtime

| Jira Description                                                                                                                             | IDUN Jira                                                                          | ONAP Jira                                               |
|----------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------|---------------------------------------------------------|
| Added migration support in ACM participants and runtime                                                                                      | [IDUN-82296](https://eteamproject.internal.ericsson.com/browse/IDUN-82296)         | [POLICY-4909](https://jira.onap.org/browse/POLICY-4809) |
| Added allowing custom naming of element and composition names in TOSCA service template                                                      | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4827](https://jira.onap.org/browse/POLICY-4827) |
| Added handling of participant restart                                                                                                        | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4684](https://jira.onap.org/browse/POLICY-4684) |
| Added timeout support e.g. prime takes too long - TIMEOUT state is triggered - allows acm to try again or change the state to something else | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4716](https://jira.onap.org/browse/POLICY-4716) |
| Added failure handling support. e.g. if deploy/undeploy fails                                                                                | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4683](https://jira.onap.org/browse/POLICY-4683) |

```text
NOTE: This version of the participant intermediary module contains many new changes/features. It is NOT compatible with previous versions of ACM-R for this reason.
```
#### Intermediary Module

| Jira Description                                                                                                                                                                                                                                                                                                             | IDUN Jira                                                                          | ONAP Jira                                                                                                         |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| Added migration support                                                                                                                                                                                                                                                                                                      | [IDUN-82296](https://eteamproject.internal.ericsson.com/browse/IDUN-82296)         | [POLICY-4909](https://jira.onap.org/browse/POLICY-4809)                                                           |
| Allow update of deployed or undeployed instance                                                                                                                                                                                                                                                                              | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4591](https://jira.onap.org/browse/POLICY-4591) + [POLICY-4682](https://jira.onap.org/browse/POLICY-4682) |
| Allow participant to add new properties to the automation composition and save in acm db                                                                                                                                                                                                                                     | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4650](https://jira.onap.org/browse/POLICY-4650)                                                           |
| Allow participant to add/alter properties in ac definition at priming time                                                                                                                                                                                                                                                   | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4774](https://jira.onap.org/browse/POLICY-4774)                                                           |
| Added handling of participant restart                                                                                                                                                                                                                                                                                        | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4684](https://jira.onap.org/browse/POLICY-4684)                                                           |
| Added timeout support e.g. prime takes too long - TIMEOUT state is triggered - allows acm to try again or change the state to something else                                                                                                                                                                                 | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4716](https://jira.onap.org/browse/POLICY-4716)                                                           |
| Added multiple message support - doesn't block anymore if action triggered by message is slow                                                                                                                                                                                                                                | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4700](https://jira.onap.org/browse/POLICY-4700)                                                           |
| Added failure handling support. e.g. if deploy/undeploy fails                                                                                                                                                                                                                                                                | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4683](https://jira.onap.org/browse/POLICY-4683)                                                           |
| Added interface methods in AutomationCompositionElementListener - now action can be carried out in participant in response to; deploy, undeploy, lock, unlock, prime, deprime, update, delete and migrate - details [here](https://docs.onap.org/projects/onap-policy-parent/en/latest/clamp/acm/acm-participant-guide.html) | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4706](https://jira.onap.org/browse/POLICY-4706)                                                           |
| Added interface methods to respond to participant restart - details [here](https://docs.onap.org/projects/onap-policy-parent/en/latest/clamp/acm/acm-participant-guide.html)                                                                                                                                                 | [IDUN-19663](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-19663) | [POLICY-4747](https://jira.onap.org/browse/POLICY-4747)                                                           |

#### Helm Chart
- Design rule maintenance
- 2PP uplifts
- Made custom naming available in chart

### Changed
- Application updated to Java 17
- Application updated to Springboot 3
- Application updated to Spring 6

### Security
- CBOS version 6.2.0-13
- Dependency version uplifts

## [Q3 - 2023-09-13 - 2.0.0-4]

```text
Mapped to policy-clamp version 6.4.2 in open source
```
[policy-clamp 6.4.2](https://github.com/onap/policy-clamp/tree/6.4.2)
### Added

#### ACM Runtime
- As before
#### Intermediary Module
- As before

#### Helm Chart
- Added functional SIP-TLS
- Added service mesh support
- Design rule maintenance
- 2PP uplifts
- Added prometheus metrics support

### Security
- CBOS version 5.22.0-8
- Dependency version uplifts
## [Q2 - 2023-06-29 - 1.0.0-17]

```text
Mapped to policy-clamp version 6.4.2 in open source
```
[policy-clamp 6.4.2](https://github.com/onap/policy-clamp/tree/6.4.2)
### Added
- First release of ACM-R.
- Delivered ACM runtime application.
- Delivered ACM runtime helm chart.
- Delivered ACM participant intermediary module to allow user to create their own participants.
- Delivered Helm charts.
- Delivered microservice pipeline.

### Security
- CBOS version 5.0.0-22
