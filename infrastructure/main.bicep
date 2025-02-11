@minLength(3)
@maxLength(10)
param env string

param location string = resourceGroup().location

resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: '${env}storage'
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

resource dbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: '${env}dbaccount'
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  parent: dbAccount
  name: 'db'
  properties: {
    resource: {
      id: 'db'
    }
    options: {
      throughput: 1000
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: database
  name: 'container'
  properties: {
    resource: {
      id: 'container'
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
    }
  }
}
