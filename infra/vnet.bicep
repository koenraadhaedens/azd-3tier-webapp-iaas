targetScope = 'resourceGroup'

param environmentName string
param location string

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
output webSubnetId string = vnet.properties.subnets[0].id
output apiSubnetId string = vnet.properties.subnets[1].id
output sqlSubnetId string = vnet.properties.subnets[2].id
