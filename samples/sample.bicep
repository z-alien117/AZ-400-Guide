param location string = resourceGroup().location
param webAppName string
param storageAccountName string
param sqlServerName string
param sqlAdministratorLogin string
param sqlAdministratorPassword string
param keyVaultName string

// Create an Azure Web App
resource webApp 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

// Create an Azure App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${webAppName}-asp'
  location: location
  sku: {
    name: 'F1' // Free tier
  }
}

// Create an Azure Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// Create an Azure SQL Server
resource sqlServer 'Microsoft.Sql/servers@2020-02-02-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    version: '12.0'
  }
}

// Create an Azure Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      // Access policies here
    ]
  }
}

// Store SQL Administrator Password in Key Vault
resource sqlAdminPassword 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultName}/sqlAdministratorPassword'
  properties: {
    value: sqlAdministratorPassword
  }
  dependsOn: [
    keyVault
  ]
}

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
