@minLength(3)
@maxLength(10)
param env string

param location string = resourceGroup().location

resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: '${env}-storage'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: '${env}-appServicePlan'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}

resource appservice 'Microsoft.Web/sites@2024-04-01' = {
  name: '${env}-appServiceName'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}
