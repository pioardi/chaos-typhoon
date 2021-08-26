# chaos-typhoon :cyclone: :ocean: :zap: :cloud:

**Typoohn** is a collection of **chaos experiments** built with [chaostoolkit](https://github.com/chaostoolkit/chaostoolkit) that can be used in several ways based on the maturity level of your system.  
Goals of this project:

- Share and document real-world failures
- Provide a reference architecture and solution to handle failure scenarios
- Design chaos experiments based on real-world failures
- Share scenarios and experiments from different organizations and individuals around the globe
- Act at cloud services level
- Provide a starting point experiment to extend and customize
- Promote chaos days into organizations

## Real-worl scenarios

Experiments list:

| Number      | Environment     | Description                                                                                           |
| ----------- | -----------     | -----------                                                                                           |
| 001         | Cloud ( Azure ) | An app service or function app in the primary region has an outage                                    |
| 002         | Cloud ( Azure ) | An application uses the claim check pattern with a blob storage, the blob storage is not available    |

## Contribute

This repo is open to new contributions.  
Please share failure scenarios that you met:

- Specify a draft infrastructure that was affected by the failure ( with a Diagram, plantuml should be the best option )
- Clearly describe the failure scenario
- Clearly describe how to handle the failure scenario to minimize/avoid impact on the system
- Implement the solution to handle the failure and automate the deployment
- Design and automate a chaos experiment to test the solution ( with chaostoolkit or others if needed )
