targetScope = 'subscription'

@description('Name of the environment')
param environmentName string

@description('Location for resources')
param location string

@secure()
@description('Password for the Windows VMs')
param winVMPassword string

var rgName = 'rg-${environmentName}'
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: {
    SecurityControl: 'Ignore'
    CostControl: 'Ignore'
  }
}

module vnet 'vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup(rgName)
  params: {
    environmentName: environmentName
    location: location
  }
}

// Reference subnet resource IDs from vnet module outputs
module webvm 'webvm.bicep' = {
  name: 'webvm'
  scope: resourceGroup(rgName)
  params: {
    environmentName: environmentName
    location: location
    subnetId: vnet.outputs.webSubnetId
    winVMPassword: winVMPassword
    winVMAdminUsername: 'adminuser'
    tags: tags
  }
}

module apivm 'apivm.bicep' = {
  name: 'apivm'
  scope: resourceGroup(rgName)
  params: {
    environmentName: environmentName
    location: location
    subnetId: vnet.outputs.apiSubnetId
    winVMPassword: winVMPassword
    winVMUsername: 'adminuser'
    tags: tags
  }
}

module sqlvm 'sqlvm.bicep' = {
  name: 'sqlvm'
  scope: resourceGroup(rgName)
  params: {
    environmentName: environmentName
    location: location
    subnetId: vnet.outputs.sqlSubnetId
    winVMPassword: winVMPassword
    tags: tags
    winVMUsername: 'adminuser'
  }
}
