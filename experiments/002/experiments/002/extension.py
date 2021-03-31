from chaoslib.types import Configuration, Secrets
import subprocess
__all__ = ["put_on" , "steady"]

#export PYTHONPATH=`pwd`  

def stop_function(temperature: int = 90, configuration: Configuration = None,
           secrets: Secrets = None) -> None:

    print('Stopping function')
    name = configuration.get('functionAppName')
    rg = configuration.get('resourceGroupName')
    subid = configuration.get('subscriptionId')  
    steadyState = subprocess.run(["pwsh", "stop-app.ps1" , '-functionAppName',  f'{name}', '-resourceGroupName' , f'{rg}' , '-subscriptionId', f'{subid}'])

    pass

def start_function(configuration: Configuration = None,
           secrets: Secrets = None) -> None:
    print('Starting function')
    name = configuration.get('functionAppName')
    rg = configuration.get('resourceGroupName')
    subid = configuration.get('subscriptionId')  
    steadyState = subprocess.run(["pwsh", "start-app.ps1" , '-functionAppName',  f'{name}', '-resourceGroupName' , f'{rg}', '-subscriptionId', f'{subid}'])
    
    pass


def steady(configuration: Configuration = None,
           secrets: Secrets = None) -> bool:
    print('checking steady state')
    url = configuration.get('url')
    primaryappid = configuration.get('primaryAppId')
    secondaryappid = configuration.get('secondaryAppId')
    steadyState = subprocess.run(["pwsh", "steady-state.ps1" , '-baseUri',  f'{url}', '-primaryAppId' , f'{primaryappid}', '-secondaryAppId' , f'{secondaryappid}' ])
    # 0 means that the system is in its steady state
    # 1 means that something is not working well
    return steadyState.returncode == 0

