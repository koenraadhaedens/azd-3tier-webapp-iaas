param environmentName string
param location string
param subnetId string
@secure()
param winVMPassword string
param tags object
param winVMUsername string

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-api-${environmentName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'vm-api-${environmentName}'
  location: location
  tags: union(tags, { 'azd-service-name': 'api' })
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      adminUsername: winVMUsername
      adminPassword: winVMPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
