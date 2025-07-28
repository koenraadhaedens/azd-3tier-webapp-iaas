param environmentName string
param location string
param subnetId string
@secure()
param winVMPassword string
param tags object
param winVMUsername string

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-sql-${environmentName}'
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
  name: 'vm-sql-${environmentName}'
  location: location
  tags: union(tags, { 'azd-service-name': 'sql' })
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
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2019-ws2022'
        sku: 'sqldev'
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

