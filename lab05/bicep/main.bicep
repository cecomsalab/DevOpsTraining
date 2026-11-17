// Optional exercise: the same kind of storage account written in Bicep.
@description('Short lowercase name used in the storage account name.')
@minLength(3)
@maxLength(10)
param prefix string

@description('Azure region. Defaults to the region of the resource group.')
param location string = resourceGroup().location

var storageName = 'st${prefix}${take(uniqueString(resourceGroup().id), 6)}'

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
  tags: {
    course: 'devops'
    lab: '05'
  }
}

output storageAccountName string = storage.name
output blobEndpoint string = storage.properties.primaryEndpoints.blob
