param location string = resourceGroup().location
param storageAccountName string = 'appcatstorage'
param functionAppName string = 'appcatfunction'
param functionAppPlanName string = 'appcatfunctionplan'
param appInsightsName string = 'appcatinsights'
// This is an app registration is needed to be made prior to deployment that will allow only authenticated processes from github.com to call the azure function
@secure()
param shipperClientID string = newGuid()

// Data lake for appcat results
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'appcat'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Azure Function to support appcat results shipment to the data lake
resource functionAppPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: functionAppPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}


resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    reserved: true
    httpsOnly: true
    serverFarmId: functionAppPlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      cors: {
        allowedOrigins: [
          'https://github.com'
        ]
        supportCredentials: false
      }
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccountName
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionAppName
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
      ]
    }
  }
}

// Allow the data lake to be written to by the function app
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: functionApp.identity.principalId
  }
}



// Adds the authentication settings to the function app
// Restricts to identiites assigned to the app registration
// Uses the client id as an input parameter
resource authSettingsV2 'Microsoft.Web/sites/config@2023-01-01' = {
  name: 'authsettingsV2'
  parent: functionApp
  properties: {
    globalValidation: {
      requireAuthentication:  true
      unauthenticatedClientAction: 'Return401'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          openIdIssuer: 'https://login.microsoftonline.com/v2.0/${subscription().tenantId}/'
          clientId: shipperClientID
        }
        validation: {
          jwtClaimChecks: {}
          allowedAudiences: [
          ]
          defaultAuthorizationPolicy: {
            allowedPrincipals: {}
          }
        }
      }
    }
    login: {
      routes: {}
      tokenStore: {
        enabled: true
        tokenRefreshExtensionHours: json('72.0')
        fileSystem: {}
        azureBlobStorage: {}
      }
      preserveUrlFragmentsForLogins: false
      cookieExpiration: {
        convention: 'FixedTime'
        timeToExpiration: '08:00:00'
      }
      nonce: {
        validateNonce: true
        nonceExpirationInterval: '00:05:00'
      }
    }
    httpSettings: {
      requireHttps: true
      routes: {
        apiPrefix: '/.auth'
      }
      forwardProxy: {
        convention: 'NoProxy'
      }
    }
  }
}
