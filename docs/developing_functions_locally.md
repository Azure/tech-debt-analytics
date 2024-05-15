# How to work with this project locally to make changes to the `shipper` functionality

## Tools for local dev

Tools that will be helpful for local development are:

- Azure Functions Core Tools: This is a local version of the Azure Functions runtime that you can run on your local machine. It allows you to develop and test your functions locally before deploying them to Azure.
- Azurite: This is a local emulator for Azure Storage that you can run on your local machine. It allows you to develop and test your functions locally without needing to connect to an Azure Storage account.
- Az CLI: This is a command-line tool that you can use to interact with Azure resources. It allows you to create and manage Azure resources from the command line and authenticate with Azure.
- appcat: The modernisation command line tool for assessing readiness to deploy to Azure.

### Installation

To install the recommended tools, follow these steps:

- Install Azure Functions Core Tools by following the instructions in the [Azure Functions Core Tools documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-csharp#v2).
- Install Azurite by following the instructions in the [Azurite documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio-code%2Cblob-storage).
- Install the Az CLI by following the instructions in the [Az CLI documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- Install appcat following the instructions in the [appcat documentation](appcat.md).

## Local dev

To make changes to the Azure Function, you can edit the code in the `shipper/` directory. Once you've made your changes, you can test them locally by running the Azure Function and sending test payloads to it.

### Running the Azure Function locally

To run the Azure Function locally, you will need to use local storage:

- Start the Azureite Blob Storage emulator by running the command `azurite-blob --silent`.
- Add a `local.settings.json` file with the following:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated"
  }
}
```

Once you've got storage running, you can use `func start` from the `shipper/` directory to start the Azure Function.

### Testing the function locally

You will want to generate a test payload to send to the function. You can do this by running the `appcat` tool.

```bash
appcat analyze shipper --source folder --report appcat-results/reports --serializer json --non-interactive --code --binaries --target AppService.Linux
```

You can now test the Function by sending cURL commands to it locally. For example:

```bash
curl -X PUT -v \
  -H "Content-Type: application/json" \
  --data appcat-results/reports.json \
  "http://localhost:7071/shipper?org=stephlocke&repo=tech-debt-analytics&branch=main&pr=&commit=68af5f6b04dd484a48d9f4814cc5f556743bb34d&committer=stephlocke"
```
