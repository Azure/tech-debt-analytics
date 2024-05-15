# Quickstart guide to running this project

## 0. Fork the repository

This solution is made available under the MIT license. You can fork the repository to your own GitHub account and use it as you see fit.

## 1. Deploy resources to Azure via CI/CD

To ensure the repository can securely deploy resources to Azure, do the following:

- [Optional but highly recommended] Create a [custom role](../infra/custom-deployer-role.json) in the subscription to allow deployment of the types of resources included in this solution with the least amount of privileges.
  - [Most recommended] You could provision the resource group first and associate the role only to that resource group to reduce the security perimeter of the role.
  - [Not recommended] Alternatively, you can assign contributor access to the subscription to the User Managed Identity when you create it.
- Create the [App Registration](security_and_authentication.md#app-registration) that the Azure Functions will use to provide authentication.
- Create a [User Managed Identity](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azcli) and assigned it to the custom role.
- Create an associated [Federated Credential](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation) for the User Managed Identity for the repository.
- Add the User Managed Identity Client ID within the secrets for the repository.
  - `AZURE_CLIENT_ID`: The client ID of the User Managed Identity.
  - `AZURE_TENANT_ID`: The tenant ID that the User Managed Identity exists in.
  - `AZURE_SUBSCRIPTION_ID`: The subscription ID where the resources are to be deployed.
- Add a login step within the CI/CD using the secrets associated with the User Managed Identity and the subscription you wish to deploy into.

```yaml
- name: Azure login
    uses: azure/login@v2
    with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## 2. Add modernisation assessment pipelines to your repos

For each repository that you want to analyse, you will need to add the secrets for authenticating and a pipeline/action yaml file that will run the assessment and send it to the shipper API.

To support authentication by the pipeline, you need to get the app registration's client ID plus the tent ID and add them as secrets in the repository.

Then, within the pipeline you will need to login to Entra as the pipeline. The `--allow-no-subscriptions` flag is used to allow the pipeline to login even if though it won't be connected to any subscriptions.

```yaml
- name: Azure login
    uses: azure/login@v2
    with:
    # This is an app registration client ID associated with the shipper function.
    client-id: ${{ secrets.SHIPPER_CLIENT_ID }} 
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    allow-no-subscriptions: true
```

As the Function will need a Bearer token to authenticate, you will need to get a token from Entra that you can then pass as a header of the request. You can use the Azure CLI to get an access token.

```yaml
- name: Set environment variables
    run: |
    echo "ACCESS_TOKEN=$(az account get-access-token --query accessToken --resource  ${{ secrets.SHIPPER_CLIENT_ID }} -o tsv)" >> $GITHUB_ENV
```

You will need your modernisation assessment process to run. It is recommended to work on this within a [GitHub Codespace](https://docs.github.com/en/codespaces/overview) as a close replica of the environment that the pipeline will run in.

```yaml
- name: Install appcat
    run: dotnet tool install -g dotnet-appcat
- name: Run appcat JSON
    # This creates the payload for the datalake to give overall visibility of the modernisation effort
    run: appcat analyze ${{ env.DOTNET_APP_PATH }} --source folder --report ${{ env.REPORT_FOLDER }} --serializer json --non-interactive --code --binaries --target ${{ env.TARGET}}
```

You can then use the token in the Authorization header of the request.

```yaml
- name: Send report
    run: |
    response=$(curl -X ${{ env.FUNCTION_APP_VERB }} -v \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${{ env.ACCESS_TOKEN }}" \
    --data @${{ env.REPORT_JSON_FILENAME }} \
    "${{ env.SHIPPER_URL }}")
```

Optionally, you can also add analysis outputs as [Github Actions Artifacts](https://docs.github.com/en/actions/guides/storing-workflow-data-as-artifacts) to the pipeline to allow immediate viewing of outputs by developers and other people who have an interest and access to the Actions.

```yaml
    - name: Upload results
      uses: actions/upload-artifact@v4
      with:
        path: ${{ env.REPORT_FOLDER }}
```

You can see a working end-to-end example of this in the [appcat-demos.yml](../.github/workflows/appcat-demos.yml) file.

## 3. Deploy the Power BI report

> Work in progress
