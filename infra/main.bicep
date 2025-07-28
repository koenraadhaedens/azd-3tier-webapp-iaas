targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@secure()
@description('Password for the Windows VM')
param winVMPassword string

var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: {
    SecurityControl: 'Ignore'
    CostControl: 'Ignore'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-${environmentName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.50.0/24'
      ]
    }
    subnets: [
      {
        name: 'webSubnet'
        properties: {
          addressPrefix: '192.168.50.0/27'
        }
      }
      {
        name: 'apiSubnet'
        properties: {
          addressPrefix: '192.168.50.32/27'
        }
      }
      {
        name: 'sqlSubnet'
        properties: {
          addressPrefix: '192.168.50.64/27'
        }
      }
    ]
  }
}

module webvm 'webvm.bicep' = {
  name: 'webvm'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    subnetId: vnet.properties.subnets[0].id
    winVMPassword: winVMPassword
    tags: tags
  }
}

module apivm 'apivm.bicep' = {
  name: 'apivm'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    subnetId: vnet.properties.subnets[1].id
    winVMPassword: winVMPassword
    tags: tags
  }
}

module sqlvm 'sqlvm.bicep' = {
  name: 'sqlvm'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    subnetId: vnet.properties.subnets[2].id
    winVMPassword: winVMPassword
    tags: tags
  }
}
